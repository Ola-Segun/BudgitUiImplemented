import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_type_theme.freezed.dart';

/// Account type theme configuration for customizable colors and icons
@freezed
class AccountTypeTheme with _$AccountTypeTheme {
  const factory AccountTypeTheme({
    required String accountType, // AccountType enum name
    required String displayName,
    required String iconName, // Material icon name
    required int colorValue, // Color as int value
  }) = _AccountTypeTheme;

  const AccountTypeTheme._();

  /// Get the color from the color value
  Color get color => Color(colorValue);

  /// Get the icon data from the icon name
  IconData get iconData {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'trending_up':
        return Icons.trending_up;
      case 'edit':
        return Icons.edit;
      case 'savings':
        return Icons.savings;
      case 'payments':
        return Icons.payments;
      case 'business':
        return Icons.business;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'local_atm':
        return Icons.local_atm;
      case 'account_circle':
        return Icons.account_circle;
      case 'attach_money':
        return Icons.attach_money;
      case 'euro':
        return Icons.euro;
      case 'currency_pound':
        return Icons.currency_pound;
      case 'currency_yen':
        return Icons.currency_yen;
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      case 'wallet':
        return Icons.wallet;
      case 'credit_score':
        return Icons.credit_score;
      case 'real_estate_agent':
        return Icons.real_estate_agent;
      case 'store':
        return Icons.store;
      case 'work':
        return Icons.work;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'flight':
        return Icons.flight;
      case 'hotel':
        return Icons.hotel;
      case 'beach_access':
        return Icons.beach_access;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'music_note':
        return Icons.music_note;
      case 'movie':
        return Icons.movie;
      case 'games':
        return Icons.games;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'spa':
        return Icons.spa;
      case 'casino':
        return Icons.casino;
      case 'celebration':
        return Icons.celebration;
      case 'cake':
        return Icons.cake;
      case 'pets':
        return Icons.pets;
      case 'nature':
        return Icons.nature;
      case 'forest':
        return Icons.forest;
      case 'park':
        return Icons.park;
      case 'local_florist':
        return Icons.local_florist;
      case 'eco':
        return Icons.eco;
      case 'recycling':
        return Icons.recycling;
      case 'science':
        return Icons.science;
      case 'engineering':
        return Icons.engineering;
      case 'architecture':
        return Icons.architecture;
      case 'construction':
        return Icons.construction;
      case 'handyman':
        return Icons.handyman;
      case 'build':
        return Icons.build;
      case 'precision_manufacturing':
        return Icons.precision_manufacturing;
      case 'agriculture':
        return Icons.agriculture;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'directions_car':
        return Icons.directions_car;
      case 'two_wheeler':
        return Icons.two_wheeler;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'electric_bike':
        return Icons.electric_bike;
      case 'electric_car':
        return Icons.electric_car;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'train':
        return Icons.train;
      case 'tram':
        return Icons.tram;
      case 'subway':
        return Icons.subway;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'directions_boat':
        return Icons.directions_boat;
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'connecting_airports':
        return Icons.connecting_airports;
      case 'local_airport':
        return Icons.local_airport;
      case 'rocket':
        return Icons.rocket;
      case 'satellite':
        return Icons.satellite;
      case 'cell_tower':
        return Icons.cell_tower;
      case 'router':
        return Icons.router;
      case 'computer':
        return Icons.computer;
      case 'phone_android':
        return Icons.phone_android;
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'tablet':
        return Icons.tablet;
      case 'tv':
        return Icons.tv;
      case 'gamepad':
        return Icons.gamepad;
      case 'headphones':
        return Icons.headphones;
      case 'speaker':
        return Icons.speaker;
      case 'camera':
        return Icons.camera;
      case 'videocam':
        return Icons.videocam;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'palette':
        return Icons.palette;
      case 'brush':
        return Icons.brush;
      case 'color_lens':
        return Icons.color_lens;
      case 'format_paint':
        return Icons.format_paint;
      case 'image':
        return Icons.image;
      case 'photo':
        return Icons.photo;
      case 'audiotrack':
        return Icons.audiotrack;
      case 'queue_music':
        return Icons.queue_music;
      case 'library_music':
        return Icons.library_music;
      case 'album':
        return Icons.album;
      case 'mic':
        return Icons.mic;
      case 'mic_off':
        return Icons.mic_off;
      case 'volume_up':
        return Icons.volume_up;
      case 'volume_down':
        return Icons.volume_down;
      case 'volume_mute':
        return Icons.volume_mute;
      case 'volume_off':
        return Icons.volume_off;
      case 'radio':
        return Icons.radio;
      case 'library_books':
        return Icons.library_books;
      case 'menu_book':
        return Icons.menu_book;
      case 'book':
        return Icons.book;
      case 'import_contacts':
        return Icons.import_contacts;
      case 'contacts':
        return Icons.contacts;
      case 'person':
        return Icons.person;
      case 'people':
        return Icons.people;
      case 'group':
        return Icons.group;
      case 'person_add':
        return Icons.person_add;
      case 'how_to_reg':
        return Icons.how_to_reg;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'security':
        return Icons.security;
      case 'verified_user':
        return Icons.verified_user;
      case 'gpp_good':
        return Icons.gpp_good;
      case 'gpp_bad':
        return Icons.gpp_bad;
      case 'privacy_tip':
        return Icons.privacy_tip;
      case 'policy':
        return Icons.policy;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'sanitizer':
        return Icons.sanitizer;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'medical_services':
        return Icons.medical_services;
      case 'healing':
        return Icons.healing;
      case 'vaccines':
        return Icons.vaccines;
      case 'elderly':
        return Icons.elderly;
      case 'child_care':
        return Icons.child_care;
      case 'pregnant_woman':
        return Icons.pregnant_woman;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'wc':
        return Icons.wc;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'dry_cleaning':
        return Icons.dry_cleaning;
      case 'wash':
        return Icons.wash;
      case 'iron':
        return Icons.iron;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'water_damage':
        return Icons.water_damage;
      case 'fire_extinguisher':
        return Icons.fire_extinguisher;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'local_police':
        return Icons.local_police;
      case 'gavel':
        return Icons.gavel;
      case 'balance':
        return Icons.balance;
      case 'scales':
        return Icons.scale;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.account_balance; // Default fallback
    }
  }

  /// Create default themes for each account type
  static Map<String, AccountTypeTheme> get defaultThemes => {
        'bankAccount': const AccountTypeTheme(
          accountType: 'bankAccount',
          displayName: 'Bank Account',
          iconName: 'account_balance',
          colorValue: 0xFF10B981, // Green
        ),
        'creditCard': const AccountTypeTheme(
          accountType: 'creditCard',
          displayName: 'Credit Card',
          iconName: 'credit_card',
          colorValue: 0xFF3B82F6, // Blue
        ),
        'loan': const AccountTypeTheme(
          accountType: 'loan',
          displayName: 'Loan',
          iconName: 'account_balance_wallet',
          colorValue: 0xFFEF4444, // Red
        ),
        'investment': const AccountTypeTheme(
          accountType: 'investment',
          displayName: 'Investment',
          iconName: 'trending_up',
          colorValue: 0xFF8B5CF6, // Purple
        ),
        'manualAccount': const AccountTypeTheme(
          accountType: 'manualAccount',
          displayName: 'Manual Account',
          iconName: 'edit',
          colorValue: 0xFF64748B, // Gray
        ),
      };

  /// Get default theme for a specific account type
  static AccountTypeTheme defaultThemeFor(String accountType) {
    return defaultThemes[accountType] ?? defaultThemes['bankAccount']!;
  }
}