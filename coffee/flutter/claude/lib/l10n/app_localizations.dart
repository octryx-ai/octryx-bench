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
