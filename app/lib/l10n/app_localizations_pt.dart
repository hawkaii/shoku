// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle =>
      'O Shoku no seu idioma. Você pode mudar depois em Você.';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get languageSystemHint => 'Segue o idioma do telefone';

  @override
  String get languageTapToContinue => 'Toque em um idioma para continuar';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingStartCooking => 'Começar a cozinhar';

  @override
  String get onboardingShareCta => 'Compartilhe um reel para experimentar';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingOpenJournal => 'Abrir meu diário';

  @override
  String get onboardingIntroTitle => 'Cozinhe uma vez.\nFaça do seu jeito.';

  @override
  String get onboardingIntroBody =>
      'Cada vez que você cozinha, muda algo. O Shoku lembra dessas mudanças para que, na próxima vez, você escolha a versão que combina com hoje.';

  @override
  String get onboardingShareStepLabel => '01 · COMPARTILHE O REEL';

  @override
  String get onboardingShareTitle =>
      'Um toque, direto do app em que você já está.';

  @override
  String get onboardingShareTo => 'Compartilhar com';

  @override
  String get onboardingSaved => 'Salvo como v1 · extraído em 4 segundos';

  @override
  String get onboardingJournalStepLabel => '02 · COZINHE, MUDE';

  @override
  String get onboardingJournalTitle => 'Seu diário lembra as mudanças.';

  @override
  String get onboardingJournalBody =>
      'O modo cozinha guia você. Quando trocar algo, avise. No fim, você tem uma versão — com foto, nota e o que mudou.';

  @override
  String get onboardingAltered => 'alterado';

  @override
  String get onboardingTap => 'TOQUE';

  @override
  String get authSheetTitle => 'Guarde seu diário';

  @override
  String get authSheetBody =>
      'As cozinhas ficam neste telefone até você entrar. Entrar coloca tudo em todos os seus dispositivos.';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Senha';

  @override
  String get authWorking => 'Processando…';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authHaveAccount => 'Já tenho uma conta';

  @override
  String get authCreateAccountLink => 'Criar uma conta';

  @override
  String get authErrorEmailPassword => 'E-mail e uma senha de 6+ caracteres';

  @override
  String get authErrorConfirmEmail =>
      'Confira seu e-mail para confirmar e depois entre';

  @override
  String get authErrorMismatch => 'Esse e-mail e essa senha não combinam';

  @override
  String get authErrorUnconfirmed =>
      'Essa conta ainda não foi confirmada — confira seu e-mail';

  @override
  String get authErrorExists => 'Esse e-mail já tem conta — entre em vez disso';

  @override
  String get authErrorNoConnection => 'Sem conexão';

  @override
  String get authErrorGeneric => 'Não foi possível entrar';

  @override
  String get authNotSignedIn => 'Sem sessão';

  @override
  String get authSignedIn => 'Sessão iniciada';

  @override
  String get authLocalOnly => 'As cozinhas vivem só neste telefone.';

  @override
  String get authSignOut => 'Sair';
}
