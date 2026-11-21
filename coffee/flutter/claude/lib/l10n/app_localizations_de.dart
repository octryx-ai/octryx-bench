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

  @override
  String get beansEmptyTitle => 'Noch keine Bohnen';

  @override
  String get noPack => 'Keine Packung';

  @override
  String get beanEditTitle => 'Bohne bearbeiten';

  @override
  String get packForm => 'Packung hinzufügen';

  @override
  String get packEditTitle => 'Packung bearbeiten';

  @override
  String get fieldRoaster => 'Röster';

  @override
  String get fieldRoastLevel => 'Röstgrad';

  @override
  String get fieldKind => 'Art';

  @override
  String get fieldLeadTime => 'Lieferzeit';

  @override
  String get fieldMinStock => 'Mindestbestand (optional)';

  @override
  String get fieldRoastDate => 'Röstdatum';

  @override
  String get fieldWeight => 'Gewicht';

  @override
  String get firstPack => 'Erste Packung';

  @override
  String get unitDays => 'Tage';

  @override
  String get roastLight => 'Hell';

  @override
  String get roastMedium => 'Mittel';

  @override
  String get roastMediumDark => 'Mitteldunkel';

  @override
  String get roastDark => 'Dunkel';

  @override
  String get kindEspressoBlend => 'Espresso-Blend';

  @override
  String get kindFilter => 'Filter';

  @override
  String get kindAllround => 'Allround';

  @override
  String get dateRequired => 'Datum eingeben';

  @override
  String dateInvalid(String example) {
    return 'Datum wie $example eingeben';
  }

  @override
  String get dateFuture => 'Das Datum darf nicht in der Zukunft liegen';

  @override
  String get pickDate => 'Datum wählen';

  @override
  String roastedOn(String date) {
    return 'Geröstet am $date';
  }

  @override
  String packSizes(String remaining, String size) {
    return '$remaining von $size';
  }

  @override
  String get openPack => 'Öffnen';

  @override
  String openedOn(String date) {
    return 'Geöffnet am $date';
  }

  @override
  String get tileRemaining => 'Restgramm';

  @override
  String get tileReadyDate => 'Bereit-Datum';

  @override
  String get packsTitle => 'Packungen';

  @override
  String get noPacksYet => 'Noch keine Packungen.';

  @override
  String get beanNotFound => 'Bohne nicht gefunden';

  @override
  String get editPack => 'Packung bearbeiten';

  @override
  String deletePackNamed(String date) {
    return 'Packung vom $date löschen';
  }

  @override
  String kindAndRoast(String kind, String roast) {
    return '$kind, $roast';
  }

  @override
  String beanImageLabel(String name) {
    return 'Bild von $name';
  }

  @override
  String get brewsEmptyTitle => 'Noch keine Brühungen';

  @override
  String get brewsEmptyBody => 'Erfasse deinen ersten Shot.';

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
  String get tasteSour => 'Sauer';

  @override
  String get tasteBitter => 'Bitter';

  @override
  String get tasteWeak => 'Schwach';

  @override
  String get tasteBalanced => 'Ausgewogen';

  @override
  String get brewMethod => 'Methode';

  @override
  String get brewMachine => 'Maschine';

  @override
  String get brewGrinder => 'Mühle';

  @override
  String get brewPack => 'Packung';

  @override
  String get brewGrind => 'Mahlgrad';

  @override
  String get brewDose => 'Dosis';

  @override
  String get brewPurge => 'Spülmenge';

  @override
  String get brewYield => 'Ausbeute';

  @override
  String get brewShotTime => 'Shot-Zeit (s)';

  @override
  String get brewTime => 'Shot-Zeit';

  @override
  String get brewRatio => 'Verhältnis';

  @override
  String get brewWater => 'Wasserprofil';

  @override
  String get brewTaste => 'Geschmack';

  @override
  String get brewRating => 'Bewertung';

  @override
  String get brewNote => 'Notiz';

  @override
  String get brewStarted => 'Gestartet';

  @override
  String get grindLower => 'Mahlgrad verringern';

  @override
  String get grindRaise => 'Mahlgrad erhöhen';

  @override
  String get timerStart => 'Timer starten';

  @override
  String get timerStop => 'Timer stoppen';

  @override
  String timerElapsed(String time) {
    return 'Verstrichen $time';
  }

  @override
  String ratingStars(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Sterne',
      one: '1 Stern',
    );
    return '$_temp0';
  }

  @override
  String purgeBeanChange(String grams) {
    return 'Vorab $grams mahlen und verwerfen (Bohnenwechsel)';
  }

  @override
  String purgeIdle(String grams) {
    return 'Vorab $grams mahlen und verwerfen (Mühle lange ungenutzt)';
  }

  @override
  String get needGrinder => 'Zuerst eine Mühle anlegen';

  @override
  String get needMachine => 'Zuerst eine Maschine anlegen';

  @override
  String get needPack => 'Zuerst eine Packung anlegen';

  @override
  String notEnoughBeans(String n) {
    return 'Nicht genug Bohnen in der Packung (Rest $n g)';
  }

  @override
  String brewPackOption(String bean, String date, String grams) {
    return '$bean, geröstet $date, noch $grams';
  }

  @override
  String get brewSelectionMissing => 'Wähle Maschine, Mühle und Packung';

  @override
  String get brewNotFound => 'Brühung nicht gefunden';

  @override
  String get recTitle => 'Empfehlung';

  @override
  String get recReasonTitle => 'Grund';

  @override
  String get recSourceTitle => 'Quelle';

  @override
  String recGrind(String setting) {
    return 'Mahlgrad auf $setting';
  }

  @override
  String get recNoChange => 'Keine Änderung';

  @override
  String recScaleEnd(String setting) {
    return 'Mahlgrad bleibt $setting';
  }

  @override
  String get recScaleEndHint => 'Skalenende';

  @override
  String recRest(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Packung noch ruhen lassen (noch $n Tage)',
      one: 'Packung noch ruhen lassen (noch 1 Tag)',
    );
    return '$_temp0';
  }

  @override
  String get recNoWater => 'Wasserwerte erfassen';

  @override
  String get reasonNoWater =>
      'Es ist kein Wasserprofil gewählt, das Wasser kann nicht geprüft werden.';

  @override
  String get reasonWaterOutside =>
      'Wasser ausserhalb des SCA-Bereichs kommt vor jeder anderen Änderung.';

  @override
  String get reasonPackResting =>
      'Die Packung hat die Espresso-Ruhezeit noch nicht erreicht.';

  @override
  String reasonTimeTooShort(String time, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps Stufen',
      one: '1 Stufe',
    );
    return 'Shot-Zeit $time s liegt unter dem Zielfenster: $_temp0 feiner mahlen.';
  }

  @override
  String reasonTimeTooLong(String time, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps Stufen',
      one: '1 Stufe',
    );
    return 'Shot-Zeit $time s liegt über dem Zielfenster: $_temp0 gröber mahlen.';
  }

  @override
  String reasonTasteSour(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps Stufen',
      one: '1 Stufe',
    );
    return 'Sauer im Zielfenster: $_temp0 feiner mahlen.';
  }

  @override
  String reasonTasteWeak(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps Stufen',
      one: '1 Stufe',
    );
    return 'Schwach im Zielfenster: $_temp0 feiner mahlen.';
  }

  @override
  String reasonTasteBitter(int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps Stufen',
      one: '1 Stufe',
    );
    return 'Bitter im Zielfenster: $_temp0 gröber mahlen.';
  }

  @override
  String get reasonBalanced =>
      'Ausgewogen und im Zielfenster: alles beibehalten.';

  @override
  String get reasonScaleEnd =>
      'Die Mühle ist am Ende der Skala; keine weitere Änderung möglich.';

  @override
  String get nextTry => 'Nächster Versuch';
}
