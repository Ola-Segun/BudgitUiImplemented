import 'package:flutter/material.dart';

import '../../presentation/notifiers/category_notifier.dart';

/// Service for providing centralized access to category icons and colors
/// Uses CategoryNotifier to access dynamic category data instead of hardcoded mappings
class CategoryIconColorService {
  final CategoryNotifier _categoryNotifier;

  CategoryIconColorService(this._categoryNotifier);

  /// Get the icon for a given category ID
  IconData getIconForCategory(String categoryId) {
    final category = _categoryNotifier.getCategoryById(categoryId);
    if (category != null) {
      return _getIconFromString(category.icon);
    }
    return _getFallbackIcon();
  }

  /// Get the color for a given category ID
  Color getColorForCategory(String categoryId) {
    final category = _categoryNotifier.getCategoryById(categoryId);
    if (category != null) {
      return Color(category.color);
    }
    return _getFallbackColor();
  }

  /// Get both icon and color for a given category ID
  ({IconData icon, Color color}) getIconAndColorForCategory(String categoryId) {
    final category = _categoryNotifier.getCategoryById(categoryId);
    if (category != null) {
      return (
        icon: _getIconFromString(category.icon),
        color: Color(category.color)
      );
    }
    return (
      icon: _getFallbackIcon(),
      color: _getFallbackColor()
    );
  }

  /// Convert icon string to IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      // Food & Dining
      case 'restaurant':
        return Icons.restaurant;
      case 'fastfood':
        return Icons.fastfood;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'local_bar':
        return Icons.local_bar;
      case 'cake':
        return Icons.cake;
      case 'icecream':
        return Icons.icecream;

      // Transportation
      case 'directions_car':
        return Icons.directions_car;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'pedal_bike':
        return Icons.pedal_bike;

      // Shopping
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'store':
        return Icons.store;
      case 'local_mall':
        return Icons.local_mall;
      case 'shopping_basket':
        return Icons.shopping_basket;

      // Entertainment
      case 'movie':
        return Icons.movie;
      case 'music_note':
        return Icons.music_note;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'casino':
        return Icons.casino;
      case 'videogame_asset':
        return Icons.videogame_asset;
      case 'headphones':
        return Icons.headphones;

      // Health & Medical
      case 'local_hospital':
        return Icons.local_hospital;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'medical_services':
        return Icons.medical_services;
      case 'healing':
        return Icons.healing;
      case 'vaccines':
        return Icons.vaccines;

      // Education
      case 'school':
        return Icons.school;
      case 'library_books':
        return Icons.library_books;
      case 'science':
        return Icons.science;
      case 'calculate':
        return Icons.calculate;

      // Home & Living
      case 'home':
        return Icons.home;
      case 'apartment':
        return Icons.apartment;
      case 'cottage':
        return Icons.cottage;
      case 'villa':
        return Icons.villa;
      case 'real_estate_agent':
        return Icons.real_estate_agent;

      // Finance
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      case 'attach_money':
        return Icons.attach_money;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;

      // Travel & Leisure
      case 'beach_access':
        return Icons.beach_access;
      case 'landscape':
        return Icons.landscape;
      case 'location_city':
        return Icons.location_city;
      case 'hotel':
        return Icons.hotel;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'photo_camera':
        return Icons.photo_camera;

      // Utilities
      case 'bolt':
        return Icons.bolt;
      case 'water_drop':
        return Icons.water_drop;
      case 'gas_meter':
        return Icons.gas_meter;
      case 'wifi':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      case 'tv':
        return Icons.tv;
      case 'cleaning_services':
        return Icons.cleaning_services;

      // Personal
      case 'person':
        return Icons.person;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'child_care':
        return Icons.child_care;
      case 'elderly':
        return Icons.elderly;
      case 'self_improvement':
        return Icons.self_improvement;

      // Work & Business
      case 'work':
        return Icons.work;
      case 'business_center':
        return Icons.business_center;
      case 'engineering':
        return Icons.engineering;
      case 'construction':
        return Icons.construction;
      case 'handyman':
        return Icons.handyman;

      // Technology
      case 'computer':
        return Icons.computer;
      case 'phone_android':
        return Icons.phone_android;
      case 'laptop':
        return Icons.laptop;
      case 'smartphone':
        return Icons.smartphone;
      case 'devices':
        return Icons.devices;

      // Other
      case 'category':
        return Icons.category;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'pets':
        return Icons.pets;
      case 'celebration':
        return Icons.celebration;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'redeem':
        return Icons.redeem;
      default:
        return _getFallbackIcon();
    }
  }

  /// Get fallback icon for unknown categories
  IconData _getFallbackIcon() => Icons.category;

  /// Get fallback color for unknown categories
  Color _getFallbackColor() => const Color(0xFF64748B);
}