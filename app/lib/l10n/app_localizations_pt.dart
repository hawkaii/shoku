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

  @override
  String get tabJournal => 'Diário';

  @override
  String get tabCookbook => 'Receitas';

  @override
  String get tabFridge => 'Geladeira';

  @override
  String get tabWall => 'Mural';

  @override
  String get tabYou => 'Você';

  @override
  String journalKitchenTitle(String month) {
    return 'Cozinha de $month';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pratos',
      one: '1 prato',
      zero: 'Sem pratos ainda',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count melhorias',
      one: '1 melhoria',
      zero: 'sem melhorias',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cozimentos',
      one: 'cozimento',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'melhorias',
      one: 'melhoria',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
      zero: 'sem entradas',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'no balcão';

  @override
  String get journalCookLog => 'registro de cozimentos';

  @override
  String get journalCook => 'Cozinhar';

  @override
  String get journalFirstPage => 'Sua primeira página';

  @override
  String get journalFirstPageBody =>
      'Registre um cozimento — uma foto, como foi e uma coisa que você mudou. Isso vira a v1.';

  @override
  String get journalStartJournal => 'Começar o diário →';

  @override
  String get journalNoDishes =>
      'Ainda não há pratos — importe um reel para começar';

  @override
  String get journalOpening => 'Abrindo seu diário';

  @override
  String get journalErrorTitle => 'Não foi possível abrir seu diário';

  @override
  String get journalErrorBody =>
      'Os cozimentos salvos ainda estão neste telefone.';

  @override
  String get journalTryAgain => 'Tentar de novo';

  @override
  String get journalSaveRecipe => 'Salvar uma receita';

  @override
  String get cookbookTitle => 'Receitas';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cozinhados',
      one: '1 cozinhado',
      zero: 'nada cozinhado',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'Para cozinhar';

  @override
  String get cookbookCooked => 'Cozinhados';

  @override
  String get cookbookNothingToCook => 'Nada esperando para cozinhar.';

  @override
  String get cookbookNoCooksYet =>
      'Ainda não há cozimentos. Escolha algo em Para cozinhar.';

  @override
  String get cookbookNeverCooked => 'nunca cozinhado';

  @override
  String cookbookLastCooked(String outcome) {
    return 'última: $outcome';
  }

  @override
  String get badgeToCook => 'PARA COZINHAR';

  @override
  String get badgeCooked => 'COZINHADO';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'COZINHADO $count×',
      one: 'COZINHADO $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'ASSINATURA';

  @override
  String get outcomeNailedIt => 'Acertou em cheio';

  @override
  String get outcomeGood => 'Bom';

  @override
  String get outcomeNeedsWork => 'Precisa melhorar';

  @override
  String get moodQuick => 'rápida';

  @override
  String get moodProject => 'projeto';

  @override
  String get moodComfort => 'reconfortante';

  @override
  String minutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get labelSample => 'Exemplo';

  @override
  String get addSheetTitle => 'Importar uma receita';

  @override
  String get addSheetSubtitle =>
      'Um reel vira um prato que você pode cozinhar e versionar.';

  @override
  String get addSheetLinkHint => 'Cole um link do Instagram ou YouTube';

  @override
  String get addSheetShareOption => 'Compartilhar de outro app';

  @override
  String get addSheetShareHint => 'Instagram → compartilhar → Shoku';

  @override
  String get addSheetScanOption => 'Escanear um código de barras';

  @override
  String get addSheetScanHint => 'Adicione direto à sua geladeira';

  @override
  String get addSheetBackendNote =>
      'A extração roda no servidor — esta versão é só a interface.';

  @override
  String get importHeadline => 'Importando um reel';

  @override
  String get importQueued => 'Na fila';

  @override
  String get importWaking => 'Acordando a cozinha…';

  @override
  String get importWaitingHint =>
      'O primeiro depois de uma pausa leva um minuto';

  @override
  String get importReadingReel => 'Lendo o reel';

  @override
  String get importReadingAudio => 'Lendo o áudio';

  @override
  String get importWritingRecipe => 'Escrevendo a receita';

  @override
  String get importWatchingVideo => 'Assistindo ao vídeo';

  @override
  String get importReadingCaption => 'Lendo a legenda';

  @override
  String get importReady => 'Pronto';

  @override
  String get importFailedShort => 'Não foi possível ler este';

  @override
  String get reasonUnsupportedUrl =>
      'Esse link não é um reel ou vídeo que possamos ler';

  @override
  String get reasonSourceBlocked =>
      'O YouTube está bloqueando nosso servidor agora — tente mais tarde ou cole a receita';

  @override
  String get reasonTimeout => 'Isso demorou demais — tente de novo';

  @override
  String get reasonWorkerUnavailable =>
      'A cozinha não acordou — tente de novo em um minuto';

  @override
  String get reasonTimedOut =>
      'Ainda lendo — isso pode levar alguns minutos. Você pode sair e o prato estará aqui quando estiver pronto';

  @override
  String get reasonGone =>
      'Essa importação não está mais no servidor — tente o link de novo';

  @override
  String get reasonInvalidRecipe => 'Não encontramos uma receita nesse';

  @override
  String get reasonNoAudio => 'Esse vídeo não tem nada para ouvir';

  @override
  String get reasonNoText =>
      'Esse reel não tem legenda nem fala que possamos ler';

  @override
  String get reasonNoRecipe => 'Esse vídeo não mostra uma receita';

  @override
  String get reasonVisionFailed =>
      'Não conseguimos ler esse vídeo — cole a receita';

  @override
  String get reasonTakenDown => 'Essa receita foi removida';

  @override
  String get reasonUnknown => 'Não foi possível ler este — cole a receita';
}
