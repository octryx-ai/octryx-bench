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

  /// No description provided for @warningCareAction.
  ///
  /// In en, this message translates to:
  /// **'Open care'**
  String get warningCareAction;

  /// No description provided for @warningWaterAction.
  ///
  /// In en, this message translates to:
  /// **'Open water profile'**
  String get warningWaterAction;

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

  /// No description provided for @beansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No beans yet'**
  String get beansEmptyTitle;

  /// No description provided for @noPack.
  ///
  /// In en, this message translates to:
  /// **'No pack'**
  String get noPack;

  /// No description provided for @beanEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit bean'**
  String get beanEditTitle;

  /// No description provided for @packForm.
  ///
  /// In en, this message translates to:
  /// **'Add pack'**
  String get packForm;

  /// No description provided for @packEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit pack'**
  String get packEditTitle;

  /// No description provided for @fieldRoaster.
  ///
  /// In en, this message translates to:
  /// **'Roaster'**
  String get fieldRoaster;

  /// No description provided for @fieldRoastLevel.
  ///
  /// In en, this message translates to:
  /// **'Roast level'**
  String get fieldRoastLevel;

  /// No description provided for @fieldKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get fieldKind;

  /// No description provided for @fieldLeadTime.
  ///
  /// In en, this message translates to:
  /// **'Lead time'**
  String get fieldLeadTime;

  /// No description provided for @fieldMinStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock (optional)'**
  String get fieldMinStock;

  /// No description provided for @fieldRoastDate.
  ///
  /// In en, this message translates to:
  /// **'Roast date'**
  String get fieldRoastDate;

  /// No description provided for @fieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get fieldWeight;

  /// No description provided for @firstPack.
  ///
  /// In en, this message translates to:
  /// **'First pack'**
  String get firstPack;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// No description provided for @roastLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get roastLight;

  /// No description provided for @roastMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get roastMedium;

  /// No description provided for @roastMediumDark.
  ///
  /// In en, this message translates to:
  /// **'Medium dark'**
  String get roastMediumDark;

  /// No description provided for @roastDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get roastDark;

  /// No description provided for @kindEspressoBlend.
  ///
  /// In en, this message translates to:
  /// **'Espresso blend'**
  String get kindEspressoBlend;

  /// No description provided for @kindFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get kindFilter;

  /// No description provided for @kindAllround.
  ///
  /// In en, this message translates to:
  /// **'All-round'**
  String get kindAllround;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a date'**
  String get dateRequired;

  /// No description provided for @dateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a date like {example}'**
  String dateInvalid(String example);

  /// No description provided for @dateFuture.
  ///
  /// In en, this message translates to:
  /// **'The date must not be in the future'**
  String get dateFuture;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @roastedOn.
  ///
  /// In en, this message translates to:
  /// **'Roasted {date}'**
  String roastedOn(String date);

  /// No description provided for @packSizes.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {size}'**
  String packSizes(String remaining, String size);

  /// No description provided for @openPack.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openPack;

  /// No description provided for @openedOn.
  ///
  /// In en, this message translates to:
  /// **'Opened on {date}'**
  String openedOn(String date);

  /// No description provided for @tileRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get tileRemaining;

  /// No description provided for @tileReadyDate.
  ///
  /// In en, this message translates to:
  /// **'Ready date'**
  String get tileReadyDate;

  /// No description provided for @packsTitle.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get packsTitle;

  /// No description provided for @noPacksYet.
  ///
  /// In en, this message translates to:
  /// **'No packs yet.'**
  String get noPacksYet;

  /// No description provided for @beanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bean not found'**
  String get beanNotFound;

  /// No description provided for @editPack.
  ///
  /// In en, this message translates to:
  /// **'Edit pack'**
  String get editPack;

  /// No description provided for @deletePackNamed.
  ///
  /// In en, this message translates to:
  /// **'Delete pack roasted {date}'**
  String deletePackNamed(String date);

  /// No description provided for @kindAndRoast.
  ///
  /// In en, this message translates to:
  /// **'{kind}, {roast}'**
  String kindAndRoast(String kind, String roast);

  /// No description provided for @beanImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image of {name}'**
  String beanImageLabel(String name);

  /// No description provided for @brewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No brews yet'**
  String get brewsEmptyTitle;

  /// No description provided for @brewsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Log your first shot.'**
  String get brewsEmptyBody;

  /// No description provided for @methodEspresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get methodEspresso;

  /// No description provided for @methodV60.
  ///
  /// In en, this message translates to:
  /// **'V60'**
  String get methodV60;

  /// No description provided for @methodChemex.
  ///
  /// In en, this message translates to:
  /// **'Chemex'**
  String get methodChemex;

  /// No description provided for @methodKalita.
  ///
  /// In en, this message translates to:
  /// **'Kalita'**
  String get methodKalita;

  /// No description provided for @methodAeropress.
  ///
  /// In en, this message translates to:
  /// **'AeroPress'**
  String get methodAeropress;

  /// No description provided for @methodBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get methodBatch;

  /// No description provided for @tasteSour.
  ///
  /// In en, this message translates to:
  /// **'Sour'**
  String get tasteSour;

  /// No description provided for @tasteBitter.
  ///
  /// In en, this message translates to:
  /// **'Bitter'**
  String get tasteBitter;

  /// No description provided for @tasteWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get tasteWeak;

  /// No description provided for @tasteBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get tasteBalanced;

  /// No description provided for @brewMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get brewMethod;

  /// No description provided for @brewMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get brewMachine;

  /// No description provided for @brewGrinder.
  ///
  /// In en, this message translates to:
  /// **'Grinder'**
  String get brewGrinder;

  /// No description provided for @brewPack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get brewPack;

  /// No description provided for @brewGrind.
  ///
  /// In en, this message translates to:
  /// **'Grind setting'**
  String get brewGrind;

  /// No description provided for @brewDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get brewDose;

  /// No description provided for @brewPurge.
  ///
  /// In en, this message translates to:
  /// **'Purge amount'**
  String get brewPurge;

  /// No description provided for @brewYield.
  ///
  /// In en, this message translates to:
  /// **'Yield'**
  String get brewYield;

  /// No description provided for @brewShotTime.
  ///
  /// In en, this message translates to:
  /// **'Shot time (s)'**
  String get brewShotTime;

  /// No description provided for @brewTime.
  ///
  /// In en, this message translates to:
  /// **'Shot time'**
  String get brewTime;

  /// No description provided for @brewRatio.
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get brewRatio;

  /// No description provided for @brewWater.
  ///
  /// In en, this message translates to:
  /// **'Water profile'**
  String get brewWater;

  /// No description provided for @brewTaste.
  ///
  /// In en, this message translates to:
  /// **'Taste'**
  String get brewTaste;

  /// No description provided for @brewRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get brewRating;

  /// No description provided for @brewNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get brewNote;

  /// No description provided for @brewStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get brewStarted;

  /// No description provided for @grindLower.
  ///
  /// In en, this message translates to:
  /// **'Lower grind setting'**
  String get grindLower;

  /// No description provided for @grindRaise.
  ///
  /// In en, this message translates to:
  /// **'Raise grind setting'**
  String get grindRaise;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get timerStart;

  /// No description provided for @timerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop timer'**
  String get timerStop;

  /// No description provided for @timerElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed {time}'**
  String timerElapsed(String time);

  /// No description provided for @ratingStars.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 star} other{{n} stars}}'**
  String ratingStars(int n);

  /// No description provided for @purgeBeanChange.
  ///
  /// In en, this message translates to:
  /// **'Grind and discard {grams} first (bean change)'**
  String purgeBeanChange(String grams);

  /// No description provided for @purgeIdle.
  ///
  /// In en, this message translates to:
  /// **'Grind and discard {grams} first (grinder idle)'**
  String purgeIdle(String grams);

  /// No description provided for @needGrinder.
  ///
  /// In en, this message translates to:
  /// **'Add a grinder first'**
  String get needGrinder;

  /// No description provided for @needMachine.
  ///
  /// In en, this message translates to:
  /// **'Add a machine first'**
  String get needMachine;

  /// No description provided for @needPack.
  ///
  /// In en, this message translates to:
  /// **'Add a pack first'**
  String get needPack;

  /// No description provided for @notEnoughBeans.
  ///
  /// In en, this message translates to:
  /// **'Not enough beans in the pack ({n} g left)'**
  String notEnoughBeans(String n);

  /// No description provided for @brewPackOption.
  ///
  /// In en, this message translates to:
  /// **'{bean}, roasted {date}, {grams} left'**
  String brewPackOption(String bean, String date, String grams);

  /// No description provided for @brewSelectionMissing.
  ///
  /// In en, this message translates to:
  /// **'Choose machine, grinder and pack'**
  String get brewSelectionMissing;

  /// No description provided for @brewNotFound.
  ///
  /// In en, this message translates to:
  /// **'Brew not found'**
  String get brewNotFound;

  /// No description provided for @recTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recTitle;

  /// No description provided for @recReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get recReasonTitle;

  /// No description provided for @recSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get recSourceTitle;

  /// No description provided for @recGrind.
  ///
  /// In en, this message translates to:
  /// **'Set grind to {setting}'**
  String recGrind(String setting);

  /// No description provided for @recNoChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get recNoChange;

  /// No description provided for @recScaleEnd.
  ///
  /// In en, this message translates to:
  /// **'Grind stays at {setting}'**
  String recScaleEnd(String setting);

  /// No description provided for @recScaleEndHint.
  ///
  /// In en, this message translates to:
  /// **'End of scale'**
  String get recScaleEndHint;

  /// No description provided for @recRest.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Let the pack rest (1 day left)} other{Let the pack rest ({n} days left)}}'**
  String recRest(int n);

  /// No description provided for @recNoWater.
  ///
  /// In en, this message translates to:
  /// **'Enter water values'**
  String get recNoWater;

  /// No description provided for @reasonNoWater.
  ///
  /// In en, this message translates to:
  /// **'No water profile is set, so the water cannot be checked.'**
  String get reasonNoWater;

  /// No description provided for @reasonWaterOutside.
  ///
  /// In en, this message translates to:
  /// **'Water outside the SCA range comes before any other change.'**
  String get reasonWaterOutside;

  /// No description provided for @reasonPackResting.
  ///
  /// In en, this message translates to:
  /// **'The pack has not finished resting for espresso yet.'**
  String get reasonPackResting;

  /// No description provided for @reasonTimeTooShort.
  ///
  /// In en, this message translates to:
  /// **'Shot time {time} s is below the target window: grind finer by {steps, plural, =1{1 step} other{{steps} steps}}.'**
  String reasonTimeTooShort(String time, int steps);

  /// No description provided for @reasonTimeTooLong.
  ///
  /// In en, this message translates to:
  /// **'Shot time {time} s is above the target window: grind coarser by {steps, plural, =1{1 step} other{{steps} steps}}.'**
  String reasonTimeTooLong(String time, int steps);

  /// No description provided for @reasonTasteSour.
  ///
  /// In en, this message translates to:
  /// **'Sour taste in the target window: grind finer by {steps, plural, =1{1 step} other{{steps} steps}}.'**
  String reasonTasteSour(int steps);

  /// No description provided for @reasonTasteWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak taste in the target window: grind finer by {steps, plural, =1{1 step} other{{steps} steps}}.'**
  String reasonTasteWeak(int steps);

  /// No description provided for @reasonTasteBitter.
  ///
  /// In en, this message translates to:
  /// **'Bitter taste in the target window: grind coarser by {steps, plural, =1{1 step} other{{steps} steps}}.'**
  String reasonTasteBitter(int steps);

  /// No description provided for @reasonBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced and inside the target window: keep everything.'**
  String get reasonBalanced;

  /// No description provided for @reasonScaleEnd.
  ///
  /// In en, this message translates to:
  /// **'The grinder is at the end of its scale; no further change is possible.'**
  String get reasonScaleEnd;

  /// No description provided for @nextTry.
  ///
  /// In en, this message translates to:
  /// **'Next try'**
  String get nextTry;

  /// No description provided for @filterMethodNote.
  ///
  /// In en, this message translates to:
  /// **'V60 scheme'**
  String get filterMethodNote;

  /// No description provided for @filterNoPack.
  ///
  /// In en, this message translates to:
  /// **'No pack is ready yet'**
  String get filterNoPack;

  /// No description provided for @filterPackBackup.
  ///
  /// In en, this message translates to:
  /// **'{pack} (backup)'**
  String filterPackBackup(String pack);

  /// No description provided for @filterRatio.
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get filterRatio;

  /// No description provided for @filterWaterTotal.
  ///
  /// In en, this message translates to:
  /// **'Total water: {n} g'**
  String filterWaterTotal(String n);

  /// No description provided for @filterStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get filterStart;

  /// No description provided for @filterNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get filterNext;

  /// No description provided for @filterPourTo.
  ///
  /// In en, this message translates to:
  /// **'Pour to {n} g'**
  String filterPourTo(String n);

  /// No description provided for @filterAtTime.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String filterAtTime(String time);

  /// No description provided for @filterStepBloom.
  ///
  /// In en, this message translates to:
  /// **'Bloom'**
  String get filterStepBloom;

  /// No description provided for @filterStepPour.
  ///
  /// In en, this message translates to:
  /// **'Pour {n}'**
  String filterStepPour(String n);

  /// No description provided for @filterFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Drawdown'**
  String get filterFinishTitle;

  /// No description provided for @filterDrawdownField.
  ///
  /// In en, this message translates to:
  /// **'Drawdown time (s)'**
  String get filterDrawdownField;

  /// No description provided for @filterTimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Timer {time}'**
  String filterTimerLabel(String time);

  /// No description provided for @brewDrawdown.
  ///
  /// In en, this message translates to:
  /// **'Drawdown time'**
  String get brewDrawdown;

  /// No description provided for @brewWaterTotal.
  ///
  /// In en, this message translates to:
  /// **'Total water'**
  String get brewWaterTotal;

  /// No description provided for @brewBloom.
  ///
  /// In en, this message translates to:
  /// **'Bloom'**
  String get brewBloom;

  /// No description provided for @brewPours.
  ///
  /// In en, this message translates to:
  /// **'Pours'**
  String get brewPours;

  /// No description provided for @reasonPackRestingFilter.
  ///
  /// In en, this message translates to:
  /// **'The pack has not finished resting for filter yet.'**
  String get reasonPackRestingFilter;

  /// No description provided for @reasonDrawdownTooShort.
  ///
  /// In en, this message translates to:
  /// **'Drawdown {time} s is below the target window: grind finer by {steps, plural, =1{1 step} other{{steps} steps}}.'**
  String reasonDrawdownTooShort(String time, int steps);

  /// No description provided for @reasonDrawdownTooLong.
  ///
  /// In en, this message translates to:
  /// **'Drawdown {time} s is above the target window: grind coarser by {steps, plural, =1{1 step} other{{steps} steps}}.'**
  String reasonDrawdownTooLong(String time, int steps);

  /// No description provided for @stockOrderNow.
  ///
  /// In en, this message translates to:
  /// **'Order now'**
  String get stockOrderNow;

  /// No description provided for @stockDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String stockDaysLeft(String days);

  /// No description provided for @stockDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String stockDaysValue(String days);

  /// No description provided for @stockBarLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock {stock} of order point {point}'**
  String stockBarLabel(String stock, String point);

  /// No description provided for @tileReach.
  ///
  /// In en, this message translates to:
  /// **'Days of cover'**
  String get tileReach;

  /// No description provided for @tileMinStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock'**
  String get tileMinStock;

  /// No description provided for @gapBanner.
  ///
  /// In en, this message translates to:
  /// **'No ready coffee from {from} to {to}'**
  String gapBanner(String from, String to);

  /// No description provided for @gapOpenPack.
  ///
  /// In en, this message translates to:
  /// **'Open pack {x}'**
  String gapOpenPack(String x);

  /// No description provided for @todayReadyNow.
  ///
  /// In en, this message translates to:
  /// **'Ready now'**
  String get todayReadyNow;

  /// No description provided for @todayReadyNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing is ready to drink right now.'**
  String get todayReadyNone;

  /// No description provided for @todayNoPackTitle.
  ///
  /// In en, this message translates to:
  /// **'No pack yet'**
  String get todayNoPackTitle;

  /// No description provided for @todayNoPackHint.
  ///
  /// In en, this message translates to:
  /// **'Add a pack'**
  String get todayNoPackHint;

  /// No description provided for @todayLastBrew.
  ///
  /// In en, this message translates to:
  /// **'Last brew'**
  String get todayLastBrew;

  /// No description provided for @todayLastNone.
  ///
  /// In en, this message translates to:
  /// **'No brews yet.'**
  String get todayLastNone;

  /// No description provided for @todayNewBrew.
  ///
  /// In en, this message translates to:
  /// **'New brew'**
  String get todayNewBrew;

  /// No description provided for @todayBeanOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'{bean} · {days} days left'**
  String todayBeanOrderDetail(String bean, String days);

  /// No description provided for @warningWater.
  ///
  /// In en, this message translates to:
  /// **'Water profile {name} outside SCA'**
  String warningWater(String name);

  /// No description provided for @warningCareDue.
  ///
  /// In en, this message translates to:
  /// **'{task} due'**
  String warningCareDue(String task);

  /// No description provided for @careTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'{kind} {name}'**
  String careTaskTitle(String kind, String name);

  /// No description provided for @careBackflush.
  ///
  /// In en, this message translates to:
  /// **'Backflush'**
  String get careBackflush;

  /// No description provided for @careDescale.
  ///
  /// In en, this message translates to:
  /// **'Descale'**
  String get careDescale;

  /// No description provided for @careGrinderClean.
  ///
  /// In en, this message translates to:
  /// **'Grinder cleaning'**
  String get careGrinderClean;

  /// No description provided for @careDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get careDue;

  /// No description provided for @careInDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{In 1 day} other{In {n} days}}'**
  String careInDays(int n);

  /// No description provided for @careBackflushDue.
  ///
  /// In en, this message translates to:
  /// **'Backflush: Due'**
  String get careBackflushDue;

  /// No description provided for @careShotsSince.
  ///
  /// In en, this message translates to:
  /// **'Shots since last time: {n}'**
  String careShotsSince(int n);

  /// No description provided for @careLastDone.
  ///
  /// In en, this message translates to:
  /// **'Last done: {date}'**
  String careLastDone(String date);

  /// No description provided for @careNeverDone.
  ///
  /// In en, this message translates to:
  /// **'Never done'**
  String get careNeverDone;

  /// No description provided for @careManualHint.
  ///
  /// In en, this message translates to:
  /// **'The machine manual takes precedence.'**
  String get careManualHint;

  /// No description provided for @careDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get careDone;

  /// No description provided for @careEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to maintain'**
  String get careEmptyTitle;

  /// No description provided for @careEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a machine first.'**
  String get careEmptyBody;

  /// No description provided for @careTileNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing due'**
  String get careTileNone;

  /// No description provided for @careTileDue.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 task due} other{{n} tasks due}}'**
  String careTileDue(int n);

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportButton;

  /// No description provided for @exportHelp.
  ///
  /// In en, this message translates to:
  /// **'Saves all your data as one JSON file. Data only leaves this device through the export.'**
  String get exportHelp;

  /// No description provided for @exportShared.
  ///
  /// In en, this message translates to:
  /// **'Export shared: {file}'**
  String exportShared(String file);

  /// No description provided for @exportDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {file}'**
  String exportDownloaded(String file);

  /// No description provided for @exportReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get exportReadyTitle;

  /// No description provided for @exportCopiedBody.
  ///
  /// In en, this message translates to:
  /// **'The JSON was copied to the clipboard. Save it as {file}.'**
  String exportCopiedBody(String file);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importButton;

  /// No description provided for @importHelp.
  ///
  /// In en, this message translates to:
  /// **'Reads a JSON file exported by this app. Newer records win.'**
  String get importHelp;

  /// No description provided for @importPasteButton.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON'**
  String get importPasteButton;

  /// No description provided for @importJsonLabel.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get importJsonLabel;

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importConfirm;

  /// No description provided for @importResultImported.
  ///
  /// In en, this message translates to:
  /// **'{n} records imported'**
  String importResultImported(int n);

  /// No description provided for @importResultSkipped.
  ///
  /// In en, this message translates to:
  /// **'{n} records skipped'**
  String importResultSkipped(int n);

  /// No description provided for @importUnsupported.
  ///
  /// In en, this message translates to:
  /// **'File version not supported'**
  String get importUnsupported;

  /// No description provided for @importInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid file'**
  String get importInvalid;

  /// No description provided for @deleteAllButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllButton;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'Beans, packs, brews, equipment and water profiles are removed from this device. Export first to keep them.'**
  String get deleteAllBody;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAllConfirm;

  /// No description provided for @deleteAllDone.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get deleteAllDone;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// No description provided for @sourcesGroupRest.
  ///
  /// In en, this message translates to:
  /// **'Resting times'**
  String get sourcesGroupRest;

  /// No description provided for @sourcesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Sources could not be loaded.'**
  String get sourcesLoadError;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeText.
  ///
  /// In en, this message translates to:
  /// **'Keep track of how your coffee turns out.'**
  String get onboardingWelcomeText;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingProgress.
  ///
  /// In en, this message translates to:
  /// **'{k} of {total}'**
  String onboardingProgress(int k, int total);

  /// No description provided for @onboardingProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Step {k} of {total}'**
  String onboardingProgressSemantics(int k, int total);

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Setting could not be saved'**
  String get onboardingSaveFailed;

  /// No description provided for @onboardingRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get onboardingRetry;

  /// No description provided for @onboardingFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'What the app does'**
  String get onboardingFeaturesTitle;

  /// No description provided for @onboardingFeatureLog.
  ///
  /// In en, this message translates to:
  /// **'Log brews'**
  String get onboardingFeatureLog;

  /// No description provided for @onboardingFeatureTrack.
  ///
  /// In en, this message translates to:
  /// **'Track beans and resting time'**
  String get onboardingFeatureTrack;

  /// No description provided for @onboardingFeatureTips.
  ///
  /// In en, this message translates to:
  /// **'Get tips to improve'**
  String get onboardingFeatureTips;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingGrinderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your grinder'**
  String get onboardingGrinderTitle;

  /// No description provided for @onboardingGrinderText.
  ///
  /// In en, this message translates to:
  /// **'Add your grinder with scale and dead space.'**
  String get onboardingGrinderText;

  /// No description provided for @onboardingLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get onboardingLater;

  /// No description provided for @onboardingGrinderCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {name}'**
  String onboardingGrinderCreated(String name);

  /// No description provided for @onboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'All set'**
  String get onboardingFinishTitle;

  /// No description provided for @onboardingBeanText.
  ///
  /// In en, this message translates to:
  /// **'Add your first bean. Its pack can follow later.'**
  String get onboardingBeanText;

  /// No description provided for @onboardingBeanRoasterRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a roaster'**
  String get onboardingBeanRoasterRequired;

  /// No description provided for @onboardingBeanCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {name}'**
  String onboardingBeanCreated(String name);

  /// No description provided for @onboardingLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onboardingLetsGo;
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
