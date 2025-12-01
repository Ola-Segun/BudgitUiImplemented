// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => '予算トラッカー';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get languageDescription => '希望する言語を選択してください';

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
  String get appearance => '外観';

  @override
  String get theme => 'テーマ';

  @override
  String get themeDescription => 'アプリのテーマを選択してください';

  @override
  String get system => 'システム';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get currency => '通貨';

  @override
  String get currencyDescription => '通貨を選択してください';

  @override
  String get dateFormat => '日付形式';

  @override
  String get dateFormatDescription => '日付の表示方法を選択してください';

  @override
  String get notifications => '通知';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get pushNotificationsDescription => 'アプリの通知を受け取る';

  @override
  String get budgetAlerts => '予算アラート';

  @override
  String get budgetAlertsDescription => '予算制限に近づいたら通知';

  @override
  String get billReminders => '請求リマインダー';

  @override
  String get billRemindersDescription => '今後の請求をリマインド';

  @override
  String get incomeReminders => '収入リマインダー';

  @override
  String get incomeRemindersDescription => '予想される収入をリマインド';

  @override
  String get budgetAlertThreshold => '予算アラートしきい値';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '予算の$value%';
  }

  @override
  String get billReminderDays => '請求リマインダー日数';

  @override
  String billReminderDaysDescription(Object days) {
    return '期日$days日前';
  }

  @override
  String get incomeReminderDays => '収入リマインダー日数';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days日前';
  }

  @override
  String get securityPrivacy => 'セキュリティとプライバシー';

  @override
  String get biometricAuth => '生体認証';

  @override
  String get biometricAuthDescription => '指紋または顔認証を使用';

  @override
  String get autoBackup => '自動バックアップ';

  @override
  String get autoBackupDescription => 'クラウドにデータを自動バックアップ';

  @override
  String get twoFactorAuth => '二要素認証';

  @override
  String get setupTwoFactorAuth => '二要素認証を設定';

  @override
  String get privacyMode => 'プライバシーモード';

  @override
  String get privacyModeDescription => '残高や口座番号などの機密情報を非表示';

  @override
  String get gestureActivation => 'ジェスチャーアクティベーション';

  @override
  String get gestureActivationDescription => '3本指のダブルタップでプライバシーモードを有効化';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get exportData => 'データのエクスポート';

  @override
  String get exportDataDescription => 'データをJSONファイルとしてエクスポート';

  @override
  String get importData => 'データのインポート';

  @override
  String get importDataDescription => 'JSONファイルからデータをインポート';

  @override
  String get clearAllData => 'すべてのデータをクリア';

  @override
  String get clearAllDataDescription => 'アプリのすべてのデータを完全に削除';

  @override
  String get quietHours => 'サイレント時間';

  @override
  String get enableQuietHours => 'サイレント時間を有効化';

  @override
  String get quietHoursDescription => '指定された時間に通知をミュート';

  @override
  String get startTime => '開始時間';

  @override
  String get endTime => '終了時間';

  @override
  String get exportOptions => 'エクスポートオプション';

  @override
  String get defaultFormat => 'デフォルト形式';

  @override
  String get defaultFormatDescription => 'デフォルトのエクスポート形式を選択';

  @override
  String get scheduledExport => 'スケジュールされたエクスポート';

  @override
  String get scheduledExportDescription => '設定された間隔でデータを自動エクスポート';

  @override
  String get frequency => '頻度';

  @override
  String get frequencyDescription => 'エクスポート頻度を選択';

  @override
  String get daily => '毎日';

  @override
  String get weekly => '毎週';

  @override
  String get monthly => '毎月';

  @override
  String get quarterly => '四半期ごと';

  @override
  String get advancedSettings => '詳細設定';

  @override
  String get activityLogging => 'アクティビティログ';

  @override
  String get activityLoggingDescription =>
      '分析とトラブルシューティングのためにユーザーアクティビティを追跡・記録';

  @override
  String get about => 'について';

  @override
  String get appVersion => 'アプリバージョン';

  @override
  String get buildNumber => 'ビルド番号';

  @override
  String get terms => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get resetToDefaults => 'デフォルトにリセット';

  @override
  String get resetSettingsConfirm => 'すべての設定をデフォルト値にリセットしますか？この操作は元に戻せません。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get reset => 'リセット';

  @override
  String get save => '保存';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get confirm => '確認';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get loading => '読み込み中...';

  @override
  String get retry => '再試行';

  @override
  String get close => '閉じる';

  @override
  String get back => '戻る';

  @override
  String get next => '次へ';

  @override
  String get previous => '前へ';

  @override
  String get continueText => '続ける';

  @override
  String get skip => 'スキップ';

  @override
  String get done => '完了';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get add => '追加';

  @override
  String get remove => '削除';

  @override
  String get update => '更新';

  @override
  String get create => '作成';

  @override
  String get select => '選択';

  @override
  String get choose => '選択';

  @override
  String get search => '検索';

  @override
  String get filter => 'フィルター';

  @override
  String get sort => '並べ替え';

  @override
  String get ascending => '昇順';

  @override
  String get descending => '降順';
}
