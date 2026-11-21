### Akzeptanzkriterien (identisch mit Spec Studio)

Review-Präzisierungen haben Vorrang bei AC5, AC7, AC11, AC14 und AC16:

- **AC5** gilt nur für M1 mit Skala 1–30, Schritt 0.5, feiner abwärts; Wasser im
  Referenzbereich, Packung für Espresso bereit, nicht alt, Einstellung 12.0, sauer, 27 s.
- **AC7** ergänzt den Bruchfall: 15.25 g × 15 → 229 g, Bloom 31 g,
  kumulativ 31/86/157/229 g, inkrementell 31/55/71/72 g.
- **AC11/AC16** stellen in eine frische Datenbank wieder her. Ein neuerer Tombstone
  gewinnt ausdrücklich gegen einen älteren Export-Datensatz, auch bei einem Restore-Versuch.
- **AC14** prüft Textkontrast ≥4.5:1 auch für Grosstext; ungemessene Wasserparameter
  zeigen nur Text ohne Messwertbalken; orderPoint 0 hat keine Division oder Schwellenmarke.
- **AC19** Nur 56 g bestätigtes Waste in 28 Tagen → Verbrauch 2 g/Tag, Mindestbestand 4 g.
- **AC20** Leere/alte Packungen machen eine Bohne nicht Gruppe 0. A nur ruhend bis25.11.,
  B mit 50 g bereit seit11.11. → B vor A, trotz leerer alter Packung von A.
- **AC21** Filter 20 g, Purge-Vorschlag 2.5 g, tatsächlich bestätigt 1 g → Verbrauch 21 g;
  unbestätigter Entwurf und Empfehlung allein buchen 0 g.
- **AC22** Backflush-Sekundenstand 3000 s bleibt nach Entkalken 3000 s, nach Backflush 0 s.
- **AC23** Start10:00:00, Pause10:00:10, Neustart10:00:20 → 10 s;
  Resume10:00:25, Stop10:00:35 → 20 s, persistierte Pause 15000 ms.
- **AC24** Import ohne consumptionEvents, ohne settings oder mit settings=null →
  vollständiger Abbruch ohne Datenänderung. Gültiger Leerexport ersetzt hardnessUnit atomar.
- **AC25** Nächster Versuch bei water/rest ändert keine Parameter automatisch, zeigt den
  passenden Hinweis; bei grind nur Mahlgrad einsetzen, bei none alle Parameter erhalten.
- **AC26** Quellenlink nur nach Nutzeraktion extern öffnen; keine automatische Netzabfrage.
- **AC27** Packung öffnen setzt UTC-Zeitstempel und updatedAt; Rücknahme setzt openedAt=null,
  verändert weder Bestand noch historische Brew-Snapshots.

- **AC1** Vier Mühlen, unabhängige echte Skala/Typ/Totraum; 12.2 bei Raster 0.5 ab Minimum 1 abgelehnt.
- **AC2** Maschine 93 °C/8 s/Druckprofil/Standardwasser nach Neustart identisch.
- **AC3** Zwei Packungen gleicher Bohne separate Bestände/Rösttage; medium 01.11. → Filter 06.11., Espresso 11.11.
- **AC4** 250−17−2.5=230.5 g, gleiche operationId zweimal unverändert; 18 g Rest blockiert 19.5 g Verbrauch.
- **AC5** 27 s sauer bei M1 12.0/0.5 abwärts → 11.5 mit Grund/Quelle; übrige Parameter gleich.
- **AC6** 30 °fH→300 ppm, Wasser vor Mahlgrad; 150 ppm bei sonst null zeigt 1 von 6 gemessen.
- **AC7** Hario V60 20 g/1:16→320 g, kumulativ 40/120/220/320, inkrementell 40/80/100/100; keine Schritte überspringen.
- **AC8** 18 g/Tag, Lieferung 3, Ruhe 10 → min 36 g, Bestellpunkt 270 g. Ohne Historie min 100 g, keine Lückenprognose.
- **AC9** Uhr 16.11.2026, B90 g, 18 g/Tag, nächste 25.11. → Lücke 21.–24.11.; Zwischenpackung 36 g am 21.11. → Lücke 23.–24.11.
- **AC10** Backflush 10.11., 90 Shots → 17.11. fällig; Sekundenlimit 3000 bei 2970+30 erreicht; Erledigt betrifft nur diese Aufgabe.
- **AC11** JSON: neuer updatedAt ersetzt, gleich alt lokal gewinnt; fehlende Referenzen gezählt, unbekannte Version/Typen ändern nichts.
- **AC12** Android-Emulator/Chrome: Daten nach Prozessneustart erhalten, UC1–UC9 offline nutzbar; drift/SQLite.
- **AC13** DE/EN gleiche ICU-Schlüssel, Systemfallback Englisch; DE Datum 16.11.2026, keine Roh-IDs.
- **AC14** Alle 20 Screens light/dark bei 390/1280 dp empty/filled/error/Interaktionen screenshotten; LF1–LF12 erfüllt.
- **AC15** Format/Analyze/Zeilen/Unit/Widget/gesamte Chrome-Systemtests grün ohne Skip, README/CHANGELOG jede Story.
- **AC16** Export Share-Sheet Android/iOS, Chrome Download; File-Picker-Import ≤10 MiB, Tombstones erhalten.
- **AC17** 35 s Timer minus 5 s Pause =30 s auch nach Hintergrund; Neustart bietet Fortsetzen/Abbrechen.
- **AC18** Alle fünf Filtermethoden; Vorschläge nur bereite nicht leere/nicht alte Packs, Espresso-Blends nachrangig.
