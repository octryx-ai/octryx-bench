# Kaffee-Begleiter (Flutter) – Spezifikation COF-44

App-Ordner: `coffee/flutter/claude`. Ziel: Android und iOS; lokal getestet auf dem Android-Emulator und in Chrome.

## 1 Ziel und Scope

**Ziel:** Eine App, die einen Kaffeeliebhaber beim Kaffeegenuss führt: Brühungen mit Maschine, Mühle, Einstellungen und Shot-Timer erfassen;
Bohnenbestand und Ruhezeit führen; Wasserwerte prüfen; Reinigungsintervalle aus der Nutzung ableiten; nach Geschmacksrückmeldung genau eine
Verbesserung empfehlen (Espresso und Filter); Filterkaffee Schritt für Schritt mit Gramm-Zwischensummen und Timer anleiten.

**In Scope:** mehrere Mühlen (Beispiel: 4 Typen) und Maschinen; Bohnen mehrerer Röster, dieselbe Bohne mehrfach (Packungen); Bestell- und
Lückenwarnung; Wasserprofile; Espresso und Filter (V60, Chemex, Kalita, AeroPress, Batch); lokale Speicherung; JSON-Export/-Import; Deutsch und
Englisch.

**Onboarding (OE-74):** Beim ersten Start zeigt die App ein kurzes Onboarding (Willkommen, Funktionen, erste Mühle, erste Bohne). Es ist überspringbar
und erscheint nach Abschluss oder Überspringen nie wieder, auch nicht nach Reload oder Neustart. Was darin erfasst wird (Mühle, Bohne), ist danach in
der App (Abschnitt 4 R12, Abschnitt 5, UI „Onboarding“); bis zur Persistenz-Story (Folgeticket, Abschnitt 3) nur bis zum Neustart, das Flag
selbst bleibt erhalten.

**Out of Scope:** Onboarding für Maschine und Wasserprofil, erneutes Anzeigen des Onboardings, Login, mehrere Nutzer, Cloud-Sync (späteres Epic; das
Datenmodell ist dafür vorbereitet), Bestell-Abwicklung bei Röstern, Web-Release als Produkt (Chrome dient nur zum Testen).

## 2 Nutzer und Use Cases

Ein Nutzer, kein Login, offline.

- UC1 Mühle anlegen (Skala, Totraum) und Maschine anlegen (Einstellungen, Standard-Wasserprofil).
- UC2 Bohne mit Röster, Röstdatum, Röstgrad, Packungsgrösse erfassen; mehrere Packungen derselben Bohne.
- UC3 Espresso-Brühung erfassen (Maschine, Mühle, Mahlgrad, Dosis, Ausbeute, Shot-Timer, Wasser) und Geschmack bewerten.
- UC4 Empfehlung zur Verbesserung erhalten (genau eine Variable, mit Grund und Quelle; Espresso nach R9, Filter nach R11).
- UC5 Filterkaffee geführt brühen (Methode, Verhältnis, Bloom, Aufgüsse, Timer).
- UC6 Wasserprofil erfassen und gegen den SCA-Bereich prüfen.
- UC7 Reinigungs- und Entkalkungsfälligkeit sehen und quittieren.
- UC8 Bestandsstatus, Bestellhinweis und Lückenwarnung sehen.
- UC9 Daten als JSON exportieren/importieren.
- UC10 Beim ersten Start durch das Onboarding geführt werden (Willkommen, Funktionen, erste Mühle, erste Bohne), es jederzeit überspringen können und
  es danach nie wieder sehen.

## 3 Domänenmodell

Jeder Datensatz: `id` (UUIDv4, String, stabil), `createdAt`, `updatedAt` (UTC ISO-8601, ms), `deletedAt` (nullable). Ziel: drift/SQLite (Folgeticket).
Datumsfelder `roastDate`, `readyDate`, `doneAt`-Tag sind reine Datumswerte (`YYYY-MM-DD`, ohne Zeitzone). „Heute“ ist immer das lokale Kalenderdatum
des Geräts.

**Löschen:** Mühle, Maschine, Bohne, Packung, Wasserprofil werden nie hart gelöscht: `deletedAt` wird gesetzt und `updatedAt = deletedAt`. Der
Datensatz verschwindet aus Listen und Auswahlfeldern, bleibt aber für Brühungen und Historie auflösbar. Brühungen und Pflegeereignisse dürfen
ebenfalls so gelöscht werden.

| Entität | Felder (Typ, Einheit) |
|---|---|
| Grinder (Mühle) | name; `scaleMin`, `scaleMax`, `scaleStep` (Dezimalzahl, Rasterstufe wie das Gerät wirklich rastet, z. B. 0.5); `finerDirection` (`down`\|`up`); `deadSpaceG` (g, Totraum/Retention) | <!-- octryx: allow-long-line -->
| Machine | name; `brewTempC` (°C); `preinfusionS` (s); `pressureProfile` (Text); `defaultWaterProfileId` |
| WaterProfile | name; `hardnessPpm` (ppm als CaCO₃, Pflicht, gespeichert); optional (nullable): `alkalinityPpm`, `tdsPpm`, `ph`, `sodiumMgL`, `chlorineMgL` |
| Bean | name; roaster; `roastLevel` (`light`\|`medium`\|`mediumDark`\|`dark`); `kind` (`espressoBlend`\|`filter`\|`allround`); `minStockG` (nullable = Standard); `leadTimeDays` (Lieferzeit, Standard 3, auf Bohnenebene) | <!-- octryx: allow-long-line -->
| Pack (Packung) | beanId; `roastDate`; `sizeG` (g); `remainingG` (g); `openedAt` (nullable) |
| Brew | `method` (`espresso`\|`v60`\|`chemex`\|`kalita`\|`aeropress`\|`batch`); `machineId` (Pflicht bei `espresso`, sonst null); grinderId; packId; `grindSetting`; `doseG`; `purgeG` (g, Standard 0, verworfener Totraum); `yieldG` (nur Espresso); `shotTimeS` (s, nur Espresso); `waterTempC`; waterProfileId; Filter: `waterTotalG`, `bloomG`, `pours` (Liste `{atS, cumulativeG}`), `drawdownS` (s); `taste` (`sour`\|`bitter`\|`weak`\|`balanced`); `rating` 1–5; note; `startedAt` | <!-- octryx: allow-long-line -->
| CareEvent | machineId oder grinderId; `kind` (`backflush`\|`descale`\|`grinderClean`); `doneAt` |
| Setting | `hardnessUnit` (`fH`\|`dH`\|`ppm`, Standard `fH`) |

**Onboarding-Flag (kein Datensatz der Tabelle):** Schlüssel `onboardingDone` (bool, Standard `false`), gespeichert mit `shared_preferences` (Android,
iOS; Chrome: `localStorage`). Das Flag hat weder `id` noch `updatedAt`, ist nicht Teil des JSON-Exports (Abschnitt 6) und wird vom Import nicht
verändert. Mühle und Bohne bleiben bis zum Folgeticket „Persistenz mit drift/SQLite“ (Ticket-ID wird beim Anlegen vergeben; es gehört nicht zu OE-74 und
nicht zu S1–S4) im Speicher (`AppData`) und gehen beim Neustart verloren; das ist eine bekannte Einschränkung. Die Persistenz liefert dieses Folgeticket.
Das Flag bleibt dabei erhalten.

Einheiten: g, ml, s, °C; Härte intern ppm. Wasser: 1 g = 1 ml. Welche Ruhezeit-Methode für eine Bohne gilt (`restMethod`): `espressoBlend` und
`allround` → Espresso (die längere Ruhezeit), `filter` → Filter.

## 4 Regeln und Formeln

**R1 Härte-Umrechnung.** 1 °fH = 10 ppm; 1 °dH = 17.848 ppm. Anzeige auf 1 Dezimale gerundet (kaufmännisch).
Beispiel: Eingabe 15 °fH → 150.0 ppm. Eingabe 8.4 °dH → 8.4 × 17.848 = 149.9 ppm. 150 ppm → 15.0 °fH und 150 / 17.848 = 8.4 °dH.

**R2 Wasserprüfung (Daten in `assets/water_rules.json`).** Bereiche: TDS 75–250 mg/L (Ziel 150); Gesamthärte 50–175 ppm; Alkalinität 40–75 ppm (Ziel
40); pH 6.5–7.5; Natrium ≤ 10 mg/L; Chlor ≤ 0 mg/L (also exakt 0; das Wasser-Formular erlaubt 0–10 mg/L als Eingabe, jeder Wert > 0 liegt ausserhalb SCA).
Ein Parameter mit Wert `null` wird nicht geprüft und zeigt „nicht gemessen“/„not measured“; er verhindert den Status „Im SCA-Bereich“ nicht.
Der Status lautet „Im SCA-Bereich“, wenn alle gemessenen Parameter im Bereich liegen, sonst „Ausserhalb SCA“; diese Empfehlung steht dann vor jeder anderen.
Beispiel: Leitungswasser 30 °fH = 300 ppm → 300 − 175 = 125 ppm über Maximum → „Wasser zuerst prüfen: Härte 300 ppm, SCA 50–175 ppm“. 15 °fH = 150
ppm, übrige Werte null → „Im SCA-Bereich“ (1 von 6 gemessen).

**R3 Ruhezeit.** `readyDate = roastDate + restDays(Methode, Röstgrad)`; erst ab `readyDate` trinkbereit. Mindest-Ruhetage (untere Grenze des Bereichs,
`assets/rest_rules.json`): Filter: light 7, medium 5, mediumDark 4, dark 3; Espresso: light 14, medium 10, mediumDark 7, dark 5. Eine Packung ist „zu
alt“, wenn heute ≥ `roastDate + 45` Tage. Zu alte Packungen zählen nicht als trinkbereit (nicht in `B`, nie als Vorschlag).
Beispiel: Röstdatum 2026-11-01, medium: Filter bereit 2026-11-06, Espresso bereit 2026-11-11, zu alt ab 2026-12-16 (1. Nov + 45 Tage).
Für Filter werden nur Packungen vorgeschlagen, die nach Filter-Ruhezeit bereit sind; Espresso-Blends (`kind = espressoBlend`) werden für Filter nicht
zuerst vorgeschlagen (nur nachrangig, wenn nichts anderes bereit ist). Sortierschlüssel einer Bohne in Listen: das früheste `readyDate` ihrer
Packungen (nach `restMethod`). Bohne ohne Packung: Sortierschlüssel nach Name (aufsteigend, hinter allen Bohnen mit Packung), kein Chip,
Bestands-Balken leer (Bestand 0, Rand `error` entfällt: ohne Packung gibt es noch keinen Bestand zu warnen).

**R4 Verbrauch.** `consumptionPerDay = Summe(doseG + purgeG aller Brühungen der Bohne in den letzten 28 Tagen) / 28`, ohne Rundung innerhalb der
Formel (Anzeige auf 1 Dezimale). Ohne Brühung in 28 Tagen: `consumptionPerDay = 0`.
Beispiel: 504 g in 28 Tagen → 504 / 28 = 18 g/Tag.

**R5 Mindestbestand und Bestellhinweis.** `minStockG = Bean.minStockG ?? 2 × consumptionPerDay`; bei `consumptionPerDay = 0` und ohne Bean-Wert: 100
g. `restDays` gemäss `restMethod` der Bohne (R3), `leadTimeDays` der Bohne. `orderPoint = consumptionPerDay × (leadTimeDays + restDays) + minStockG`.
Bestellhinweis, wenn Gesamtbestand der Bohne (alle nicht zu alten Packungen, auch ruhende) ≤ orderPoint.
Beispiel: 18 g/Tag, Lieferzeit 3, Ruhetage 10 (Espresso medium): Mindestbestand 36 g; orderPoint = 18 × (3 + 10) + 36 = 270 g. Bestand 250 g → Hinweis
„jetzt bestellen“ (250 / 18 = 13.9 Tage Reichweite). Bestand 300 g → kein Hinweis. Ohne Verbrauch: orderPoint = 0 × 13 + 100 = 100 g.

**R6 Lückenwarnung.** Nur wenn `consumptionPerDay > 0` (sonst keine Berechnung, keine Warnung). Trinkbereiter Bestand `B` = Summe `remainingG` der
Packungen mit `readyDate ≤ heute` und nicht zu alt (R3). `runOutDate = heute + floor(B / consumptionPerDay) − 1` (letzter gedeckter Tag; floor nur
hier). `nextReady` = früheste `readyDate` einer noch ruhenden Packung; gibt es keine, `heute + leadTimeDays + restDays` (Bestellung heute). Lücke von
`runOutDate + 1` bis `nextReady − 1`, wenn `nextReady > runOutDate + 1`. Warnung mit Datum von–bis. Aktion:
- trinkbereite, ungeöffnete Packung X vorhanden und keine geöffnete trinkbereite Packung mit Rest > 0 → „Packung X öffnen“ (X = früheste Röstung);
- geöffnete trinkbereite Packung vorhanden → „Jetzt bestellen“;
- keine trinkbereite Packung (B = 0) → „Jetzt bestellen“.
Beispiel 1 (ungeöffnete Packung X): heute 2026-11-16, B = 90 g, 18 g/Tag → floor(90/18) = 5 → runOutDate 2026-11-20; ruhende Packung bereit 2026-11-25
→ Lücke 2026-11-21 bis 2026-11-24 (4 Tage); Aktion „Packung X öffnen“.
Beispiel 2 (geöffnete Packung, keine ruhende): B = 90 g, nextReady = 16. Nov + 3 + 10 = 2026-11-29 → Lücke 2026-11-21 bis 2026-11-28; Aktion „Jetzt bestellen“.
Beispiel 3 (B = 0): runOutDate = 2026-11-15, Lücke 2026-11-16 bis 2026-11-28; Aktion „Jetzt bestellen“.

**R7 Totraum.** Bohnenwechsel = Wechsel der Bohnen-`id` an einer Mühle (nicht: neue Packung derselben Bohne oder anderer Röstgrad). Bei einem
Bohnenwechsel oder wenn die Mühle ≥ 24 h ungenutzt war (Standardwert ohne Quelle, in `assets/care_rules.json` änderbar) empfiehlt die App,
`deadSpaceG` vorab zu mahlen und zu verwerfen. Die Menge wird als `purgeG` der Brühung gespeichert. Bestandsabzug der Packung = `doseG + purgeG`.
Beispiel: Dosis 17 g, Totraum 2.5 g → 2.5 g verwerfen, dann 17 g; Abzug 19.5 g.

**R8 Reinigung (Daten `assets/care_rules.json`).** Pro Maschine werden die Espresso-Shots seit dem letzten Ereignis gezählt (Anzahl Brühungen mit
dieser `machineId`). Backflush fällig bei ≥ 200 Shots oder ≥ 7 Tagen seit letztem Backflush (was zuerst eintritt). Entkalken nach Härte des
Standard-Wasserprofils: > 150 ppm alle 30 Tage; 100–150 ppm alle 60 Tage; < 100 ppm alle 90 Tage. Das Maschinenhandbuch hat Vorrang (Hinweistext). Die
Mühlenreinigung ist nach 28 Tagen fällig (Standardwert ohne Quelle). Der Shot-Timer fliesst über die Shot-Anzahl und die Brühdaten ein; eine Summe der
Shot-Zeiten wird nicht geführt.
Beispiel: Letzter Backflush 2026-11-10, bis 2026-11-16 insgesamt 90 Shots → 6 Tage, nicht fällig; am 2026-11-17 fällig (7 Tage). Wasser 120 ppm,
letztes Entkalken 2026-10-01 → fällig 2026-11-30 (1. Okt + 60 Tage).

**R9 Espresso-Empfehlung (genau eine Variable).** Ein einziges Band für Ziel und „keine Änderung“: Shot-Zeit 25–30 s (Standardverhältnis 1:2, 18 g →
36 g). Prüfreihenfolge, die erste zutreffende gewinnt, und nur sie wird genannt: (1) Wasser ausserhalb R2 → Wasser; (2) Packung vor Espresso-Ruhezeit
(R3) → „noch ruhen lassen“; (3) Mahlgrad. Mahlgrad: **die Shot-Zeit hat Vorrang vor dem Geschmack** (Quelle: erst Zeitfenster per Mahlgrad, dann
Geschmack):
- Zeit < 25 s → feiner; Zeit > 30 s → gröber (unabhängig vom Geschmack); Schrittweite 2 Rasterstufen bei Zeit < 20 s oder > 35 s, sonst 1;
- Zeit 25–30 s: `sour` oder `weak` → feiner, `bitter` → gröber, je 1 Rasterstufe; `balanced` → keine Änderung.
„Feiner“ bedeutet Skalenrichtung `finerDirection`. Ergebnis wird auf `scaleMin..scaleMax` begrenzt. Jede Empfehlung hat `reason` und `source` (URL).
Beispiel: Mühle Skala 1–30, Schritt 0.5, feiner = abwärts; Einstellung 12.0, sauer, 27 s, Wasser im Bereich, Packung bereit → 11.5 (1 Stufe feiner).
Bitter, 17 s → Zeit gewinnt: feiner, 2 Stufen → 11.0. Weak, 40 s → gröber, 2 Stufen → 13.0. Sauer, 38 s → gröber, 2 Stufen → 13.0. Ausgewogen, 22 s →
feiner, 1 Stufe → 11.5. Ausgewogen, 27 s → keine Änderung. Einstellung 1.0 und feiner → bleibt 1.0 mit Hinweis „Skalenende“.

**R10 Filter-Rezept.** Wasser `W = dose × ratio` (Standard 1:16, erlaubt 1:14–1:18, Schritt 0.5, Auflösung 1 g). Bloom = 2 × Dosis bei 0:00 für 45 s;
Zwischensummen (kumulatives Wasser) nach 0:45: round(0.375 × W); nach 1:15: round(0.6875 × W); nach 2:00: W. Ziel-Gesamtzeit 3:00–3:30 (180–210 s);
Wassertemperatur 92–96 °C. Abfluss > 4:00 → gröber, < 2:45 → feiner.
Beispiel: 20 g, 1:16 → W = 320; Bloom 40 g; Summen 120 g (0:45), 220 g (1:15), 320 g (2:00). 15 g, 1:15 → W = 225; Bloom 30; 0.375 × 225 = 84.4 → 84;
0.6875 × 225 = 154.7 → 155; 225.

**R11 Filter-Empfehlung (genau eine Variable: Mahlgrad).** Prüfreihenfolge wie R9: (1) Wasser (R2); (2) Packung vor Filter-Ruhezeit (R3); (3) Mahlgrad
nach `drawdownS` (Zeit hat Vorrang vor Geschmack): `drawdownS` > 240 s → gröber, < 165 s → feiner (je 1 Stufe; 2 Stufen bei > 270 s oder < 150 s;
Schwellen 270/150 sind Standardwerte ohne Quelle); im Fenster 165–240 s: `sour`/`weak` → feiner, `bitter` → gröber (1 Stufe), `balanced` → keine
Änderung. Das Verhältnis wird nie automatisch empfohlen. Quelle der 240/165-s-Grenzen: Coffee Hero (Abfluss > 4:00 bzw. < 2:45).
Beispiel: Mühle Skala 1–30, Schritt 0.5, feiner = abwärts; Einstellung 20.0, Abfluss 255 s, bitter → gröber 1 Stufe → 20.5. Abfluss 150 s → 150 ist
nicht < 150, also 1 Stufe feiner: 19.5; Abfluss 140 s → 2 Stufen feiner: 19.0. Abfluss 200 s, sauer → 19.5.

**R12 Onboarding-Ablauf:** vollständig in `SPEC-ONBOARDING.md` (4 Seiten, Flag-Logik, Fehlerfälle, Heute-Regel für Bohnen ohne Packung, Beispiel).

## 5 Defaults, Grenzen, Reihenfolge, leere Daten, Fehler

- Defaults: Härteeinheit °fH; Lieferzeit 3 Tage; Verhältnis 1:16; Mindestbestand 2 Tage Verbrauch, ohne Historie 100 g; Backflush 7 Tage/200 Shots.
- Grenzen: Dosis 5–40 g; Filter-Verhältnis 14–18; Espresso-Ausbeute 1–4 × Dosis; **Espresso-Shot-Timer `shotTimeS` 1–120 s; Filter-Timer `drawdownS`
  und Gesamtzeit 1–600 s** (R10 Ziel 180–210 s ist zulässig); Bewertung 1–5; Name 1–60 Zeichen; Packungsgrösse `sizeG` 50–5000 g; `remainingG`
  0..`sizeG`; Ruhetage nie negativ.
- Bestandsabzug: eine Brühung mit `doseG + purgeG` > `remainingG` der Packung wird abgelehnt („Nicht genug Bohnen in der Packung (Rest {n} g)“ / „Not
  enough beans in the pack ({n} g left)“); `remainingG` wird nie negativ.
- Mahlgrad-Eingabe muss in `scaleMin..scaleMax` liegen und ein Vielfaches von `scaleStep` ab `scaleMin` sein; sonst Fehler (DE „Wert liegt nicht auf
  der Skala der Mühle (Schritt {step})“, EN „Value is not on the grinder's scale (step {step})“).
- Reihenfolge: Bohnenlisten nach frühestem `readyDate` ihrer Packungen aufsteigend (trinkbereite zuerst); Brühungen nach `startedAt` absteigend;
  Pflege nach Fälligkeit.
- Leere Daten: keine Verbrauchshistorie → `consumptionPerDay = 0`, Mindestbestand 100 g, keine Lückenwarnung; keine Packung → R6 Beispiel 3 nur bei
  Verbrauch > 0; kein Wasserprofil → Empfehlung „Wasserwerte erfassen“; keine Mühle → Brühung nicht speicherbar, Hinweis „Zuerst eine Mühle anlegen“;
  Espresso ohne Maschine → nicht speicherbar, Hinweis „Zuerst eine Maschine anlegen“.
- Onboarding (R12): Mühle und Bohne verwenden dieselben Felder, Grenzen und Fehlermeldungen (Zeile unter dem Feld) wie ihre normalen Formulare;
  Pflichtfelder der Mühle: Name, `scaleMin`, `scaleMax`, `scaleStep`, `deadSpaceG`; Standard `finerDirection` = `down`. Pflichtfelder der Bohne:
  Name, Röster, Röstgrad, Art; Standard `leadTimeDays` 3, `minStockG` leer. Ungültige Eingabe → Seite bleibt, Fehler am Feld, nichts gespeichert.
  Nach erfolgreichem Speichern auf Seite 3 geht es automatisch zu Seite 4, auf Seite 4 gilt „Los geht’s“ (R12).
  Keine Standardwerte für Maschine oder Wasserprofil. Systemzurück auf Seite 1 beendet nichts; ab Seite 2 geht Zurück eine Seite zurück.
  Schreibfehler des Flags: Fehlerbanner mit „Erneut versuchen“, Nutzer bleibt auf der Seite (R12).
- Regelwerte stehen als Daten in `assets/*.json`; jeder Regel-Eintrag hat `source` (URL) und `retrieved` (Datum). Einträge ohne recherchierte Quelle
  tragen `source: "none"`; die UI zeigt sie als „Standardwert ohne Quelle“.
- Für Chemex, Kalita, AeroPress und Batch gilt vorerst das V60-Schema (R10) mit Quelle „none“; nur das V60-Schema ist recherchiert.

## 6 Schnittstellen und Formate

**JSON-Export** (Datei `coffee-export-YYYY-MM-DD.json`, UTF-8):
`{"schemaVersion":1,"exportedAt":"<ISO>","grinders":[],"machines":[],"waterProfiles":[],"beans":[],"packs":[],"brews":[],"careEvents":[],"settings":{}}`;
jedes Element enthält die Felder aus Abschnitt 3 (inkl. `deletedAt`).
**Auslieferung:** Android und iOS: System-Share-Sheet mit der Datei `coffee-export-YYYY-MM-DD.json`; Chrome: Browser-Download mit demselben
Dateinamen. Import: Dateiauswahl (File Picker) auf allen Plattformen.
**Import:** Datensätze mit gleicher `id` werden übernommen, wenn `updatedAt` neuer ist als der lokale Wert, sonst übersprungen; da Löschen `updatedAt
= deletedAt` setzt, gewinnt ein neueres `deletedAt` (Datensatz wird gelöscht) und ein älteres verliert. Verweist ein Datensatz auf eine `id`, die
weder in der Datei noch lokal existiert, wird er übersprungen und im Ergebnis gezählt („{n} Datensätze übersprungen“ / „{n} records skipped“).
Unbekannte `schemaVersion` → Fehler „Dateiversion nicht unterstützt“ / „File version not supported“, nichts wird geändert. Der Import läuft in einer
Transaktion.
**Onboarding-Flag:** Schlüssel `onboardingDone`, Typ bool, Lesen beim Start (Standard `false`, bei Lesefehler `true`), Schreiben `true` einmal
beim Abschluss oder Überspringen (bei Fehler wiederholbar mit „Erneut versuchen“, R12). Das Flag steht nicht im JSON-Export; der Import ändert es nicht.
Auf Chrome gilt die Reload-Garantie pro Browserprofil und Origin (`localStorage`); Browserdaten löschen zeigt es erneut.
**Regel-Assets:** `assets/water_rules.json`, `rest_rules.json`, `care_rules.json`, `brew_rules.json`; Format
`{"version":1,"rules":[{"key":"...","value":...,"source":"<URL>","retrieved":"2026-11-16"}]}` (`retrieved` pro Eintrag).
**Lokalisierung:** Texte pro Feature in `lib/features/<feature>/l10n/de.arb` und `en.arb` (Onboarding: `lib/features/onboarding/l10n/`, Schlüssel
mit Präfix `onboarding`, z. B. `onboardingWelcomeTitle`); zusammengeführt zu `lib/l10n/app_de.arb`, `app_en.arb` mit
`octryx-claude l10n-merge arb 'lib/features/*/l10n/<lang>.arb' lib/l10n/app_<lang>.arb` (nie von Hand bearbeiten); Sprache = Systemsprache, Fallback Englisch.
Alle deutschen Varianten verwenden das Format von
de-CH (Dezimalpunkt `15.5`, Datum `16.11.2026`); Englisch: Dezimalpunkt, Datum `16 Nov 2026`.

## 7 Nicht-funktionale Anforderungen

- Offline first: alle Funktionen ohne Netz; keine Netzwerkzugriffe zur Laufzeit.
- Performance: Mit 1000 Brühungen in der Liste wird jeder Frame beim Scrollen auf dem Emulator in höchstens 16 ms gebaut; die Empfehlung (R9/R11) wird
  in unter 50 ms berechnet.
- Barrierefreiheit: Kontrast Text/Hintergrund ≥ 4.5:1, Fokusring 2 dp, Touch-Ziele ≥ 48 × 48 dp, Semantics-Labels für alle Icon-Buttons.
- Code Style (Team-Konvention): max. 300 Zeilen pro Quelldatei, Tests max. 500, generierte Dateien ausgenommen; Struktur `lib/app`, `lib/core`,
  `lib/features/<feature>/{data,domain,presentation}`; eine Klasse bzw. ein Widget pro Datei; `test/` spiegelt `lib/`; `///`-Doc-Kommentare für
  öffentliche APIs; Inline-Kommentare nur für das Warum; kein auskommentierter Code; offene Aufgaben im Code nur mit Ticketnummer;
  Gate in `environment.json`: `dart format --set-exit-if-changed`, `flutter analyze` (flutter_lints, strikt) und Zeilenprüfung `tool/check_lines.dart`.
- `tool/check_lines.dart` wird in der ersten Story (Projekt-Grundgerüst) angelegt. Abnahme: Exit 0, wenn alle Dateien in `lib/` ≤ 300 und in `test/` ≤
  500 Zeilen haben; Exit 1 mit Ausgabe `<Pfad>: <Zeilen>` für jede Datei darüber (Test: eine Datei mit 301 Zeilen in `lib/` → Exit 1). Ausgenommen:
  `*.g.dart`, `*.freezed.dart`, `lib/l10n/app_localizations*.dart`.
- Tests: Unit-Tests für R1–R11 mit den Zahlen aus Abschnitt 4. Playwright-Systemtests in Chrome (Flutter-Web-Build), ein Szenario pro UC mit erwartetem Wert:
  - UC1: Mühle „M1“ (Skala 1–30, Schritt 0.5, Totraum 2.5 g) anlegen → Karte „M1“ zeigt „2.5 g“.
  - UC2: Bohne medium, Röstdatum heute − 12 Tage, anlegen → Chip „Bereit“.
  - UC3: Espresso 18 g → 36 g in 27 s speichern → Liste zeigt „27 s“.
  - UC4: Brühung sauer, 27 s, Mahlgrad 12.0 → Karte „Empfehlung“ zeigt „Mahlgrad auf 11.5“.
  - UC5: 20 g, 1:16 → Fokus-Modus zeigt „Giesse bis 40 g“, dann „120 g“, „220 g“, „320 g“.
  - UC6: Wasser 30 °fH → Status „Ausserhalb SCA“ und Anzeige „300 ppm“ nach Wechsel auf ppm.
  - UC7: Backflush 7 Tage her → Pflege zeigt „Fällig“; nach „Erledigt“ „In 7 Tagen“.
  - UC8: 90 g, Verbrauch 18 g/Tag, nächste Packung in 9 Tagen bereit → Banner „Kein trinkbereiter Kaffee vom 21.11.2026 bis 24.11.2026“ (bei heute 2026-11-16).
  - UC9: Export, Daten löschen, Import → Bohnenliste enthält wieder „Bohne 1“.
  - UC10 (drei Szenarien): „Überspringen“ auf Seite 1 → Heute sichtbar; „Abschliessen mit Mühle und Bohne“ (M1, Bohne 1) → Ausrüstung zeigt „M1“ und
    „2.5 g“, Bohnenliste zeigt „Bohne 1“; „Reload zeigt es nicht erneut“ → nach Reload ist Heute sichtbar, „Willkommen“ nicht.
  - Unit-Tests Flag-Logik: neu → Onboarding; erledigt → Heute; übersprungen → Heute; Lesefehler → Heute. Widget-Tests für jede der 4 Seiten.
- Jede Story aktualisiert `README.md` und `CHANGELOG.md`.
- Datenschutz: Daten verlassen das Gerät nur durch den ausdrücklichen JSON-Export.

## UI und Design

Die vollständige UI- und Design-Spezifikation (Onboarding-Screen, LF13) steht bewusst in SPEC-UI.md (Aufteilung bestätigt).

## 8 Entscheidungen

1. Team-Code-Style gilt wie in Abschnitt 7 (PO-Antwort 1).
2. Lokale Speicherung mit drift/SQLite, offline first, JSON-Export/-Import; stabile IDs und `updatedAt`; Cloud-Sync später (Abschnitt 3, 6).
3. Ein Nutzer, kein Login (Abschnitt 1).
4. Deutsch und Englisch nach Systemsprache (Abschnitt 6).
5. Schweizer Einheiten: Härte-Eingabe °fH (Standard), °dH, ppm, Speicherung ppm; g, ml, s, °C (R1).
6. Websuche beim Spec-Schreiben, Quellen zitiert; Regelwerte als Daten mit Quelle und Datum (Abschnitt 5, 6).
7. Mühlen: eigene Skala (Min, Max, Schritt) und Totraum pro Mühle (Abschnitt 3, R7, R9).
8. Maschinen: Brühtemperatur, Preinfusion, Druckprofil, Standard-Wasserprofil (Abschnitt 3).
9. Bestand: Mindestbestand 2 Tage Verbrauch, ohne Historie 100 g; Bestellhinweis nach R5; Lückenwarnung nach R6.
10. Alle weiteren Vorschläge übernommen (Defaults aus Abschnitt 5, 4).
11. Empfehlungen: eine Variable, in Rasterstufen der Mühle (1–2), Wasser zuerst, mit Grund und Quelle (R9, R11).
12. Filter: Methoden V60/Chemex/Kalita/AeroPress/Batch, Verhältnis Standard 1:16 (1:14–1:18), Bloom und Aufgüsse mit Zwischensummen und Timer, nur
    ruhezeit-fertige Packungen, Espresso-Blends nicht zuerst (R3, R10); README.md und CHANGELOG.md in jeder Story (Abschnitt 7).
13. Wasserbereich: Gesamthärte 50–175 ppm und Alkalinität 40–75 ppm (SCA-Handbuch „Core Zone“); Quellen nennen daneben Calcium-Härte 17–85 mg/L – nur
    Daten-Asset, änderbar (R2).
14. Ruhetage = untere Grenze der Bereichs-Tabelle (R3).
15. Annahmen aus der Review-Revision (einfachste passende Option): Zeit vor Geschmack bei Espresso und Filter (R9, R11); ein Band 25–30 s (R9);
    Filter-Empfehlung nur Mahlgrad (R11); Lieferzeit auf Bohnenebene (Abschnitt 3); `restMethod` espresso für `espressoBlend`/`allround` (Abschnitt
    3); Soft-Delete statt hartem Löschen (Abschnitt 3); fehlende Referenzen beim Import werden übersprungen (Abschnitt 6); alle deutschen Locales im
    Format de-CH (Abschnitt 6); zu alte Packungen zählen nicht als trinkbereit (R3); Shot-Zeiten-Summe entfällt (R8); Warnfarbe #8A5A00 wegen Kontrast
    (Tokens).
16. OE-74 Onboarding (alle Vorschläge und Defaults vom PO übernommen):
    - Persistenz des Flags: `shared_preferences`, Schlüssel `onboardingDone` (bool, Standard `false`), erst bei Abschluss/Überspringen gesetzt
      (Abschnitt 3, R12). Mühle und Bohne bleiben bis zum Folgeticket „Persistenz mit drift/SQLite“ (ID folgt, nicht Teil von OE-74) im Speicher
      (`AppData`), bekannte Einschränkung (Abschnitt 1, 3).
    - Erscheint nur, wenn `onboardingDone` fehlt, unabhängig von vorhandenen Daten; Import ändert nichts (R12).
    - 4 Seiten: Willkommen, Funktionen (3 Punkte), Mühle, Bohne; Maschine und Wasser nicht Teil (R12).
    - Mühle und Bohne je einzeln mit „Später“ überspringbar; Fortschritt „k von 4“ (R12).
    - „Überspringen“ auf jeder Seite ohne Rückfrage, setzt `onboardingDone`, führt zu Heute; erfasste Daten bleiben (R12, UI).
    - Abbruch mitten drin: Onboarding gilt als nicht erledigt, startet von vorn, nichts doppelt (R12).
    - Kein erneutes Anzeigen, kein Eintrag in den Einstellungen (Abschnitt 1).
    - Formulare wie Mühlen-/Bohnenformular, Bohne ohne Packung (Abschnitt 5).
    - Zurück ab Seite 2; Systemzurück auf Seite 1 beendet nichts (Abschnitt 5).
    - 4 Stories: S1 Flag und Routing (`onboardingDone`) mit „Überspringen“ auf der Willkommensseite (Seite 1: „Überspringen“ setzt das Flag und
      führt zu Heute), S2 Infoseiten, S3 Mühle, S4 Bohne; README und CHANGELOG pro Story.
    - Look: „Warme Rösterei“ (Variante A), Kopf 160 dp (`onboardingHeaderHeight`) mit Verlauf und Icon, Punkte als Fortschritt (UI).
    - Vollbild ohne Navigation, Spalte max. 480 dp (`onboardingMaxWidth`), „Weiter“ primär, „Zurück“ und „Überspringen“ als Textschaltflächen (UI).
    - Lesefehler des Flags → gilt als erledigt (R12); Texte DE/EN in `lib/features/onboarding/l10n/de.arb` und `en.arb`, Merge mit
      `octryx-claude l10n-merge arb` (Abschnitt 6); Seite 2 nennt drei Punkte (R12); gleiche Validierung wie normale Formulare (Abschnitt 5);
      Seite 3: nach Speichern automatisch Seite 4; Seite 4: nach Speichern „Angelegt: {Name}“ und „Los geht’s“ → Heute; je nur einmal anlegbar
      (R12); Zurückgehen legt nicht neu an (R12); keine Standardwerte für Maschine/Wasser (Abschnitt 5); Touch-Ziele ≥ 48 dp
      (`minTouchTarget`), Fokusring 2 dp (`focusRingWidth`) (UI).
    - Annahmen der Review-Revision (einfachste passende Option): Schreibfehler des Flags → Fehlerbanner mit „Erneut versuchen“, Nutzer bleibt auf
      der Seite (R12); Bohne ohne Packung erscheint in Heute in der Region „Ohne Packung“ (R12, UI); Sortierung nach Name hinter Bohnen mit
      Packung (R3); Pflichtfelder der Mühle und Standard `finerDirection` = `down` (Abschnitt 5); die UI-Spezifikation bleibt in `SPEC-UI.md`;
      `onPrimary` und dunkles `primary` als Tokens (UI).
    - Tests: Unit (Flag), Widget (je Seite), Playwright „Überspringen“, „Abschliessen mit Mühle und Bohne“, „Reload zeigt es nicht erneut“; UC10 und
      LF13 (Abschnitt 7, UI).
    - Chrome: `localStorage` über `shared_preferences`, Reload-Garantie pro Browserprofil (Abschnitt 6).

## 9 Offene Fragen

Keine vom PO ausdrücklich offen gelassenen Fragen.

## Sources

- https://www.percolateapp.com/articles/how-long-to-rest-coffee-after-roasting (Ruhezeiten, Staleness; geöffnet)
- https://seelaz.com/blogs/barista-academy/water-for-coffee-sca (SCA-Wasserwerte; geöffnet)
- https://www.merakitech.com/blogs/machine-guides/a-home-barista-cleaning-schedule-daily-weekly-monthly (Reinigungsrhythmus; geöffnet)
- https://coffeehero.com.au/blogs/news/v60-golden-ratio-the-1-16-pour-over-recipe (V60 1:16, Bloom, Zwischensummen, Abfluss-Grenzen; geöffnet)
- https://coffeestudies.com/barista-skills/dialing-in-espresso (Dial-in: 1:2, 25–30 s, eine Variable; aus Suchergebnis)
- https://clivecoffee.com/blogs/learn/dialing-in-espresso-by-taste (Sauer/bitter-Korrektur; aus Suchergebnis)
- https://www.thehomebaristasquill.com/p/how-to-backflush-and-descale-your (Backflush alle 200 Shots/wöchentlich, Entkalken nach Härte; aus Suchergebnis)
- https://pub.dev/packages/shared_preferences (Onboarding-Flag: Plattformen Android/iOS/Web, Web = LocalStorage, keine Schreibgarantie, nicht für kritische Daten; geöffnet) (new research) <!-- octryx: allow-long-line -->
- https://www.nngroup.com/articles/mobile-tutorials/ (Onboarding kurz, Skip gut sichtbar; aus Suchergebnis) (new research)
- https://decode.agency/article/app-onboarding-best-practices/ (Onboarding-Hintergrund; der abgerufene Auszug bestätigt „Skip“ und Fortschrittsanzeige nicht, die Entscheidung stützt sich auf PO-Antworten 4–5; geöffnet) (new research) <!-- octryx: allow-long-line -->
- https://www.eleken.co/blog-posts/mobile-app-onboarding-best-practices (Onboarding-Hintergrund: Onboarding führt vom ersten Öffnen zum Verständnis des Nutzens; Auszug ohne Aussage zu Skip oder Schrittzähler; geöffnet) (new research) <!-- octryx: allow-long-line -->
