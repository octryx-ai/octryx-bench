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
}
