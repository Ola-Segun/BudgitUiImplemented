import 'package:freezed_annotation/freezed_annotation.dart';

import 'goal.dart';

part 'goal_template.freezed.dart';

/// Goal template entity - represents pre-built goal templates
/// Pure domain entity with no dependencies
@freezed
class GoalTemplate with _$GoalTemplate {
  const factory GoalTemplate({
    required String id,
    required String name,
    required String description,
    required double suggestedAmount,
    required int suggestedMonths,
    required String categoryId,
    required GoalPriority defaultPriority,
    String? icon,
    int? color,
    required List<String> tips,
  }) = _GoalTemplate;

  const GoalTemplate._();

  /// Get suggested deadline based on current date and suggested months
  DateTime get suggestedDeadline => DateTime.now().add(Duration(days: suggestedMonths * 30));

  /// Get monthly contribution amount
  double get monthlyContribution => suggestedAmount / suggestedMonths;

  /// Create goal from template
  Goal createGoal({
    required String title,
    double? customAmount,
    DateTime? customDeadline,
    GoalPriority? customPriority,
  }) {
    return Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      targetAmount: customAmount ?? suggestedAmount,
      currentAmount: 0.0,
      deadline: customDeadline ?? suggestedDeadline,
      priority: customPriority ?? defaultPriority,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: [],
    );
  }

  /// Get preview data for template selection
  Map<String, dynamic> getPreviewData() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'suggestedAmount': suggestedAmount,
      'suggestedMonths': suggestedMonths,
      'monthlyContribution': monthlyContribution,
      'suggestedDeadline': suggestedDeadline,
      'categoryId': categoryId,
      'priority': defaultPriority.name,
      'icon': icon,
      'color': color,
      'tips': tips,
    };
  }

  /// Validate template for goal creation
  bool validateForCreation({
    double? customAmount,
    DateTime? customDeadline,
  }) {
    final amount = customAmount ?? suggestedAmount;
    final deadline = customDeadline ?? suggestedDeadline;

    // Amount must be positive
    if (amount <= 0) return false;

    // Deadline must be in the future
    if (deadline.isBefore(DateTime.now())) return false;

    // Months must be positive
    if (suggestedMonths <= 0) return false;

    return true;
  }

  /// Create customized template with new parameters
  GoalTemplate customize({
    String? newName,
    String? newDescription,
    double? newAmount,
    int? newMonths,
    GoalPriority? newPriority,
    String? newIcon,
    int? newColor,
  }) {
    return GoalTemplate(
      id: id, // Keep same ID for template identification
      name: newName ?? name,
      description: newDescription ?? description,
      suggestedAmount: newAmount ?? suggestedAmount,
      suggestedMonths: newMonths ?? suggestedMonths,
      categoryId: categoryId,
      defaultPriority: newPriority ?? defaultPriority,
      icon: newIcon ?? icon,
      color: newColor ?? color,
      tips: tips, // Keep original tips
    );
  }

  /// Check if template is selected (for UI state management)
  bool isSelected(String? selectedTemplateId) {
    return selectedTemplateId == id;
  }
}

/// Pre-built goal templates
class GoalTemplates {
  static List<GoalTemplate> get all => [
    // Emergency Fund
    const GoalTemplate(
      id: 'emergency_fund_3_months',
      name: 'Emergency Fund (3 Months)',
      description: 'Build a 3-month emergency fund to cover unexpected expenses',
      suggestedAmount: 3000.0,
      suggestedMonths: 3,
      categoryId: 'emergency_fund',
      defaultPriority: GoalPriority.high,
      icon: 'security',
      color: 0xFFDC2626,
      tips: [
        'Aim for 3-6 months of expenses',
        'Keep in a high-yield savings account',
        'Only use for true emergencies',
        'Replenish if you dip into it',
      ],
    ),

    const GoalTemplate(
      id: 'emergency_fund_6_months',
      name: 'Emergency Fund (6 Months)',
      description: 'Build a 6-month emergency fund for financial security',
      suggestedAmount: 6000.0,
      suggestedMonths: 6,
      categoryId: 'emergency_fund',
      defaultPriority: GoalPriority.high,
      icon: 'security',
      color: 0xFFDC2626,
      tips: [
        'Aim for 3-6 months of expenses',
        'Keep in a high-yield savings account',
        'Only use for true emergencies',
        'Replenish if you dip into it',
      ],
    ),

    // Vacation
    const GoalTemplate(
      id: 'vacation_couple',
      name: 'Couple\'s Vacation',
      description: 'Save for a romantic getaway for two',
      suggestedAmount: 2000.0,
      suggestedMonths: 6,
      categoryId: 'vacation',
      defaultPriority: GoalPriority.medium,
      icon: 'beach_access',
      color: 0xFF059669,
      tips: [
        'Book flights and accommodation early for best deals',
        'Consider all-inclusive packages',
        'Don\'t forget travel insurance',
        'Save extra for souvenirs and meals',
      ],
    ),

    const GoalTemplate(
      id: 'vacation_family',
      name: 'Family Vacation',
      description: 'Save for a memorable family vacation',
      suggestedAmount: 4000.0,
      suggestedMonths: 8,
      categoryId: 'vacation',
      defaultPriority: GoalPriority.medium,
      icon: 'beach_access',
      color: 0xFF059669,
      tips: [
        'Plan activities that everyone will enjoy',
        'Look for family-friendly resorts',
        'Consider vacation rentals for more space',
        'Factor in kids\' meals and activities',
      ],
    ),

    // Home Down Payment
    const GoalTemplate(
      id: 'home_down_payment_20_percent',
      name: 'Home Down Payment (20%)',
      description: 'Save for a 20% down payment on your first home',
      suggestedAmount: 40000.0,
      suggestedMonths: 24,
      categoryId: 'home_down_payment',
      defaultPriority: GoalPriority.high,
      icon: 'home',
      color: 0xFF7C3AED,
      tips: [
        'Get pre-approved for a mortgage first',
        'Consider FHA loans for lower down payments',
        'Improve your credit score',
        'Shop around for the best rates',
      ],
    ),

    const GoalTemplate(
      id: 'home_down_payment_10_percent',
      name: 'Home Down Payment (10%)',
      description: 'Save for a 10% down payment on your first home',
      suggestedAmount: 20000.0,
      suggestedMonths: 18,
      categoryId: 'home_down_payment',
      defaultPriority: GoalPriority.high,
      icon: 'home',
      color: 0xFF7C3AED,
      tips: [
        'You\'ll need PMI with less than 20% down',
        'Conventional loans require good credit',
        'Consider gift funds from family',
        'Look into first-time homebuyer programs',
      ],
    ),

    // Debt Payoff
    const GoalTemplate(
      id: 'credit_card_debt',
      name: 'Pay Off Credit Card Debt',
      description: 'Eliminate high-interest credit card debt',
      suggestedAmount: 5000.0,
      suggestedMonths: 12,
      categoryId: 'debt_payoff',
      defaultPriority: GoalPriority.high,
      icon: 'credit_card_off',
      color: 0xFFEA580C,
      tips: [
        'Focus on highest interest rate cards first',
        'Consider balance transfer offers',
        'Cut up cards after payoff to avoid temptation',
        'Build emergency fund simultaneously',
      ],
    ),

    const GoalTemplate(
      id: 'student_loan_debt',
      name: 'Pay Off Student Loans',
      description: 'Eliminate student loan debt faster',
      suggestedAmount: 25000.0,
      suggestedMonths: 36,
      categoryId: 'debt_payoff',
      defaultPriority: GoalPriority.medium,
      icon: 'credit_card_off',
      color: 0xFFEA580C,
      tips: [
        'Explore income-driven repayment plans',
        'Consider refinancing for lower rates',
        'Look into forgiveness programs',
        'Make extra payments when possible',
      ],
    ),

    // Car Purchase
    const GoalTemplate(
      id: 'new_car_down_payment',
      name: 'New Car Down Payment',
      description: 'Save for a down payment on a new car',
      suggestedAmount: 5000.0,
      suggestedMonths: 12,
      categoryId: 'car_purchase',
      defaultPriority: GoalPriority.medium,
      icon: 'directions_car',
      color: 0xFF2563EB,
      tips: [
        'Aim for 20% down to avoid negative equity',
        'Consider certified pre-owned for savings',
        'Research reliability ratings',
        'Factor in insurance and maintenance costs',
      ],
    ),

    // Education
    const GoalTemplate(
      id: 'college_fund',
      name: 'College Fund',
      description: 'Save for your child\'s college education',
      suggestedAmount: 50000.0,
      suggestedMonths: 216, // 18 years
      categoryId: 'education',
      defaultPriority: GoalPriority.medium,
      icon: 'school',
      color: 0xFF7C2D12,
      tips: [
        'Start early to take advantage of compound interest',
        'Consider 529 plans for tax benefits',
        'Research colleges and costs',
        'Look into scholarships and grants',
      ],
    ),

    // Retirement
    const GoalTemplate(
      id: 'retirement_boost',
      name: 'Retirement Savings Boost',
      description: 'Increase your retirement savings',
      suggestedAmount: 10000.0,
      suggestedMonths: 12,
      categoryId: 'retirement',
      defaultPriority: GoalPriority.high,
      icon: 'account_balance',
      color: 0xFF0D9488,
      tips: [
        'Max out employer matches first',
        'Consider Roth IRA for tax-free growth',
        'Increase contributions annually',
        'Diversify your investment portfolio',
      ],
    ),

    // Investment
    const GoalTemplate(
      id: 'investment_portfolio',
      name: 'Investment Portfolio',
      description: 'Build a diversified investment portfolio',
      suggestedAmount: 15000.0,
      suggestedMonths: 24,
      categoryId: 'investment',
      defaultPriority: GoalPriority.medium,
      icon: 'trending_up',
      color: 0xFF16A34A,
      tips: [
        'Diversify across asset classes',
        'Consider low-cost index funds',
        'Invest regularly (dollar-cost averaging)',
        'Focus on long-term growth',
      ],
    ),

    // Wedding
    const GoalTemplate(
      id: 'wedding_fund',
      name: 'Wedding Fund',
      description: 'Save for your dream wedding',
      suggestedAmount: 20000.0,
      suggestedMonths: 18,
      categoryId: 'wedding',
      defaultPriority: GoalPriority.medium,
      icon: 'favorite',
      color: 0xFFBE185D,
      tips: [
        'Prioritize what matters most to you',
        'Consider DIY elements to save money',
        'Look for deals on venues and vendors',
        'Remember the honeymoon too!',
      ],
    ),
  ];

  /// Get templates by category ID
  static List<GoalTemplate> getByCategoryId(String categoryId) {
    return all.where((template) => template.categoryId == categoryId).toList();
  }

  /// Get popular templates
  static List<GoalTemplate> get popular => [
    all.firstWhere((t) => t.id == 'emergency_fund_3_months'),
    all.firstWhere((t) => t.id == 'vacation_couple'),
    all.firstWhere((t) => t.id == 'home_down_payment_20_percent'),
    all.firstWhere((t) => t.id == 'credit_card_debt'),
  ];

  /// Get quick start templates (3-6 months)
  static List<GoalTemplate> get quickStart => all.where((t) => t.suggestedMonths <= 6).toList();

  /// Get long-term templates (12+ months)
  static List<GoalTemplate> get longTerm => all.where((t) => t.suggestedMonths >= 12).toList();
}