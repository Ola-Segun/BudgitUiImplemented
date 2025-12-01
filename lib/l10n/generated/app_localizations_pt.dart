// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Rastreador de Orçamento';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Escolha seu idioma preferido';

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
  String get appearance => 'Aparência';

  @override
  String get theme => 'Tema';

  @override
  String get themeDescription => 'Escolha o tema do aplicativo';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get currency => 'Moeda';

  @override
  String get currencyDescription => 'Selecione sua moeda';

  @override
  String get dateFormat => 'Formato de Data';

  @override
  String get dateFormatDescription => 'Escolha como as datas são exibidas';

  @override
  String get notifications => 'Notificações';

  @override
  String get pushNotifications => 'Notificações Push';

  @override
  String get pushNotificationsDescription =>
      'Receber notificações do aplicativo';

  @override
  String get budgetAlerts => 'Alertas de Orçamento';

  @override
  String get budgetAlertsDescription =>
      'Notificar quando se aproximar dos limites do orçamento';

  @override
  String get billReminders => 'Lembretes de Contas';

  @override
  String get billRemindersDescription => 'Lembrar sobre contas próximas';

  @override
  String get incomeReminders => 'Lembretes de Renda';

  @override
  String get incomeRemindersDescription => 'Lembrar sobre renda esperada';

  @override
  String get budgetAlertThreshold => 'Limite de Alerta de Orçamento';

  @override
  String budgetAlertThresholdDescription(Object value) {
    return '$value% do orçamento';
  }

  @override
  String get billReminderDays => 'Dias de Lembrete de Contas';

  @override
  String billReminderDaysDescription(Object days) {
    return '$days dias antes do vencimento';
  }

  @override
  String get incomeReminderDays => 'Dias de Lembrete de Renda';

  @override
  String incomeReminderDaysDescription(Object days) {
    return '$days dias antes';
  }

  @override
  String get securityPrivacy => 'Segurança e Privacidade';

  @override
  String get biometricAuth => 'Autenticação Biométrica';

  @override
  String get biometricAuthDescription =>
      'Usar impressão digital ou desbloqueio facial';

  @override
  String get autoBackup => 'Backup Automático';

  @override
  String get autoBackupDescription =>
      'Fazer backup automático de dados na nuvem';

  @override
  String get twoFactorAuth => 'Autenticação de Dois Fatores';

  @override
  String get setupTwoFactorAuth => 'Configurar Autenticação de Dois Fatores';

  @override
  String get privacyMode => 'Modo de Privacidade';

  @override
  String get privacyModeDescription =>
      'Ocultar informações sensíveis como saldos e números de conta';

  @override
  String get gestureActivation => 'Ativação por Gesto';

  @override
  String get gestureActivationDescription =>
      'Ativar modo de privacidade com toque duplo de três dedos';

  @override
  String get dataManagement => 'Gerenciamento de Dados';

  @override
  String get exportData => 'Exportar Dados';

  @override
  String get exportDataDescription => 'Exportar seus dados como arquivo JSON';

  @override
  String get importData => 'Importar Dados';

  @override
  String get importDataDescription => 'Importar dados de arquivo JSON';

  @override
  String get clearAllData => 'Limpar Todos os Dados';

  @override
  String get clearAllDataDescription =>
      'Excluir permanentemente todos os dados do aplicativo';

  @override
  String get quietHours => 'Horas de Silêncio';

  @override
  String get enableQuietHours => 'Habilitar Horas de Silêncio';

  @override
  String get quietHoursDescription =>
      'Silenciar notificações durante horas especificadas';

  @override
  String get startTime => 'Hora de Início';

  @override
  String get endTime => 'Hora de Fim';

  @override
  String get exportOptions => 'Opções de Exportação';

  @override
  String get defaultFormat => 'Formato Padrão';

  @override
  String get defaultFormatDescription =>
      'Escolher formato de exportação padrão';

  @override
  String get scheduledExport => 'Exportação Agendada';

  @override
  String get scheduledExportDescription =>
      'Exportar dados automaticamente em intervalos definidos';

  @override
  String get frequency => 'Frequência';

  @override
  String get frequencyDescription => 'Escolher frequência de exportação';

  @override
  String get daily => 'Diário';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get quarterly => 'Trimestral';

  @override
  String get advancedSettings => 'Configurações Avançadas';

  @override
  String get activityLogging => 'Registro de Atividade';

  @override
  String get activityLoggingDescription =>
      'Rastrear e registrar atividades do usuário para análise e solução de problemas';

  @override
  String get about => 'Sobre';

  @override
  String get appVersion => 'Versão do Aplicativo';

  @override
  String get buildNumber => 'Número da Build';

  @override
  String get terms => 'Termos';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get resetToDefaults => 'Redefinir para padrões';

  @override
  String get resetSettingsConfirm =>
      'Redefinir todas as configurações para valores padrão? Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Redefinir';

  @override
  String get save => 'Salvar';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get confirm => 'Confirmar';

  @override
  String get error => 'Erro';

  @override
  String get success => 'Sucesso';

  @override
  String get loading => 'Carregando...';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get next => 'Próximo';

  @override
  String get previous => 'Anterior';

  @override
  String get continueText => 'Continuar';

  @override
  String get skip => 'Pular';

  @override
  String get done => 'Concluído';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get add => 'Adicionar';

  @override
  String get remove => 'Remover';

  @override
  String get update => 'Atualizar';

  @override
  String get create => 'Criar';

  @override
  String get select => 'Selecionar';

  @override
  String get choose => 'Escolher';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get ascending => 'Crescente';

  @override
  String get descending => 'Decrescente';
}
