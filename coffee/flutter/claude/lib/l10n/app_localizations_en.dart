// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coffee Companion';

  @override
  String get today => 'Today';

  @override
  String get beans => 'Beans';

  @override
  String get brew => 'Brew';

  @override
  String get equipment => 'Equipment';

  @override
  String get more => 'More';

  @override
  String get water => 'Water';

  @override
  String get care => 'Care';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ready => 'Ready';

  @override
  String restingDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Resting, $n days left',
      one: 'Resting, 1 day left',
    );
    return '$_temp0';
  }

  @override
  String get tooOld => 'Too old';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonBody =>
      'This part of the app arrives in a later release.';

  @override
  String get retry => 'Try again';

  @override
  String get noImage => 'No image';

  @override
  String get defaultWithoutSource => 'Default without source';

  @override
  String sourceLabel(String source, String date) {
    return 'Source: $source (retrieved $date)';
  }

  @override
  String get bannerInfo => 'Info';

  @override
  String get bannerWarning => 'Warning';

  @override
  String get bannerError => 'Error';

  @override
  String get styleGuide => 'Style guide';

  @override
  String get navigation => 'Navigation';

  @override
  String get add => 'Add';

  @override
  String get back => 'Back';

  @override
  String get startFilter => 'Start filter';

  @override
  String get grinders => 'Grinders';

  @override
  String get machines => 'Machines';

  @override
  String get beanDetail => 'Bean detail';

  @override
  String get beanForm => 'Add bean';

  @override
  String get brewForm => 'Log a brew';

  @override
  String get brewDetail => 'Brew detail';

  @override
  String get filterGuided => 'Guided filter';

  @override
  String get grinderForm => 'Add grinder';

  @override
  String get machineForm => 'Add machine';

  @override
  String get waterForm => 'Add water profile';

  @override
  String get openBeanDetail => 'Open a bean';

  @override
  String get openBrewDetail => 'Open a brew';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptyBody => 'Add your first bean.';

  @override
  String get addBean => 'Add bean';

  @override
  String get loading => 'Loading';

  @override
  String get errorBody => 'Something went wrong.';

  @override
  String get stateDefault => 'Default';

  @override
  String get stateHover => 'Hover';

  @override
  String get statePressed => 'Pressed';

  @override
  String get stateFocus => 'Focus';

  @override
  String get stateDisabled => 'Disabled';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateSelected => 'Selected';

  @override
  String get stateEmpty => 'Empty';

  @override
  String get stateError => 'Error';

  @override
  String get sgIntro => 'Every component in every state, in the current theme.';

  @override
  String get sgColors => 'Colours';

  @override
  String get sgButtons => 'Buttons';

  @override
  String get sgCards => 'Cards';

  @override
  String get sgFields => 'Fields';

  @override
  String get sgChips => 'Chips';

  @override
  String get sgBanners => 'Banners';

  @override
  String get sgOther => 'Other';

  @override
  String get fieldLabel => 'Label';

  @override
  String get fieldHint => 'Value';

  @override
  String get fieldUnit => 'g';

  @override
  String get fieldErrorText => 'Enter a value between 1 and 100';

  @override
  String get bannerInfoText => 'Your beans are resting.';

  @override
  String get bannerWarningText => 'Order beans soon.';

  @override
  String get bannerErrorText => 'Could not save the brew.';

  @override
  String get warningCareAction => 'Open care';

  @override
  String get warningWaterAction => 'Open water profile';

  @override
  String get bannerAction => 'Show';

  @override
  String get cardTitle => 'Card title';

  @override
  String get cardBody => 'Card content in paper look.';

  @override
  String get ruleDemoKey => 'Rule demo';

  @override
  String get aboutSources => 'About and sources';

  @override
  String get fieldName => 'Name';

  @override
  String get edit => 'Edit';

  @override
  String deleteNamed(String name) {
    return 'Delete $name';
  }

  @override
  String get enterNumber => 'Enter a number';

  @override
  String rangeError(String min, String max) {
    return 'Enter a value between $min and $max';
  }

  @override
  String get nameRequired => 'Enter a name';

  @override
  String tooLong(int n) {
    return 'Use at most $n characters';
  }

  @override
  String get unitG => 'g';

  @override
  String get unitS => 's';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitPpm => 'ppm';

  @override
  String get unitMgL => 'mg/L';

  @override
  String get unitFh => '°fH';

  @override
  String get unitDh => '°dH';

  @override
  String gramsValue(String value) {
    return '$value g';
  }

  @override
  String secondsValue(String value) {
    return '$value s';
  }

  @override
  String celsiusValue(String value) {
    return '$value °C';
  }

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get grinderAdd => 'Add grinder';

  @override
  String get grinderEditTitle => 'Edit grinder';

  @override
  String get grindersEmptyTitle => 'No grinder yet';

  @override
  String get grindersEmptyBody => 'Add your grinder with scale and dead space.';

  @override
  String get scaleMin => 'Scale minimum';

  @override
  String get scaleMax => 'Scale maximum';

  @override
  String get scaleStep => 'Scale step';

  @override
  String get stepPositive => 'Step must be greater than 0';

  @override
  String get scaleMaxAboveMin => 'Maximum must be greater than the minimum';

  @override
  String get finerDirection => 'Finer grind direction';

  @override
  String get finerDown => 'Down (lower is finer)';

  @override
  String get finerUp => 'Up (higher is finer)';

  @override
  String get deadSpace => 'Dead space';

  @override
  String get checkGrindSetting => 'Check grind setting';

  @override
  String grindSettingNotOnScale(String step) {
    return 'Value is not on the grinder\'s scale (step $step)';
  }

  @override
  String get machineAdd => 'Add machine';

  @override
  String get machineEditTitle => 'Edit machine';

  @override
  String get machinesEmptyTitle => 'No machine yet';

  @override
  String get machinesEmptyBody => 'Add your machine with its settings.';

  @override
  String get brewTemp => 'Brew temperature';

  @override
  String get preinfusion => 'Pre-infusion';

  @override
  String get pressureProfile => 'Pressure profile';

  @override
  String get defaultWater => 'Default water profile';

  @override
  String get noDefaultWater => 'None';

  @override
  String get waterAdd => 'Add water profile';

  @override
  String get waterEditTitle => 'Edit water profile';

  @override
  String get waterDetail => 'Water profile';

  @override
  String get waterEmptyTitle => 'No water profile yet';

  @override
  String get waterEmptyBody => 'Enter your water\'s hardness.';

  @override
  String get waterInScaRange => 'In SCA range';

  @override
  String get waterOutsideSca => 'Outside SCA';

  @override
  String waterCheckFirst(String parameter, String value, String range) {
    return 'Check water first: $parameter $value, SCA $range';
  }

  @override
  String measuredOf(int n, int total) {
    return '$n of $total measured';
  }

  @override
  String get notMeasured => 'not measured';

  @override
  String scaRange(String range) {
    return 'SCA $range';
  }

  @override
  String get paramTds => 'TDS';

  @override
  String get paramHardness => 'Hardness';

  @override
  String get paramAlkalinity => 'Alkalinity';

  @override
  String get paramPh => 'pH';

  @override
  String get paramSodium => 'Sodium';

  @override
  String get paramChlorine => 'Chlorine';

  @override
  String get hardnessUnitLabel => 'Hardness unit';

  @override
  String get hardnessRequired => 'Hardness (required)';

  @override
  String get exportData => 'Export';

  @override
  String get importData => 'Import';

  @override
  String get beansEmptyTitle => 'No beans yet';

  @override
  String get noPack => 'No pack';

  @override
  String get beanEditTitle => 'Edit bean';

  @override
  String get packForm => 'Add pack';

  @override
  String get packEditTitle => 'Edit pack';

  @override
  String get fieldRoaster => 'Roaster';

  @override
  String get fieldRoastLevel => 'Roast level';

  @override
  String get fieldKind => 'Kind';

  @override
  String get fieldLeadTime => 'Lead time';

  @override
  String get fieldMinStock => 'Minimum stock (optional)';

  @override
  String get fieldRoastDate => 'Roast date';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get firstPack => 'First pack';

  @override
  String get unitDays => 'days';

  @override
  String get roastLight => 'Light';

  @override
  String get roastMedium => 'Medium';

  @override
  String get roastMediumDark => 'Medium dark';

  @override
  String get roastDark => 'Dark';

  @override
  String get kindEspressoBlend => 'Espresso blend';

  @override
  String get kindFilter => 'Filter';

  @override
  String get kindAllround => 'All-round';

  @override
  String get dateRequired => 'Enter a date';

  @override
  String dateInvalid(String example) {
    return 'Use a date like $example';
  }

  @override
  String get dateFuture => 'The date must not be in the future';

  @override
  String get pickDate => 'Pick a date';

  @override
  String roastedOn(String date) {
    return 'Roasted $date';
  }

  @override
  String packSizes(String remaining, String size) {
    return '$remaining of $size';
  }

  @override
  String get openPack => 'Open';

  @override
  String openedOn(String date) {
    return 'Opened on $date';
  }

  @override
  String get tileRemaining => 'Remaining';

  @override
  String get tileReadyDate => 'Ready date';

  @override
  String get packsTitle => 'Packs';

  @override
  String get noPacksYet => 'No packs yet.';

  @override
  String get beanNotFound => 'Bean not found';

  @override
  String get editPack => 'Edit pack';

  @override
  String deletePackNamed(String date) {
    return 'Delete pack roasted $date';
  }

  @override
  String kindAndRoast(String kind, String roast) {
    return '$kind, $roast';
  }

  @override
  String beanImageLabel(String name) {
    return 'Image of $name';
  }

  @override
  String get brewsEmptyTitle => 'No brews yet';

  @override
  String get brewsEmptyBody => 'Log your first shot.';

  @override
  String get methodEspresso => 'Espresso';

  @override
  String get methodV60 => 'V60';

  @override
  String get methodChemex => 'Chemex';

  @override
  String get methodKalita => 'Kalita';

  @override
  String get methodAeropress => 'AeroPress';

  @override
  String get methodBatch => 'Batch';

  @override
  String get tasteSour => 'Sour';

  @override
  String get tasteBitter => 'Bitter';

  @override
  String get tasteWeak => 'Weak';

  @override
  String get tasteBalanced => 'Balanced';

  @override
  String get brewMethod => 'Method';

  @override
  String get brewMachine => 'Machine';

  @override
  String get brewGrinder => 'Grinder';

  @override
  String get brewPack => 'Pack';

  @override
  String get brewGrind => 'Grind setting';

  @override
  String get brewDose => 'Dose';

  @override
  String get brewPurge => 'Purge amount';

  @override
  String get brewYield => 'Yield';

  @override
  String get brewShotTime => 'Shot time (s)';

  @override
  String get brewTime => 'Shot time';

  @override
  String get brewRatio => 'Ratio';

  @override
  String get brewWater => 'Water profile';

  @override
  String get brewTaste => 'Taste';

  @override
  String get brewRating => 'Rating';

  @override
  String get brewNote => 'Note';

  @override
  String get brewStarted => 'Started';

  @override
  String get grindLower => 'Lower grind setting';

  @override
  String get grindRaise => 'Raise grind setting';

  @override
  String get timerStart => 'Start timer';

  @override
  String get timerStop => 'Stop timer';

  @override
  String timerElapsed(String time) {
    return 'Elapsed $time';
  }

  @override
  String ratingStars(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String purgeBeanChange(String grams) {
    return 'Grind and discard $grams first (bean change)';
  }

  @override
  String purgeIdle(String grams) {
    return 'Grind and discard $grams first (grinder idle)';
  }

  @override
  String get needGrinder => 'Add a grinder first';

  @override
  String get needMachine => 'Add a machine first';

  @override
  String get needPack => 'Add a pack first';

  @override
  String notEnoughBeans(String n) {
    return 'Not enough beans in the pack ($n g left)';
  }

  @override
  String brewPackOption(String bean, String date, String grams) {
    return '$bean, roasted $date, $grams left';
  }

  @override
  String get brewSelectionMissing => 'Choose machine, grinder and pack';

  @override
  String get brewNotFound => 'Brew not found';

  @override
  String get recTitle => 'Recommendation';

  @override
  String get recReasonTitle => 'Reason';

  @override
  String get recSourceTitle => 'Source';

  @override
  String recGrind(String setting) {
    return 'Set grind to $setting';
  }

  @override
  String get recNoChange => 'No change';

  @override
  String recScaleEnd(String setting) {
    return 'Grind stays at $setting';
  }

  @override
  String get recScaleEndHint => 'End of scale';

  @override
  String recRest(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Let the pack rest ($n days left)',
      one: 'Let the pack rest (1 day left)',
    );
    return '$_temp0';
  }

  @override
  String get recNoWater => 'Enter water values';

  @override
  String get reasonNoWater =>
      'No water profile is set, so the water cannot be checked.';

  @override
  String get reasonWaterOutside =>
      'Water outside the SCA range comes before any other change.';

  @override
  String get reasonPackResting =>
      'The pack has not finished resting for espresso yet.';

  @override
  String reasonTimeTooShort(String time, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Shot time $time s is below the target window: grind finer by $_temp0.';
  }

  @override
  String reasonTimeTooLong(String time, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Shot time $time s is above the target window: grind coarser by $_temp0.';
  }

  @override
  String reasonTasteSour(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Sour taste in the target window: grind finer by $_temp0.';
  }

  @override
  String reasonTasteWeak(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Weak taste in the target window: grind finer by $_temp0.';
  }

  @override
  String reasonTasteBitter(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Bitter taste in the target window: grind coarser by $_temp0.';
  }

  @override
  String get reasonBalanced =>
      'Balanced and inside the target window: keep everything.';

  @override
  String get reasonScaleEnd =>
      'The grinder is at the end of its scale; no further change is possible.';

  @override
  String get nextTry => 'Next try';

  @override
  String get filterMethodNote => 'V60 scheme';

  @override
  String get filterNoPack => 'No pack is ready yet';

  @override
  String filterPackBackup(String pack) {
    return '$pack (backup)';
  }

  @override
  String get filterRatio => 'Ratio';

  @override
  String filterWaterTotal(String n) {
    return 'Total water: $n g';
  }

  @override
  String get filterStart => 'Start';

  @override
  String get filterNext => 'Next';

  @override
  String filterPourTo(String n) {
    return 'Pour to $n g';
  }

  @override
  String filterAtTime(String time) {
    return 'at $time';
  }

  @override
  String get filterStepBloom => 'Bloom';

  @override
  String filterStepPour(String n) {
    return 'Pour $n';
  }

  @override
  String get filterFinishTitle => 'Drawdown';

  @override
  String get filterDrawdownField => 'Drawdown time (s)';

  @override
  String filterTimerLabel(String time) {
    return 'Timer $time';
  }

  @override
  String get brewDrawdown => 'Drawdown time';

  @override
  String get brewWaterTotal => 'Total water';

  @override
  String get brewBloom => 'Bloom';

  @override
  String get brewPours => 'Pours';

  @override
  String get reasonPackRestingFilter =>
      'The pack has not finished resting for filter yet.';

  @override
  String reasonDrawdownTooShort(String time, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Drawdown $time s is below the target window: grind finer by $_temp0.';
  }

  @override
  String reasonDrawdownTooLong(String time, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps steps',
      one: '1 step',
    );
    return 'Drawdown $time s is above the target window: grind coarser by $_temp0.';
  }

  @override
  String get stockOrderNow => 'Order now';

  @override
  String stockDaysLeft(String days) {
    return '$days days left';
  }

  @override
  String stockDaysValue(String days) {
    return '$days days';
  }

  @override
  String stockBarLabel(String stock, String point) {
    return 'Stock $stock of order point $point';
  }

  @override
  String get tileReach => 'Days of cover';

  @override
  String get tileMinStock => 'Minimum stock';

  @override
  String gapBanner(String from, String to) {
    return 'No ready coffee from $from to $to';
  }

  @override
  String gapOpenPack(String x) {
    return 'Open pack $x';
  }

  @override
  String get todayReadyNow => 'Ready now';

  @override
  String get todayReadyNone => 'Nothing is ready to drink right now.';

  @override
  String get todayLastBrew => 'Last brew';

  @override
  String get todayLastNone => 'No brews yet.';

  @override
  String get todayNewBrew => 'New brew';

  @override
  String todayBeanOrderDetail(String bean, String days) {
    return '$bean · $days days left';
  }

  @override
  String warningWater(String name) {
    return 'Water profile $name outside SCA';
  }

  @override
  String warningCareDue(String task) {
    return '$task due';
  }

  @override
  String careTaskTitle(String kind, String name) {
    return '$kind $name';
  }

  @override
  String get careBackflush => 'Backflush';

  @override
  String get careDescale => 'Descale';

  @override
  String get careGrinderClean => 'Grinder cleaning';

  @override
  String get careDue => 'Due';

  @override
  String careInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'In $n days',
      one: 'In 1 day',
    );
    return '$_temp0';
  }

  @override
  String get careBackflushDue => 'Backflush: Due';

  @override
  String careShotsSince(int n) {
    return 'Shots since last time: $n';
  }

  @override
  String careLastDone(String date) {
    return 'Last done: $date';
  }

  @override
  String get careNeverDone => 'Never done';

  @override
  String get careManualHint => 'The machine manual takes precedence.';

  @override
  String get careDone => 'Done';

  @override
  String get careEmptyTitle => 'Nothing to maintain';

  @override
  String get careEmptyBody => 'Add a machine first.';

  @override
  String get careTileNone => 'Nothing due';

  @override
  String careTileDue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tasks due',
      one: '1 task due',
    );
    return '$_temp0';
  }

  @override
  String get exportButton => 'Export data';

  @override
  String get exportHelp =>
      'Saves all your data as one JSON file. Data only leaves this device through the export.';

  @override
  String exportShared(String file) {
    return 'Export shared: $file';
  }

  @override
  String exportDownloaded(String file) {
    return 'Downloaded $file';
  }

  @override
  String get exportReadyTitle => 'Export ready';

  @override
  String exportCopiedBody(String file) {
    return 'The JSON was copied to the clipboard. Save it as $file.';
  }

  @override
  String get close => 'Close';

  @override
  String get importButton => 'Import data';

  @override
  String get importHelp =>
      'Reads a JSON file exported by this app. Newer records win.';

  @override
  String get importPasteButton => 'Paste JSON';

  @override
  String get importJsonLabel => 'JSON';

  @override
  String get importConfirm => 'Import';

  @override
  String importResultImported(int n) {
    return '$n records imported';
  }

  @override
  String importResultSkipped(int n) {
    return '$n records skipped';
  }

  @override
  String get importUnsupported => 'File version not supported';

  @override
  String get importInvalid => 'Invalid file';

  @override
  String get deleteAllButton => 'Delete all data';

  @override
  String get deleteAllTitle => 'Delete all data?';

  @override
  String get deleteAllBody =>
      'Beans, packs, brews, equipment and water profiles are removed from this device. Export first to keep them.';

  @override
  String get deleteAllConfirm => 'Delete';

  @override
  String get deleteAllDone => 'All data deleted';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesGroupRest => 'Resting times';

  @override
  String get sourcesLoadError => 'Sources could not be loaded.';
}
