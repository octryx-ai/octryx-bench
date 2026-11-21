// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kaffee-Begleiter';

  @override
  String get today => 'Heute';

  @override
  String get beans => 'Bohnen';

  @override
  String get brew => 'Brühen';

  @override
  String get equipment => 'Ausrüstung';

  @override
  String get more => 'Mehr';

  @override
  String get water => 'Wasser';

  @override
  String get care => 'Pflege';

  @override
  String get settings => 'Einstellungen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ready => 'Bereit';

  @override
  String restingDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ruht noch $n Tage',
      one: 'Ruht noch 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get tooOld => 'Zu alt';

  @override
  String get comingSoon => 'Kommt bald';

  @override
  String get comingSoonBody =>
      'Dieser Teil der App folgt in einer späteren Version.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get noImage => 'Kein Bild';

  @override
  String get defaultWithoutSource => 'Standardwert ohne Quelle';

  @override
  String sourceLabel(String source, String date) {
    return 'Quelle: $source (abgerufen $date)';
  }

  @override
  String get bannerInfo => 'Info';

  @override
  String get bannerWarning => 'Warnung';

  @override
  String get bannerError => 'Fehler';

  @override
  String get styleGuide => 'Style-Guide';

  @override
  String get navigation => 'Navigation';

  @override
  String get add => 'Hinzufügen';

  @override
  String get back => 'Zurück';

  @override
  String get startFilter => 'Filter starten';

  @override
  String get grinders => 'Mühlen';

  @override
  String get machines => 'Maschinen';

  @override
  String get beanDetail => 'Bohnendetail';

  @override
  String get beanForm => 'Bohne hinzufügen';

  @override
  String get brewForm => 'Brühung erfassen';

  @override
  String get brewDetail => 'Brühungsdetail';

  @override
  String get filterGuided => 'Filter geführt';

  @override
  String get grinderForm => 'Mühle hinzufügen';

  @override
  String get machineForm => 'Maschine hinzufügen';

  @override
  String get waterForm => 'Wasserprofil hinzufügen';

  @override
  String get openBeanDetail => 'Bohne öffnen';

  @override
  String get openBrewDetail => 'Brühung öffnen';

  @override
  String get emptyTitle => 'Noch nichts da';

  @override
  String get emptyBody => 'Lege deine erste Bohne an.';

  @override
  String get addBean => 'Bohne hinzufügen';

  @override
  String get loading => 'Lädt';

  @override
  String get errorBody => 'Etwas ist schiefgelaufen.';

  @override
  String get stateDefault => 'Standard';

  @override
  String get stateHover => 'Hover';

  @override
  String get statePressed => 'Gedrückt';

  @override
  String get stateFocus => 'Fokus';

  @override
  String get stateDisabled => 'Deaktiviert';

  @override
  String get stateLoading => 'Lädt';

  @override
  String get stateSelected => 'Ausgewählt';

  @override
  String get stateEmpty => 'Leer';

  @override
  String get stateError => 'Fehler';

  @override
  String get sgIntro => 'Jede Komponente in jedem Zustand, im aktuellen Theme.';

  @override
  String get sgColors => 'Farben';

  @override
  String get sgButtons => 'Schaltflächen';

  @override
  String get sgCards => 'Karten';

  @override
  String get sgFields => 'Felder';

  @override
  String get sgChips => 'Chips';

  @override
  String get sgBanners => 'Banner';

  @override
  String get sgOther => 'Weiteres';

  @override
  String get fieldLabel => 'Bezeichnung';

  @override
  String get fieldHint => 'Wert';

  @override
  String get fieldUnit => 'g';

  @override
  String get fieldErrorText => 'Wert zwischen 1 und 100 eingeben';

  @override
  String get bannerInfoText => 'Deine Bohnen ruhen noch.';

  @override
  String get bannerWarningText => 'Bohnen bald nachbestellen.';

  @override
  String get bannerErrorText => 'Die Brühung konnte nicht gespeichert werden.';

  @override
  String get bannerAction => 'Anzeigen';

  @override
  String get cardTitle => 'Kartentitel';

  @override
  String get cardBody => 'Karteninhalt in Papier-Anmutung.';

  @override
  String get ruleDemoKey => 'Regel-Demo';

  @override
  String get aboutSources => 'Über und Quellen';

  @override
  String get fieldName => 'Name';

  @override
  String get edit => 'Bearbeiten';

  @override
  String deleteNamed(String name) {
    return '$name löschen';
  }

  @override
  String get enterNumber => 'Zahl eingeben';

  @override
  String rangeError(String min, String max) {
    return 'Wert zwischen $min und $max eingeben';
  }

  @override
  String get nameRequired => 'Name eingeben';

  @override
  String tooLong(int n) {
    return 'Höchstens $n Zeichen verwenden';
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
      other: '$n Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get grinderAdd => 'Mühle hinzufügen';

  @override
  String get grinderEditTitle => 'Mühle bearbeiten';

  @override
  String get grindersEmptyTitle => 'Noch keine Mühle';

  @override
  String get grindersEmptyBody => 'Lege deine Mühle mit Skala und Totraum an.';

  @override
  String get scaleMin => 'Skala Minimum';

  @override
  String get scaleMax => 'Skala Maximum';

  @override
  String get scaleStep => 'Skala Schritt';

  @override
  String get stepPositive => 'Schritt muss grösser als 0 sein';

  @override
  String get scaleMaxAboveMin => 'Maximum muss grösser als das Minimum sein';

  @override
  String get finerDirection => 'Richtung für feiner';

  @override
  String get finerDown => 'Abwärts (kleiner ist feiner)';

  @override
  String get finerUp => 'Aufwärts (grösser ist feiner)';

  @override
  String get deadSpace => 'Totraum';

  @override
  String get checkGrindSetting => 'Mahlgrad prüfen';

  @override
  String grindSettingNotOnScale(String step) {
    return 'Wert liegt nicht auf der Skala der Mühle (Schritt $step)';
  }

  @override
  String get machineAdd => 'Maschine hinzufügen';

  @override
  String get machineEditTitle => 'Maschine bearbeiten';

  @override
  String get machinesEmptyTitle => 'Noch keine Maschine';

  @override
  String get machinesEmptyBody => 'Lege deine Maschine mit Einstellungen an.';

  @override
  String get brewTemp => 'Brühtemperatur';

  @override
  String get preinfusion => 'Preinfusion';

  @override
  String get pressureProfile => 'Druckprofil';

  @override
  String get defaultWater => 'Standard-Wasserprofil';

  @override
  String get noDefaultWater => 'Keines';

  @override
  String get waterAdd => 'Wasserprofil hinzufügen';

  @override
  String get waterEditTitle => 'Wasserprofil bearbeiten';

  @override
  String get waterDetail => 'Wasserprofil';

  @override
  String get waterEmptyTitle => 'Noch kein Wasserprofil';

  @override
  String get waterEmptyBody => 'Erfasse die Härte deines Wassers.';

  @override
  String get waterInScaRange => 'Im SCA-Bereich';

  @override
  String get waterOutsideSca => 'Ausserhalb SCA';

  @override
  String waterCheckFirst(String parameter, String value, String range) {
    return 'Wasser zuerst prüfen: $parameter $value, SCA $range';
  }

  @override
  String measuredOf(int n, int total) {
    return '$n von $total gemessen';
  }

  @override
  String get notMeasured => 'nicht gemessen';

  @override
  String scaRange(String range) {
    return 'SCA $range';
  }

  @override
  String get paramTds => 'TDS';

  @override
  String get paramHardness => 'Härte';

  @override
  String get paramAlkalinity => 'Alkalinität';

  @override
  String get paramPh => 'pH';

  @override
  String get paramSodium => 'Natrium';

  @override
  String get paramChlorine => 'Chlor';

  @override
  String get hardnessUnitLabel => 'Härteeinheit';

  @override
  String get hardnessRequired => 'Härte (Pflicht)';

  @override
  String get exportData => 'Export';

  @override
  String get importData => 'Import';
}
