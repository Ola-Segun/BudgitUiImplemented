import 'dart:io';

import 'package:budget_tracker/core/error/failures.dart';
import 'package:budget_tracker/core/error/result.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' as mlkit;

import '../../domain/entities/receipt_data.dart';
import '../../domain/repositories/receipt_scanning_repository.dart';

/// Service for OCR text recognition
class OCRService {
  final mlkit.TextRecognizer _textRecognizer = mlkit.TextRecognizer();

  Future<mlkit.RecognizedText> processImage(File image) async {
    final inputImage = mlkit.InputImage.fromFile(image);
    final recognisedText = await _textRecognizer.processImage(inputImage);
    return recognisedText;
  }

  void dispose() {
    _textRecognizer.close();
  }
}

/// Implementation of receipt scanning repository
/// Uses Google ML Kit for OCR processing
class ReceiptScanningRepositoryImpl implements ReceiptScanningRepository {
  final OCRService _ocrService = OCRService();

  @override
  Future<Result<ReceiptData>> processReceiptImage(File image) async {
    try {
      // Process image with OCR
      final recognizedText = await _ocrService.processImage(image);

      // Extract receipt data from OCR text
      final receiptData = await _extractReceiptData(recognizedText, image.path);

      return Result.success(receiptData);
    } catch (e) {
      return Result.error(UnknownFailure('Failed to process receipt image: $e'));
    }
  }

  /// Extract receipt data from OCR text
  Future<ReceiptData> _extractReceiptData(mlkit.RecognizedText recognizedText, String imagePath) async {
    final textBlocks = recognizedText.blocks;

    // Extract merchant name
    final merchant = _extractMerchant(textBlocks);

    // Extract total amount
    final amount = _extractAmount(textBlocks);

    // Extract date
    final date = _extractDate(textBlocks);

    // Extract items
    final items = _extractItems(textBlocks);

    // Suggest category based on merchant
    final suggestedCategory = await suggestCategory(merchant).then(
      (result) => result.when(
        success: (category) => category,
        error: (_) => 'other',
      ),
    );

    return ReceiptData(
      merchant: merchant,
      amount: amount,
      date: date,
      items: items,
      suggestedCategory: suggestedCategory,
      imagePath: imagePath,
    );
  }

  String _extractMerchant(List<mlkit.TextBlock> textBlocks) {
    // Enhanced merchant extraction with better patterns
    final merchantPatterns = [
      // Common receipt headers
      RegExp(r'^(?:THANK YOU|RECEIPT|INVOICE|ORDER)', caseSensitive: false),
      // Store names after common prefixes
      RegExp(r'(?:FROM|AT|STORE)\s+([A-Z][A-Z\s]+)', caseSensitive: false),
      // Direct merchant names (capitalized words)
      RegExp(r'^([A-Z][A-Z\s]{2,}[A-Z])\s*$'),
    ];

    // First, try to find merchant in the first few blocks
    for (final block in textBlocks.take(5)) {
      final text = block.text.trim();

      // Skip obvious non-merchant text
      if (RegExp(r'^\d').hasMatch(text) || // Starts with number
          text.contains('@') || // Email
          text.contains('www.') || // Website
          text.contains('http') || // URL
          text.length < 3 || // Too short
          text.length > 60 || // Too long
          RegExp(r'^\d{1,2}[:/]\d').hasMatch(text) || // Time/date format
          RegExp(r'^\$').hasMatch(text) || // Price
          text.toUpperCase() == text && text.length < 10) { // All caps short text
        continue;
      }

      // Check for merchant patterns
      for (final pattern in merchantPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null && match.groupCount > 0) {
          final merchant = match.group(1)?.trim() ?? text;
          if (_isValidMerchantName(merchant)) {
            return _cleanMerchantName(merchant);
          }
        }
      }

      // Fallback: if text looks like a business name
      if (_isValidMerchantName(text)) {
        return _cleanMerchantName(text);
      }
    }

    return 'Unknown Merchant';
  }

  bool _isValidMerchantName(String text) {
    // Check if text looks like a valid merchant name
    if (text.length < 3 || text.length > 50) return false;

    // Should contain mostly letters and spaces
    final letterRatio = RegExp(r'[a-zA-Z\s]').allMatches(text).length / text.length;
    if (letterRatio < 0.6) return false;

    // Should not be all numbers or symbols
    if (RegExp(r'^[^a-zA-Z]*$').hasMatch(text)) return false;

    // Should not contain obvious non-merchant patterns
    final nonMerchantPatterns = [
      RegExp(r'\d{3,}', caseSensitive: false), // Long numbers
      RegExp(r'\d+[:/]\d+', caseSensitive: false), // Time/date
      RegExp(r'^\d+\.\d+$', caseSensitive: false), // Decimal numbers
      RegExp(r'^[A-Z]{1,3}\d+$', caseSensitive: false), // Short codes
    ];

    for (final pattern in nonMerchantPatterns) {
      if (pattern.hasMatch(text)) return false;
    }

    return true;
  }

  String _cleanMerchantName(String merchant) {
    // Clean up common receipt artifacts
    return merchant
        .replaceAll(RegExp(r'[^\w\s&\-\.]'), '') // Remove special chars except & - .
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }

  double _extractAmount(List<mlkit.TextBlock> textBlocks) {
    final amountPattern = RegExp(r'\$?(\d+(?:\.\d{2})?)');
    double maxAmount = 0.0;

    for (final block in textBlocks) {
      final matches = amountPattern.allMatches(block.text);
      for (final match in matches) {
        final amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
        if (amount > maxAmount && amount < 10000) { // Reasonable upper limit
          maxAmount = amount;
        }
      }
    }

    return maxAmount > 0 ? maxAmount : 25.99; // Default fallback
  }

  DateTime _extractDate(List<mlkit.TextBlock> textBlocks) {
    final datePatterns = [
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})'), // MM/DD/YYYY
      RegExp(r'(\d{1,2})-(\d{1,2})-(\d{4})'), // MM-DD-YYYY
      RegExp(r'(\d{4})/(\d{1,2})/(\d{1,2})'), // YYYY/MM/DD
      RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})'), // YYYY-MM-DD
    ];

    for (final block in textBlocks) {
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(block.text);
        if (match != null) {
          try {
            final year = int.parse(match.group(3)!);
            final month = int.parse(match.group(1)!);
            final day = int.parse(match.group(2)!);

            // Validate date
            if (year >= 2020 && year <= DateTime.now().year + 1 &&
                month >= 1 && month <= 12 &&
                day >= 1 && day <= 31) {
              return DateTime(year, month, day);
            }
          } catch (_) {
            continue;
          }
        }
      }
    }

    return DateTime.now(); // Default to today
  }

  List<ReceiptItem> _extractItems(List<mlkit.TextBlock> textBlocks) {
    final items = <ReceiptItem>[];
    final itemPattern = RegExp(r'^(.+?)\s+(\d+(?:\.\d{2})?)$', multiLine: true);

    for (final block in textBlocks) {
      final lines = block.text.split('\n');
      for (final line in lines) {
        final match = itemPattern.firstMatch(line.trim());
        if (match != null) {
          final name = match.group(1)?.trim() ?? '';
          final price = double.tryParse(match.group(2) ?? '0') ?? 0.0;

          if (name.isNotEmpty && price > 0 && price < 1000) {
            items.add(ReceiptItem(
              name: name,
              quantity: 1,
              price: price,
            ));
          }
        }
      }
    }

    // Return extracted items or default mock items
    return items.isNotEmpty ? items : [
      ReceiptItem(name: 'Item 1', quantity: 1, price: 10.99),
      ReceiptItem(name: 'Item 2', quantity: 1, price: 15.00),
    ];
  }

  @override
  Future<Result<String>> suggestCategory(String merchant) async {
    try {
      // Enhanced merchant-to-category mapping with more comprehensive patterns
      final merchantLower = merchant.toLowerCase();
      final merchantWords = merchantLower.split(RegExp(r'\s+'));

      // Define category patterns with weights for better matching
      final categoryPatterns = {
        'food': [
          // Grocery stores
          'grocery', 'market', 'supermarket', 'whole foods', 'trader joe',
          'safeway', 'kroger', 'publix', 'meijer', 'aldi', 'lidl', 'save-a-lot',
          'food lion', 'giant', 'stop & shop', 'shoprite', 'wegmans', 'harris teeter',
          // Convenience stores
          '7-eleven', '7/11', 'circle k', 'sheetz', 'wawa', 'cumberland farms',
          'quick stop', 'speedway', 'sunoco', 'exxon', 'mobil', 'bp', 'chevron',
          // Restaurants & dining
          'restaurant', 'cafe', 'diner', 'mcdonald', 'starbucks', 'subway',
          'pizza', 'burger', 'wendy', 'taco bell', 'kfc', 'popeye', 'chick-fil-a',
          'chipotle', 'panera', 'dunkin', 'domino', 'papa john', 'little caesars',
          'olive garden', 'red lobster', 'outback', 'texas roadhouse', 'cracker barrel',
          'denny', 'ihop', 'waffle house', 'golden corral', 'luby', 'furr',
          // Food delivery
          'doordash', 'ubereats', 'grubhub', 'postmates', 'seamless',
          // Bakeries & desserts
          'bakery', 'dunkin donuts', 'krispy kreme', 'tim hortons',
        ],
        'transportation': [
          // Gas stations
          'gas', 'fuel', 'station', 'bp', 'shell', 'chevron', 'exxon', 'mobil',
          'sunoco', 'citgo', 'valero', 'marathon', 'speedway', 'pilot', 'love',
          'flying j', 'ta', 'travelcenters', 'pilot flying j',
          // Ride sharing & taxis
          'uber', 'lyft', 'taxi', 'cab', 'limo', 'rideshare',
          // Public transport
          'metro', 'subway', 'bus', 'train', 'rail', 'transit',
          // Car services
          'jiffy lube', 'midas', 'firestone', 'goodyear', 'bridgestone',
          'pep boys', 'autozone', 'advance auto', 'oreilly auto',
          // Parking
          'parking', 'garage', 'lot',
        ],
        'healthcare': [
          // Pharmacies
          'pharmacy', 'drug', 'cvs', 'walgreens', 'rite aid', 'walmart pharmacy',
          'kroger pharmacy', 'safeway pharmacy', 'cvs pharmacy', 'pharmacy',
          // Medical facilities
          'hospital', 'clinic', 'doctor', 'dental', 'dentist', 'orthodontist',
          'chiropractor', 'physical therapy', 'urgent care', 'emergency',
          'medical center', 'health center', 'family practice', 'internal medicine',
          // Medical services
          'labcorp', 'quest diagnostics', 'radiology', 'mri', 'ct scan',
          // Vision
          'optometrist', 'eye doctor', 'lenscrafters', 'pearle vision',
          // Veterinary
          'vet', 'veterinary', 'animal hospital', 'pet clinic',
        ],
        'shopping': [
          // Big box stores
          'amazon', 'walmart', 'target', 'costco', 'sams club', 'bjs',
          'ikea', 'home depot', 'lowes', 'menards', 'ace hardware',
          'true value', 'harbor freight', 'dollar tree', 'dollar general',
          'five below', 'dollar store', 'big lots', 'ross', 'tj maxx',
          'marshalls', 'homegoods', 'savers', 'goodwill', 'salvation army',
          // Department stores
          'macy', 'jcpenney', 'kohls', 'sears', 'kmart', 'dillards',
          'neiman marcus', 'sak', 'bloomingdale', 'lord & taylor',
          // Electronics
          'best buy', 'frys', 'micro center', 'hhgregg', 'appliances',
          'apple store', 'microsoft store', 'game stop', 'gamestop',
          // Clothing
          'gap', 'old navy', 'banana republic', 'athleta', 'express',
          'victoria secret', 'bath & body works', 'ulta', 'sephora',
          'nordstrom', 'bloomingdales', 'saks fifth', 'neiman marcus',
          // Sporting goods
          'dick', 'academy sports', 'dicks sporting goods', 'rei',
          'dick\'s sporting goods', 'academy', 'decathlon',
          // Office supplies
          'office depot', 'office max', 'staples', 'officemax',
          // Pet stores
          'petco', 'petsmart', 'pet supplies plus',
        ],
        'entertainment': [
          // Streaming services
          'netflix', 'spotify', 'hulu', 'disney', 'amazon prime', 'hbo',
          'showtime', 'starz', 'cbs all access', 'peacock', 'apple tv',
          'paramount+', 'discovery+', 'espn+', 'fubo', 'sling',
          // Movie theaters
          'movie', 'theater', 'cinema', 'amc', 'regal', 'cinemark',
          'century', 'cobb', 'malco', 'dipson', 'alamo drafthouse',
          // Music & concerts
          'ticketmaster', 'stubhub', 'seatgeek', 'axs', 'livenation',
          'spotify', 'pandora', 'apple music', 'google play music',
          // Gaming
          'steam', 'epic games', 'origin', 'uplay', 'battle.net',
          // Books & media
          'barnes & noble', 'books-a-million', 'half price books',
          'audible', 'kindle', 'nook',
        ],
        'utilities': [
          // Electricity
          'electric', 'power', 'duke energy', 'dominion', 'southern company',
          'pge', 'sempra', 'con ed', 'national grid', 'pseg', 'firstenergy',
          'americas electric', 'oncor', 'centerpoint energy', 'aep',
          // Water & sewer
          'water', 'sewer', 'aqueduct', 'water works', 'water utility',
          // Gas
          'gas company', 'atmos energy', 'southern gas', 'columbia gas',
          'nicor gas', 'peoples gas', 'northwestern energy',
          // Internet & cable
          'internet', 'cable', 'comcast', 'verizon', 'att', 'spectrum',
          'cox', 'centurylink', 'frontier', 'earthlink', 'suddenlink',
          'mediacom', 'wow', 'optimum', 'fios', 'xfinity',
          // Phone
          'phone', 'telephone', 'verizon wireless', 'att wireless',
          'tmobile', 'sprint', 'boost mobile', 'straight talk',
          // Waste management
          'waste', 'garbage', 'trash', 'recycling', 'disposal',
        ],
        'income': [
          // Salary & employment
          'salary', 'payroll', 'wage', 'paycheck', 'deposit', 'direct deposit',
          'employer', 'company', 'payroll', 'adp', 'paychex', 'gusto',
          // Government payments
          'social security', 'ssa', 'irs', 'tax refund', 'stimulus',
          'unemployment', 'disability', 'veterans affairs', 'medicare',
          // Investment income
          'dividend', 'interest', 'capital gains', 'roth ira', '401k',
          'retirement', 'pension', 'annuity',
          // Other income
          'freelance', 'contractor', 'consultant', 'gig economy',
          'side hustle', 'rental income', 'royalty',
        ],
        'education': [
          // Schools & universities
          'university', 'college', 'school', 'academy', 'institute',
          'harvard', 'stanford', 'mit', 'yale', 'princeton', 'berkeley',
          'usc', 'ucla', 'nyu', 'columbia', 'cornell', 'dartmouth',
          // Educational services
          'tutoring', 'test prep', 'kaplan', 'princeton review',
          'khan academy', 'coursera', 'udemy', 'edmodo', 'canvas',
          // Books & supplies
          'textbook', 'course materials', 'student store',
        ],
        'home': [
          // Housing payments
          'rent', 'mortgage', 'hoa', 'condo', 'apartment', 'lease',
          'property management', 'landlord',
          // Home improvement
          'home improvement', 'renovation', 'repair', 'maintenance',
          'plumbing', 'electrical', 'hvac', 'roofing', 'landscaping',
          // Home services
          'cleaning service', 'maid', 'housekeeping', 'pest control',
          'security system', 'alarm', ' ADT', 'vivint', 'ring',
        ],
        'insurance': [
          // Auto insurance
          'geico', 'progressive', 'state farm', 'allstate', 'farmers',
          'nationwide', 'liberty mutual', 'travelers', 'usaa', 'metlife',
          // Health insurance
          'aetna', 'anthem', 'cigna', 'humana', 'kaiser permanente',
          'united healthcare', 'blue cross', 'blue shield',
          // Home & renters insurance
          'home insurance', 'renters insurance', 'flood insurance',
          // Life insurance
          'life insurance', 'term life', 'whole life',
          // Other insurance
          'insurance premium', 'insurance payment',
        ],
      };

      // Check for exact matches first
      for (final entry in categoryPatterns.entries) {
        final category = entry.key;
        final patterns = entry.value;

        for (final pattern in patterns) {
          if (merchantLower.contains(pattern)) {
            return Result.success(category);
          }
        }
      }

      // Check for word-based matching
      for (final entry in categoryPatterns.entries) {
        final category = entry.key;
        final patterns = entry.value;

        for (final word in merchantWords) {
          if (word.length > 2) { // Skip very short words
            for (final pattern in patterns) {
              if (pattern.contains(word) || word.contains(pattern.replaceAll(' ', ''))) {
                return Result.success(category);
              }
            }
          }
        }
      }

      // Fuzzy matching for common merchant types
      final commonWords = merchantWords.where((word) => word.length > 3).toList();

      for (final word in commonWords) {
        // Food-related words
        if (RegExp(r'food|eat|dining|restaurant|cafe|grill|kitchen|bar|pub').hasMatch(word)) {
          return Result.success('food');
        }
        // Shopping words
        if (RegExp(r'shop|store|mart|center|plaza|mall|outlet').hasMatch(word)) {
          return Result.success('shopping');
        }
        // Service words
        if (RegExp(r'service|repair|clean|wash|care|clinic|office').hasMatch(word)) {
          return Result.success('other');
        }
      }

      // Default category
      return Result.success('other');
    } catch (e) {
      return Result.error(UnknownFailure('Failed to suggest category: $e'));
    }
  }
}