import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee Companion'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @beans.
  ///
  /// In en, this message translates to:
  /// **'Beans'**
  String get beans;

  /// No description provided for @brew.
  ///
  /// In en, this message translates to:
  /// **'Brew'**
  String get brew;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @care.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get care;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @restingDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Resting, 1 day left} other{Resting, {n} days left}}'**
  String restingDays(int n);

  /// No description provided for @tooOld.
  ///
  /// In en, this message translates to:
  /// **'Too old'**
  String get tooOld;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This part of the app arrives in a later release.'**
  String get comingSoonBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImage;

  /// No description provided for @defaultWithoutSource.
  ///
  /// In en, this message translates to:
  /// **'Default without source'**
  String get defaultWithoutSource;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source: {source} (retrieved {date})'**
  String sourceLabel(String source, String date);

  /// No description provided for @bannerInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get bannerInfo;

  /// No description provided for @bannerWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get bannerWarning;

  /// No description provided for @bannerError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get bannerError;

  /// No description provided for @styleGuide.
  ///
  /// In en, this message translates to:
  /// **'Style guide'**
  String get styleGuide;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @startFilter.
  ///
  /// In en, this message translates to:
  /// **'Start filter'**
  String get startFilter;

  /// No description provided for @grinders.
  ///
  /// In en, this message translates to:
  /// **'Grinders'**
  String get grinders;

  /// No description provided for @machines.
  ///
  /// In en, this message translates to:
  /// **'Machines'**
  String get machines;

  /// No description provided for @beanDetail.
  ///
  /// In en, this message translates to:
  /// **'Bean detail'**
  String get beanDetail;

  /// No description provided for @beanForm.
  ///
  /// In en, this message translates to:
  /// **'Add bean'**
  String get beanForm;

  /// No description provided for @brewForm.
  ///
  /// In en, this message translates to:
  /// **'Log a brew'**
  String get brewForm;

  /// No description provided for @brewDetail.
  ///
  /// In en, this message translates to:
  /// **'Brew detail'**
  String get brewDetail;

  /// No description provided for @filterGuided.
  ///
  /// In en, this message translates to:
  /// **'Guided filter'**
  String get filterGuided;

  /// No description provided for @grinderForm.
  ///
  /// In en, this message translates to:
  /// **'Add grinder'**
  String get grinderForm;

  /// No description provided for @machineForm.
  ///
  /// In en, this message translates to:
  /// **'Add machine'**
  String get machineForm;

  /// No description provided for @waterForm.
  ///
  /// In en, this message translates to:
  /// **'Add water profile'**
  String get waterForm;

  /// No description provided for @openBeanDetail.
  ///
  /// In en, this message translates to:
  /// **'Open a bean'**
  String get openBeanDetail;

  /// No description provided for @openBrewDetail.
  ///
  /// In en, this message translates to:
  /// **'Open a brew'**
  String get openBrewDetail;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first bean.'**
  String get emptyBody;

  /// No description provided for @addBean.
  ///
  /// In en, this message translates to:
  /// **'Add bean'**
  String get addBean;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @errorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorBody;

  /// No description provided for @stateDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get stateDefault;

  /// No description provided for @stateHover.
  ///
  /// In en, this message translates to:
  /// **'Hover'**
  String get stateHover;

  /// No description provided for @statePressed.
  ///
  /// In en, this message translates to:
  /// **'Pressed'**
  String get statePressed;

  /// No description provided for @stateFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get stateFocus;

  /// No description provided for @stateDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get stateDisabled;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get stateLoading;

  /// No description provided for @stateSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get stateSelected;

  /// No description provided for @stateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get stateEmpty;

  /// No description provided for @stateError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get stateError;

  /// No description provided for @sgIntro.
  ///
  /// In en, this message translates to:
  /// **'Every component in every state, in the current theme.'**
  String get sgIntro;

  /// No description provided for @sgColors.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get sgColors;

  /// No description provided for @sgButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get sgButtons;

  /// No description provided for @sgCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get sgCards;

  /// No description provided for @sgFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get sgFields;

  /// No description provided for @sgChips.
  ///
  /// In en, this message translates to:
  /// **'Chips'**
  String get sgChips;

  /// No description provided for @sgBanners.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get sgBanners;

  /// No description provided for @sgOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sgOther;

  /// No description provided for @fieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get fieldLabel;

  /// No description provided for @fieldHint.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get fieldHint;

  /// No description provided for @fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get fieldUnit;

  /// No description provided for @fieldErrorText.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 1 and 100'**
  String get fieldErrorText;

  /// No description provided for @bannerInfoText.
  ///
  /// In en, this message translates to:
  /// **'Your beans are resting.'**
  String get bannerInfoText;

  /// No description provided for @bannerWarningText.
  ///
  /// In en, this message translates to:
  /// **'Order beans soon.'**
  String get bannerWarningText;

  /// No description provided for @bannerErrorText.
  ///
  /// In en, this message translates to:
  /// **'Could not save the brew.'**
  String get bannerErrorText;

  /// No description provided for @bannerAction.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get bannerAction;

  /// No description provided for @cardTitle.
  ///
  /// In en, this message translates to:
  /// **'Card title'**
  String get cardTitle;

  /// No description provided for @cardBody.
  ///
  /// In en, this message translates to:
  /// **'Card content in paper look.'**
  String get cardBody;

  /// No description provided for @ruleDemoKey.
  ///
  /// In en, this message translates to:
  /// **'Rule demo'**
  String get ruleDemoKey;

  /// No description provided for @aboutSources.
  ///
  /// In en, this message translates to:
  /// **'About and sources'**
  String get aboutSources;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteNamed.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteNamed(String name);

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @rangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between {min} and {max}'**
  String rangeError(String min, String max);

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @tooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most {n} characters'**
  String tooLong(int n);

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @unitS.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get unitS;

  /// No description provided for @unitCelsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get unitCelsius;

  /// No description provided for @unitPpm.
  ///
  /// In en, this message translates to:
  /// **'ppm'**
  String get unitPpm;

  /// No description provided for @unitMgL.
  ///
  /// In en, this message translates to:
  /// **'mg/L'**
  String get unitMgL;

  /// No description provided for @unitFh.
  ///
  /// In en, this message translates to:
  /// **'°fH'**
  String get unitFh;

  /// No description provided for @unitDh.
  ///
  /// In en, this message translates to:
  /// **'°dH'**
  String get unitDh;

  /// No description provided for @gramsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} g'**
  String gramsValue(String value);

  /// No description provided for @secondsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String secondsValue(String value);

  /// No description provided for @celsiusValue.
  ///
  /// In en, this message translates to:
  /// **'{value} °C'**
  String celsiusValue(String value);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day} other{{n} days}}'**
  String daysCount(int n);

  /// No description provided for @grinderAdd.
  ///
  /// In en, this message translates to:
  /// **'Add grinder'**
  String get grinderAdd;

  /// No description provided for @grinderEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit grinder'**
  String get grinderEditTitle;

  /// No description provided for @grindersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No grinder yet'**
  String get grindersEmptyTitle;

  /// No description provided for @grindersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your grinder with scale and dead space.'**
  String get grindersEmptyBody;

  /// No description provided for @scaleMin.
  ///
  /// In en, this message translates to:
  /// **'Scale minimum'**
  String get scaleMin;

  /// No description provided for @scaleMax.
  ///
  /// In en, this message translates to:
  /// **'Scale maximum'**
  String get scaleMax;

  /// No description provided for @scaleStep.
  ///
  /// In en, this message translates to:
  /// **'Scale step'**
  String get scaleStep;

  /// No description provided for @stepPositive.
  ///
  /// In en, this message translates to:
  /// **'Step must be greater than 0'**
  String get stepPositive;

  /// No description provided for @scaleMaxAboveMin.
  ///
  /// In en, this message translates to:
  /// **'Maximum must be greater than the minimum'**
  String get scaleMaxAboveMin;

  /// No description provided for @finerDirection.
  ///
  /// In en, this message translates to:
  /// **'Finer grind direction'**
  String get finerDirection;

  /// No description provided for @finerDown.
  ///
  /// In en, this message translates to:
  /// **'Down (lower is finer)'**
  String get finerDown;

  /// No description provided for @finerUp.
  ///
  /// In en, this message translates to:
  /// **'Up (higher is finer)'**
  String get finerUp;

  /// No description provided for @deadSpace.
  ///
  /// In en, this message translates to:
  /// **'Dead space'**
  String get deadSpace;

  /// No description provided for @checkGrindSetting.
  ///
  /// In en, this message translates to:
  /// **'Check grind setting'**
  String get checkGrindSetting;

  /// No description provided for @grindSettingNotOnScale.
  ///
  /// In en, this message translates to:
  /// **'Value is not on the grinder\'s scale (step {step})'**
  String grindSettingNotOnScale(String step);

  /// No description provided for @machineAdd.
  ///
  /// In en, this message translates to:
  /// **'Add machine'**
  String get machineAdd;

  /// No description provided for @machineEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit machine'**
  String get machineEditTitle;

  /// No description provided for @machinesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No machine yet'**
  String get machinesEmptyTitle;

  /// No description provided for @machinesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your machine with its settings.'**
  String get machinesEmptyBody;

  /// No description provided for @brewTemp.
  ///
  /// In en, this message translates to:
  /// **'Brew temperature'**
  String get brewTemp;

  /// No description provided for @preinfusion.
  ///
  /// In en, this message translates to:
  /// **'Pre-infusion'**
  String get preinfusion;

  /// No description provided for @pressureProfile.
  ///
  /// In en, this message translates to:
  /// **'Pressure profile'**
  String get pressureProfile;

  /// No description provided for @defaultWater.
  ///
  /// In en, this message translates to:
  /// **'Default water profile'**
  String get defaultWater;

  /// No description provided for @noDefaultWater.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noDefaultWater;

  /// No description provided for @waterAdd.
  ///
  /// In en, this message translates to:
  /// **'Add water profile'**
  String get waterAdd;

  /// No description provided for @waterEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit water profile'**
  String get waterEditTitle;

  /// No description provided for @waterDetail.
  ///
  /// In en, this message translates to:
  /// **'Water profile'**
  String get waterDetail;

  /// No description provided for @waterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No water profile yet'**
  String get waterEmptyTitle;

  /// No description provided for @waterEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your water\'s hardness.'**
  String get waterEmptyBody;

  /// No description provided for @waterInScaRange.
  ///
  /// In en, this message translates to:
  /// **'In SCA range'**
  String get waterInScaRange;

  /// No description provided for @waterOutsideSca.
  ///
  /// In en, this message translates to:
  /// **'Outside SCA'**
  String get waterOutsideSca;

  /// No description provided for @waterCheckFirst.
  ///
  /// In en, this message translates to:
  /// **'Check water first: {parameter} {value}, SCA {range}'**
  String waterCheckFirst(String parameter, String value, String range);

  /// No description provided for @measuredOf.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total} measured'**
  String measuredOf(int n, int total);

  /// No description provided for @notMeasured.
  ///
  /// In en, this message translates to:
  /// **'not measured'**
  String get notMeasured;

  /// No description provided for @scaRange.
  ///
  /// In en, this message translates to:
  /// **'SCA {range}'**
  String scaRange(String range);

  /// No description provided for @paramTds.
  ///
  /// In en, this message translates to:
  /// **'TDS'**
  String get paramTds;

  /// No description provided for @paramHardness.
  ///
  /// In en, this message translates to:
  /// **'Hardness'**
  String get paramHardness;

  /// No description provided for @paramAlkalinity.
  ///
  /// In en, this message translates to:
  /// **'Alkalinity'**
  String get paramAlkalinity;

  /// No description provided for @paramPh.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get paramPh;

  /// No description provided for @paramSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get paramSodium;

  /// No description provided for @paramChlorine.
  ///
  /// In en, this message translates to:
  /// **'Chlorine'**
  String get paramChlorine;

  /// No description provided for @hardnessUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Hardness unit'**
  String get hardnessUnitLabel;

  /// No description provided for @hardnessRequired.
  ///
  /// In en, this message translates to:
  /// **'Hardness (required)'**
  String get hardnessRequired;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
