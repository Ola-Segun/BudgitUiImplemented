// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '预算跟踪器';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择您偏好的语言';

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
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get themeDescription => '选择应用主题';

  @override
  String get system => '系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get currency => '货币';

  @override
  String get currencyDescription => '选择您的货币';

  @override
  String get dateFormat => '日期格式';

  @override
  String get dateFormatDescription => '选择日期的显示方式';

  @override
  String get notifications => '通知';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get pushNotificationsDescription => '接收应用通知';

  @override
  String get budgetAlerts => '预算提醒';

  @override
  String get budgetAlertsDescription => '接近预算限额时通知';

  @override
  String get billReminders => '账单提醒';

  @override
  String get billRemindersDescription => '提醒即将到期的账单';

  @override
  String get incomeReminders => '收入提醒';

  @override
  String get incomeRemindersDescription => '提醒预期收入';

  @override
  String get budgetAlertThreshold => '预算提醒阈值';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '预算的$value%';
  }

  @override
  String get billReminderDays => '账单提醒天数';

  @override
  String billReminderDaysDescription(Object days) {
    return '到期前$days天';
  }

  @override
  String get incomeReminderDays => '收入提醒天数';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '前$days天';
  }

  @override
  String get securityPrivacy => '安全和隐私';

  @override
  String get biometricAuth => '生物识别认证';

  @override
  String get biometricAuthDescription => '使用指纹或面部解锁';

  @override
  String get autoBackup => '自动备份';

  @override
  String get autoBackupDescription => '自动将数据备份到云端';

  @override
  String get twoFactorAuth => '双因素认证';

  @override
  String get setupTwoFactorAuth => '设置双因素认证';

  @override
  String get privacyMode => '隐私模式';

  @override
  String get privacyModeDescription => '隐藏余额和账户号码等敏感信息';

  @override
  String get gestureActivation => '手势激活';

  @override
  String get gestureActivationDescription => '用三指双击激活隐私模式';

  @override
  String get dataManagement => '数据管理';

  @override
  String get exportData => '导出数据';

  @override
  String get exportDataDescription => '将您的数据导出为JSON文件';

  @override
  String get importData => '导入数据';

  @override
  String get importDataDescription => '从JSON文件导入数据';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get clearAllDataDescription => '永久删除应用的所有数据';

  @override
  String get quietHours => '静音时间';

  @override
  String get enableQuietHours => '启用静音时间';

  @override
  String get quietHoursDescription => '在指定时间内静音通知';

  @override
  String get startTime => '开始时间';

  @override
  String get endTime => '结束时间';

  @override
  String get exportOptions => '导出选项';

  @override
  String get defaultFormat => '默认格式';

  @override
  String get defaultFormatDescription => '选择默认导出格式';

  @override
  String get scheduledExport => '定时导出';

  @override
  String get scheduledExportDescription => '按设定间隔自动导出数据';

  @override
  String get frequency => '频率';

  @override
  String get frequencyDescription => '选择导出频率';

  @override
  String get daily => '每日';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String get quarterly => '每季度';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get activityLogging => '活动日志';

  @override
  String get activityLoggingDescription => '跟踪和记录用户活动以进行分析和故障排除';

  @override
  String get about => '关于';

  @override
  String get appVersion => '应用版本';

  @override
  String get buildNumber => '构建号';

  @override
  String get terms => '条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get resetToDefaults => '重置为默认值';

  @override
  String get resetSettingsConfirm => '将所有设置重置为默认值？此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get reset => '重置';

  @override
  String get save => '保存';

  @override
  String get ok => '确定';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get confirm => '确认';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get loading => '加载中...';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get continueText => '继续';

  @override
  String get skip => '跳过';

  @override
  String get done => '完成';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get add => '添加';

  @override
  String get remove => '移除';

  @override
  String get update => '更新';

  @override
  String get create => '创建';

  @override
  String get select => '选择';

  @override
  String get choose => '选择';

  @override
  String get search => '搜索';

  @override
  String get filter => '筛选';

  @override
  String get sort => '排序';

  @override
  String get ascending => '升序';

  @override
  String get descending => '降序';
}
