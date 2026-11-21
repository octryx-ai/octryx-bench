# Kaffee-Begleiter (Flutter) – Spezifikation OE-80

App-Ordner: `coffee/flutter/codex` . Ziel: Android und iOS; lokal getestet auf dem Android-Emulator und in Chrome.

Neue App; vorhandene andere Benchmarks sind ausschliesslich Referenzmaterial. Kein
Code wird in dieser Phase implementiert.

## 1 Ziel und Scope

**Ziel:** Eine App, die einen Kaffeeliebhaber beim Kaffeegenuss führt: Brühungen mit Maschine, Mühle, Einstellungen und Shot-Timer erfassen;
Bohnenbestand und Ruhezeit führen; Wasserwerte prüfen; Reinigungsintervalle aus der Nutzung ableiten; nach Geschmacksrückmeldung genau eine
Verbesserung empfehlen (Espresso und Filter); Filterkaffee Schritt für Schritt mit Gramm-Zwischensummen und Timer anleiten.

**In Scope:** mehrere Mühlen (Beispiel: 4 Typen) und Maschinen; Bohnen mehrerer Röster, dieselbe Bohne mehrfach (Packungen); Bestell- und
Lückenwarnung; Wasserprofile; Espresso und Filter (V60, Chemex, Kalita, AeroPress, Batch); lokale Speicherung; JSON-Export/-Import; Deutsch und
Englisch.

**Out of Scope:** Login, mehrere Nutzer, Cloud-Sync (späteres Epic; das Datenmodell ist dafür vorbereitet), Bestell-Abwicklung bei Röstern,
Web-Release als Produkt (Chrome dient nur zum Testen).

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

## Verbindliche Spezifikationsmodule

Die folgenden verlinkten Module sind verbindlicher Bestandteil dieser Spezifikation.

- [3 Domänenmodell](docs/spec/domain.md)
- [4 Regeln und Formeln](docs/spec/rules.md)
- [5 Defaults](docs/spec/interfaces.md)
- [7 Nicht-funktionale](docs/spec/quality.md)
- [UI und Design](docs/spec/design.md)
- [Verbindliche Ergänzungen](docs/spec/contracts.md)
- [Vollständiger Bildschirmvertrag](docs/spec/screens.md)
- [Akzeptanzkriterien](docs/spec/acceptance.md)

<!-- spec-studio:tokens -->
### Design tokens (approved in the Spec Studio, v1, exact)

Direction: Warme Rösterei. Fonts: headings `Fraunces`, text `Inter`, numbers `JetBrains Mono`. Radius `16` px.

| Token | Light | Dark |
|---|---|---|
| `bg` | #FBF6EF | #1F1814 |
| `surface` | #F0E6D8 | #2B211B |
| `text` | #2A1E17 | #F3E9DD |
| `muted` | #6B584B | #C5B4A6 |
| `accent` | #8A4B2A | #DFA77D |
| `ok` | #36703F | #7CC28E |
| `warn` | #8A5A00 | #E0B050 |
| `error` | #B3261E | #F2B8B5 |
<!-- /spec-studio:tokens -->

## 8 Entscheidungen

Review-Präzisierungen (ersetzen unvollständige Kurzfassungen in den verlinkten Modulen):

- §7: Stilgrenzen werden von `max_lines_per_file` = 300, `tests_max_lines` = 500,
  `max_function_lines` = 60 und `max_line_length` = 160 getragen; Gates in `environment.json`
  mit `dart format`, `flutter analyze --no-pub`, `flutter_lints` und `tool/check_lines.dart`.
- §3/6: Feste Einheiten `massUnit` = `g`, `waterVolumeUnit` = `ml`, `durationUnit` = `s`,
  `temperatureUnit` = `°C`; Härte-Eingabe `hardnessUnit`, Speicherung `hardnessPpm`.
- R4/R5: `leadTimeDays` = 3 Tage und `consumptionWindowDays` = 28 vollständige lokale Tage.
- R8: Regel-Asset-Schlüssel `care.backflush.days` = 7 Tage, `care.backflush.shots` = 200,
  `care.descale.hardDays` = 30 Tage, `care.descale.mediumDays` = 60 Tage,
  `care.descale.softDays` = 90 Tage, `care.grinderClean.days` = 28 Tage;
  Härteschwellen `care.descale.hardnessHighPpm` = 150 und
  `care.descale.hardnessLowPpm` = 100. Persistierte Geräte-Overrides stehen in `domain.md`.
- Annahmen: `brewSecondsLimit` gilt nur für Backflush; `roundHalfUp` rundet Wasser/Bloom
  vor der Aufgussplanung auf ganze Gramm; Restore-Tests verwenden eine frische Datenbank.
  Pausen werden mit `pausedAt` und `accumulatedPausedMs` über Neustarts erhalten.

1. Neue Flutter-App Android/iOS unter `coffee/flutter/codex` ; Chrome und Android-Emulator als lokale Testziele (`flutter`, §1/7).
2. Team-Struktur, eine Klasse/Widget pro Datei, 300/500 Zeilen, Funktionen maximal 60 Zeilen, Zeilenlänge maximal 160, Tests spiegeln lib, öffentliche
  API dokumentiert; Gates `flutter_lints` , `check_lines.dart` , `environment.json` (§7).
3. Lokale persistente Daten, offline first und Transaktionen mit `drift` /SQLite; kein flüchtiger Ersatz als fertige Speicherung; stabile `id` ,
  `updatedAt` , JSON-Import/Export, Cloud später (§3/6).
4. Ein Nutzer ohne Login (`singleUserMode`, §1); Systemsprache Deutsch/Englisch, Englisch als Fallback (`supportedLocales`, §6).
5. Schweizer Einheiten, Standard °fH (`hardnessUnit`), intern `hardnessPpm` ; g/ml/s/°C (§3, R1).
6. Recherche bei Spezifikation, keine Laufzeit-Websuche; datengetriebene Quellen und Abrufdatum (`assets/*.json`, `source` , `retrieved` , §5/6).
7. Mehrere Mühlen mit eigener echter Skala, Schritt und Richtung sowie Totraum (`scaleMin`, `scaleMax` , `scaleStep` , `finerDirection` , `deadSpaceG`
  , §3/R7).
8. Maschinenparameter und Standardwasser (`brewTempC`, `preinfusionS` , `pressureProfile` , `defaultWaterProfileId` , §3).
9. Mindestbestand zwei Verbrauchstage oder ohne Historie 100 g (`minStockG`); Bestellformel mit Lieferzeit und Ruhezeit, konkrete Lücken von–bis samt
  Aktion (`orderPoint`, `runOutDate` , `nextReady` , R4–R6).
10. Empfehlung ändert genau eine Variable in 1–2 echten Rasterstufen, Wasser zuerst, Grund und Quelle (`grindSetting`, `reason` , `source` , R9/R11).
11. Filtermethoden V60/Chemex/Kalita/AeroPress/Batch (`method`); Verhältnis 16 mit Grenzen 14–18 (`ratio`), Bloom und Aufgüsse mit Timer (`bloomG`,
  `pours` ), nur bereite Packungen, Espresso-Blends nachrangig (R3/R10).
12. Jede Story aktualisiert `README.md` und `CHANGELOG.md` (§7).
13. Übernommene Defaults: Lieferzeit 3 (`leadTimeDays`), Verbrauchsfenster 28 (`consumptionWindowDays`), Totraumhinweis ab 24 h (`idleHours`),
  Altershinweis ab 45 Tagen (`staleDays`), Ruhezeit-Tabelle (`restDays`), Rösterei-Design (`AppTokens`), Fraunces/Inter lokal (`fontFamily`) (§4/UI).
14. Übernommene Brühdefaults: Espresso 1:2, 25–30 s (`espressoRatio`, `espressoTimeMinS` , `espressoTimeMaxS` ); Zeit vor Geschmack; Filterplan R10,
  Filter-Empfehlung nur Mahlgrad (`filterRecipe`, `recommendationPriority` , R9–R11).
15. Pflege-Defaults 7 Tage/200 Shots, Entkalkung 30/60/90 Tage und Mühle 28 Tage sind editierbare Erinnerungen (`careRules`); tatsächliche
  Shot-Sekunden verfügbar (`brewSeconds`, `brewSecondsLimit` ), Geräte-Eignung vor Backflush (`backflushSupported`, R8).
16. Sonstige übernommene Defaults: Soft Delete (`deletedAt`), Import neuerer Datensatz gewinnt (`updatedAt`), fehlende Referenzen überspringen
  (`skippedCount`), de-CH-Format (`AppFormat`), Warnfarbe #8A5A00 (`warning`), kein automatischer Bestellvorgang (§3/6/UI).
17. Jede Zahl in §4/5 und jedes UI-Token ist ein Produktdefault, soweit nicht ausdrücklich als Quellenwert bezeichnet; identische Namen in
  Regel-Assets und Tests verwenden (`ruleKey`). Keine vom PO ausdrücklich offen gelassene Entscheidung wird erfunden.

<!-- spec-studio:decisions -->
### Spec Studio decisions (v1)

- SS1. `design.direction`: Warme Rösterei (proposal accepted).
<!-- /spec-studio:decisions -->

## 9 Offene Fragen

Keine. Alle weiteren Vorschläge wurden vom PO übernommen; die ausführbaren Akzeptanztests werden erst in der dafür vorgesehenen Phase erstellt.

## Sources

Recherche am 18.11.2026. Repository-Referenzen:
`coffee/flutter/claude/SPEC.md` , `README.md` , Regel-Assets und Mühlen-Skalenvalidierung, sowie `coffee/web/codex/SPEC.md` . Root-`README.md`
existiert nicht. Diese Dateien sind keine bestehende Spezifikation der neuen App.

- S1 (new research): https://www.percolateapp.com/articles/how-long-to-rest-coffee-after-roasting — geöffnet; Ruhezeitfenster nach Röstgrad/Methode,
  Untergrenzen in R3 als Schätzung. 45-Tage-Ausschluss ist Produktdefault.
- S2 (new research): https://seelaz.com/blogs/barista-academy/water-for-coffee-sca — geöffnet; sekundäre Wasser-Erläuterung, keine Maschinenfreigabe.
- S3 (new research): https://coffeehero.com.au/blogs/news/v60-golden-ratio-the-1-16-pour-over-recipe — geöffnet; V60 20 g/320 g, Bloom 40 g, kumulativ
  120/220/320 g; Skalierung und andere Methoden sind Produktdefaults.
- S4 (new research): https://clivecoffee.com/blogs/learn/how-to-dial-in-your-espresso-grinder-clive-coffee — gesucht und geöffnet; 18 g/36 g, 25–30 s,
  kleine einzelne Änderungen. Entscheidungsbaum und Zwei-Schritt-Grenzen sind Produktheuristik.
- S5 (new research):
  https://static1.squarespace.com/static/587af1d4db29d69a1a226b95/t/60747196b54d702410bd802a/1618243990452/SCA%2BWater%2BChart-US-Letter.pdf —
  gesucht; Fetch liefert PDF-Binärtext, nicht für numerische Transkription verwendet. Historischer Calciumhärtebereich nicht mit Gesamthärte
  gleichsetzen.
- S6 (new research): https://www.espresso-services.com/hubfs/Slayer%20Espresso%20v3%20Spech%20Sheet.pdf — Suchergebnis nennt tägliche
  kommerzielle/wöchentliche Heimreinigung; Fetch liefert PDF-Binärtext. Keine Übertragung auf unbekannte Maschinen; R8 bleibt Produktdefault mit
  Handbuchvorrang.

