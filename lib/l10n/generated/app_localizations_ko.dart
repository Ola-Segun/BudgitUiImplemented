// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '예산 추적기';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get languageDescription => '선호하는 언어를 선택하세요';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Português';

  @override
  String get russian => 'Русский';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '한국어';

  @override
  String get chinese => '中文';

  @override
  String get appearance => '외관';

  @override
  String get theme => '테마';

  @override
  String get themeDescription => '앱 테마를 선택하세요';

  @override
  String get system => '시스템';

  @override
  String get light => '밝은';

  @override
  String get dark => '어두운';

  @override
  String get currency => '통화';

  @override
  String get currencyDescription => '통화를 선택하세요';

  @override
  String get dateFormat => '날짜 형식';

  @override
  String get dateFormatDescription => '날짜 표시 방법을 선택하세요';

  @override
  String get notifications => '알림';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get pushNotificationsDescription => '앱 알림 받기';

  @override
  String get budgetAlerts => '예산 알림';

  @override
  String get budgetAlertsDescription => '예산 한계에 가까워지면 알림';

  @override
  String get billReminders => '청구서 알림';

  @override
  String get billRemindersDescription => '다가오는 청구서 알림';

  @override
  String get incomeReminders => '수입 알림';

  @override
  String get incomeRemindersDescription => '예상 수입 알림';

  @override
  String get budgetAlertThreshold => '예산 알림 임계값';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '예산의 $value%';
  }

  @override
  String get billReminderDays => '청구서 알림 일수';

  @override
  String billReminderDaysDescription(Object days) {
    return '마감 $days일 전';
  }

  @override
  String get incomeReminderDays => '수입 알림 일수';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days일 전';
  }

  @override
  String get securityPrivacy => '보안 및 개인정보 보호';

  @override
  String get biometricAuth => '생체 인식 인증';

  @override
  String get biometricAuthDescription => '지문 또는 얼굴 잠금 해제 사용';

  @override
  String get autoBackup => '자동 백업';

  @override
  String get autoBackupDescription => '클라우드에 데이터 자동 백업';

  @override
  String get twoFactorAuth => '2단계 인증';

  @override
  String get setupTwoFactorAuth => '2단계 인증 설정';

  @override
  String get privacyMode => '개인정보 보호 모드';

  @override
  String get privacyModeDescription => '잔액 및 계좌 번호와 같은 민감한 정보 숨기기';

  @override
  String get gestureActivation => '제스처 활성화';

  @override
  String get gestureActivationDescription => '세 손가락 두 번 탭으로 개인정보 보호 모드 활성화';

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get exportData => '데이터 내보내기';

  @override
  String get exportDataDescription => '데이터를 JSON 파일로 내보내기';

  @override
  String get importData => '데이터 가져오기';

  @override
  String get importDataDescription => 'JSON 파일에서 데이터 가져오기';

  @override
  String get clearAllData => '모든 데이터 지우기';

  @override
  String get clearAllDataDescription => '앱의 모든 데이터를 영구적으로 삭제';

  @override
  String get quietHours => '무음 시간';

  @override
  String get enableQuietHours => '무음 시간 활성화';

  @override
  String get quietHoursDescription => '지정된 시간에 알림 음소거';

  @override
  String get startTime => '시작 시간';

  @override
  String get endTime => '종료 시간';

  @override
  String get exportOptions => '내보내기 옵션';

  @override
  String get defaultFormat => '기본 형식';

  @override
  String get defaultFormatDescription => '기본 내보내기 형식 선택';

  @override
  String get scheduledExport => '예약된 내보내기';

  @override
  String get scheduledExportDescription => '설정된 간격으로 데이터 자동 내보내기';

  @override
  String get frequency => '빈도';

  @override
  String get frequencyDescription => '내보내기 빈도 선택';

  @override
  String get daily => '매일';

  @override
  String get weekly => '매주';

  @override
  String get monthly => '매월';

  @override
  String get quarterly => '분기별';

  @override
  String get advancedSettings => '고급 설정';

  @override
  String get activityLogging => '활동 로깅';

  @override
  String get activityLoggingDescription => '분석 및 문제 해결을 위한 사용자 활동 추적 및 기록';

  @override
  String get about => '정보';

  @override
  String get appVersion => '앱 버전';

  @override
  String get buildNumber => '빌드 번호';

  @override
  String get terms => '약관';

  @override
  String get privacyPolicy => '개인정보 보호 정책';

  @override
  String get resetToDefaults => '기본값으로 재설정';

  @override
  String get resetSettingsConfirm =>
      '모든 설정을 기본값으로 재설정하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get cancel => '취소';

  @override
  String get reset => '재설정';

  @override
  String get save => '저장';

  @override
  String get ok => '확인';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get confirm => '확인';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get loading => '로딩 중...';

  @override
  String get retry => '다시 시도';

  @override
  String get close => '닫기';

  @override
  String get back => '뒤로';

  @override
  String get next => '다음';

  @override
  String get previous => '이전';

  @override
  String get continueText => '계속';

  @override
  String get skip => '건너뛰기';

  @override
  String get done => '완료';

  @override
  String get edit => '편집';

  @override
  String get delete => '삭제';

  @override
  String get add => '추가';

  @override
  String get remove => '제거';

  @override
  String get update => '업데이트';

  @override
  String get create => '생성';

  @override
  String get select => '선택';

  @override
  String get choose => '선택';

  @override
  String get search => '검색';

  @override
  String get filter => '필터';

  @override
  String get sort => '정렬';

  @override
  String get ascending => '오름차순';

  @override
  String get descending => '내림차순';
}
