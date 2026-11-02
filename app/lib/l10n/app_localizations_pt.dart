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
      'Os cozimentos ficam neste telefone até você entrar. Entrar coloca tudo em todos os seus dispositivos.';

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
  String get authLocalOnly => 'Os cozimentos vivem só neste telefone.';

  @override
  String get authSignOut => 'Sair';

  @override
  String get tabJournal => 'Diário';

  @override
  String get tabCookbook => 'Livro de receitas';

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
  String get cookbookTitle => 'Livro de receitas';

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
  String get reasonInvalidRecipe => 'Não encontramos uma receita nesse vídeo';

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

  @override
  String get pantryTitle => 'Geladeira';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'sem itens',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buscar $count itens',
      one: 'Buscar 1 item',
      zero: 'Busque na sua geladeira',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
      zero: 'nada selecionado',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Editar';

  @override
  String get pantryShelfLabel => 'cozinhe com sua geladeira';

  @override
  String get pantryToBuy => 'para comprar';

  @override
  String get pantryInFridge => 'na geladeira';

  @override
  String get pantryEmpty =>
      'Ainda não há nada na geladeira. Fotografe um recibo ou me diga o que tem nela.';

  @override
  String get pantryAddItems => 'Adicionar itens';

  @override
  String get pantryHowMuch => 'Quanto?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'Cancelar';

  @override
  String get pantryDone => 'Concluir';

  @override
  String get pantryDelete => 'Excluir';

  @override
  String get pantrySelectItems => 'Selecionar itens';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $countString',
      one: 'Excluir 1',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens excluídos',
      one: '1 item excluído',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'definir quantidade';

  @override
  String pantryLessItem(String name) {
    return 'Menos $name';
  }

  @override
  String pantryMoreItem(String name) {
    return 'Mais $name';
  }

  @override
  String get shelfEmpty =>
      'Nada para sugerir ainda — adicione alguns itens e eu cruzo murais e seus próprios pratos.';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count para comprar',
      one: '+1 para comprar',
    );
    return '$_temp0';
  }

  @override
  String shelfScore(int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$haveString de $totalString';
  }

  @override
  String get pantryEditTitle => 'Editar item';

  @override
  String get pantryNameLabel => 'nome';

  @override
  String get pantryAmountLabel => 'quantidade';

  @override
  String get pantryAmountHelp =>
      'Deixe em branco se você sabe que tem, mas não quanto.';

  @override
  String pantrySavedAs(String amount) {
    return 'Salvo como $amount';
  }

  @override
  String get pantrySave => 'Salvar';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'colher (sopa)';

  @override
  String get unitTsp => 'colher (chá)';

  @override
  String get unitPcs => 'un.';

  @override
  String get unitBunch => 'maço';

  @override
  String get unitPack => 'pacote';

  @override
  String get pantryAddTitle => 'Adicionar à geladeira';

  @override
  String get pantryAddIntro =>
      'Fotografe um recibo, diga o que há na cozinha ou digite. Nada entra na geladeira até você ver a lista.';

  @override
  String get pantryDoorPhoto => 'Foto';

  @override
  String get pantryDoorVoice => 'Voz';

  @override
  String get pantryDoorType => 'Digitar';

  @override
  String get pantryReview => 'Revisar';

  @override
  String get pantryToAdd => 'para adicionar';

  @override
  String get pantryAiReading => 'Lendo o resto…';

  @override
  String get pantryAmountUnknown => 'quantidade desconhecida';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não deu para ler ($count)',
      one: 'Não deu para ler (1)',
    );
    return '$_temp0';
  }

  @override
  String pantryConfirmAdd(int checked, int total) {
    final intl.NumberFormat checkedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String checkedString = checkedNumberFormat.format(checked);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Adicionar $checkedString de $totalString',
      one: 'Adicionar $checkedString de 1',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline =>
      'O leitor de recibos precisa de conexão. Digite ou fale.';

  @override
  String get pantryNoteUnreadable => 'Nada legível nessa foto — digite.';

  @override
  String get pantryCapReached => 'Leituras de IA esgotadas hoje — digite.';

  @override
  String get pantryPhotoButton => 'Foto ou captura';

  @override
  String get pantryPhotoHint =>
      'Fotografe um recibo e o leitor digita. Nada entra na geladeira até você ver a lista.';

  @override
  String get pantryReadingReceipt => 'Lendo o recibo…';

  @override
  String get pantryBackTooltip => 'Voltar para a geladeira';

  @override
  String get pantryTypeHint => '2 kg de arroz, um por linha';

  @override
  String get pantryVoiceHint => 'Segure o microfone e diga o que há na cozinha';

  @override
  String get pantryWhatIsIt => 'O que é?';

  @override
  String get pantryVisionTitle => 'O leitor usa o modelo da Meta';

  @override
  String get pantryVisionBody =>
      'A foto é enviada ao modelo da Meta para ser lida. Ela é usada só nessa chamada e não fica guardada. As linhas vão para a revisão abaixo, onde você pode corrigir tudo antes de entrarem na geladeira.';

  @override
  String get pantryGotIt => 'Entendi';

  @override
  String get pantryScreenshotOrPhoto => 'Captura ou foto';

  @override
  String get pantryCamera => 'Câmera';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens na geladeira',
      one: '1 item na geladeira',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'Sem prato';

  @override
  String get botDishFallback => 'Prato';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Cozinhando · passo $stepString de $totalString';
  }

  @override
  String get botTalkAbout => 'Falar sobre…';

  @override
  String get botThisDish => 'Este prato';

  @override
  String get botNoDishKitchen => 'Sem prato — a cozinha';

  @override
  String get botOpen => 'Abrir';

  @override
  String get botMinimise => 'Minimizar';

  @override
  String get botNewChat => 'Nova conversa';

  @override
  String get botThinking => 'PENSANDO';

  @override
  String get botOfflineLine =>
      'O assistente precisa de conexão. Nada é respondido offline.';

  @override
  String get botAskKitchen => 'Pergunte sobre a cozinha…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Pergunte sobre este prato · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'Sem perguntas por hoje';

  @override
  String get botNoConnection => 'Sem conexão';

  @override
  String get botCapNotice =>
      'Você usou as perguntas de hoje. Elas voltam amanhã.';

  @override
  String get botOfflineNotice =>
      'O assistente precisa de uma conexão. Nada aqui é respondido offline.';

  @override
  String botWhichDish(String choices) {
    return 'Qual prato você quis dizer? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens na geladeira.',
      one: '1 item na geladeira.',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'Não posso mudar seu diário daqui. Abra o prato (ou o menu ⋯) e o fluxo real fará isso.';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count faltantes',
      one: 'Adicionar 1 faltante',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens adicionados à sua lista',
      one: '1 item adicionado à sua lista',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'Não é este';

  @override
  String get botAddToFridgeQuestion => 'Adicionar à geladeira?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count itens à geladeira',
      one: 'Adicionar 1 item à geladeira',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => 'quantidade?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $haveString de $totalString';
  }

  @override
  String get botStarterFridge => 'O que há na sua geladeira?';

  @override
  String get botStarterWall => 'Mostre algo do Mural';

  @override
  String get botStarterPhoto => 'Tenho uma foto de um prato';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você tem $count coisas na geladeira. Jantar com elas?',
      one: 'Você tem 1 coisa na geladeira. Jantar com ela?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar anteriores ($count)',
      one: 'Mostrar anterior (1)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'sobre o passo $stepString';
  }

  @override
  String get chatAskHint => 'Pergunte, ou segure o microfone';

  @override
  String get chatResolveChange => 'Resolva a mudança acima';

  @override
  String get chatAsk => 'Perguntar';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString começa aqui';
  }

  @override
  String chatApplied(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'V$versionString · APLICADO';
  }

  @override
  String chatOpenVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Abrir v$versionString';
  }

  @override
  String get chatUndo => 'Desfazer';

  @override
  String get chatRecipeChange => 'MUDANÇA NA RECEITA';

  @override
  String chatVersionArrow(int from, int to) {
    final intl.NumberFormat fromNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String toString = toNumberFormat.format(to);

    return 'v$fromString → v$toString';
  }

  @override
  String chatMoreEdits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count mais',
      one: '+1 mais',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Cria v$versionString — desta mensagem';
  }

  @override
  String get chatRecompute => 'Recalcular';

  @override
  String get chatDiscard => 'Descartar';

  @override
  String get chatNotApplied => 'NÃO APLICADO';

  @override
  String get chatNothingChanged => 'Nada mudou na sua receita.';

  @override
  String get chatTryAgain => 'Tentar de novo';

  @override
  String get chatApplying => 'Aplicando…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Aplicar como v$versionString';
  }
}
