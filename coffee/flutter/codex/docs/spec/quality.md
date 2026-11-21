## 7 Nicht-funktionale Anforderungen

### Präzisierte Netz- und Testbedingungen

- Die Laufzeit-Netzsperre betrifft die App selbst und alle automatischen Abrufe.
  Ein vom Nutzer ausdrücklich angetippter Quellenlink darf als Ausnahme den externen Browser
  öffnen. Keine Hintergrundabfrage, keine Recherche als Voraussetzung für Save oder Start.
- UC4/AC5: Mühle M1 hat Minimum 1, Maximum 30, Schritt 0.5 und `finerDirection=down`;
  aktueller Mahlgrad 12.0, Geschmack sauer, Espresso 27 s. Wasser liegt mit allen gemessenen
  Werten im Referenzbereich, Packung ist für Espresso bereit und nicht alt. Erst unter
  diesen Vorbedingungen ist das erwartete Ergebnis genau 11.5 mit Grund und Quelle.
- UC9/AC11/AC16: Exportieren, dann eine frische leere Datenbank initialisieren und dort
  importieren → Bohnenliste enthält „Bohne 1“. Kein Löschen per Tombstone vor dem Restore:
  ein neuerer lokaler Tombstone würde erwartungsgemäss gegen den älteren Export gewinnen.
  Separater Konflikttest: lokaler Tombstone `updatedAt` 13:00, Export-Datensatz 12:00 →
  Datensatz bleibt archiviert. Ein Restore überstimmt niemals neuere Tombstones.

- Offline first: alle Funktionen ohne Netz; keine Netzwerkzugriffe zur Laufzeit.
- Performance: Mit 1000 Brühungen in der Liste wird jeder Frame beim Scrollen auf dem Emulator in höchstens 16 ms gebaut; die Empfehlung (R9/R11) wird
  in unter 50 ms berechnet.
- Barrierefreiheit: Kontrast Text/Hintergrund ≥ 4.5:1, Fokusring 2 dp, Touch-Ziele ≥ 48 × 48 dp, Semantics-Labels für alle Icon-Buttons.
- Code Style (Team-Konvention): max. 300 Zeilen pro Quelldatei, Tests max. 500, generierte Dateien ausgenommen; Struktur `lib/app` , `lib/core` ,
  `lib/features/<feature>/{data,domain,presentation}` ; eine Klasse bzw. ein Widget pro Datei; `test/` spiegelt `lib/` ; `///` -Doc-Kommentare für
  öffentliche APIs; Inline-Kommentare nur für das Warum; kein auskommentierter Code; Aufgabenmarker nur mit Ticket, z. B. `TODO(OE-80)` ; Gate in
  `environment.json` : `dart format --output=none --set-exit-if-changed .` , `flutter analyze --no-pub` (flutter_lints, strikt) und Zeilenprüfung
  `tool/check_lines.dart` .
- `tool/check_lines.dart` wird in der ersten Story (Projekt-Grundgerüst) angelegt. Abnahme: Exit 0, wenn alle Dateien in `lib/` ≤ 300 und in `test/` ≤
  500 Zeilen haben; Exit 1 mit Ausgabe `<Pfad>: <Zeilen>` für jede Datei darüber (Test: eine Datei mit 301 Zeilen in `lib/` → Exit 1). Ausgenommen:
  `*.g.dart` , `*.freezed.dart` , `lib/l10n/app_localizations*.dart` .
- Tests: Unit-Tests für R1–R11 mit den Zahlen aus Abschnitt 4. Playwright-Systemtests in Chrome (Flutter-Web-Build), ein Szenario pro UC mit
  erwartetem Wert:
- UC1: Mühle „M1“ (Skala 1–30, Schritt 0.5, Totraum 2.5 g) anlegen → Karte „M1“ zeigt „2.5 g“.
- UC2: Bohne medium, Röstdatum heute − 12 Tage, anlegen → Chip „Bereit“.
- UC3: Espresso 18 g → 36 g in 27 s speichern → Liste zeigt „27 s“.
- UC4: Brühung sauer, 27 s, Mahlgrad 12.0 → Karte „Empfehlung“ zeigt „Mahlgrad auf 11.5“.
- UC5: 20 g, 1:16 → Fokus-Modus zeigt „Giesse bis 40 g“, dann „120 g“, „220 g“, „320 g“.
- UC6: Wasser 30 °fH → Status „Ausserhalb Referenzbereich“ und Anzeige „300 ppm“ nach Wechsel auf ppm.
- UC7: Backflush 7 Tage her → Pflege zeigt „Fällig“; nach „Erledigt“ „In 7 Tagen“.
- UC8: 90 g, Verbrauch 18 g/Tag, nächste Packung in 9 Tagen bereit → Banner „Kein trinkbereiter Kaffee vom 21.11.2026 bis 24.11.2026“ (bei heute
  2026-11-16).
- UC9: Export, Daten löschen, Import → Bohnenliste enthält wieder „Bohne 1“.
- Jede Story aktualisiert `README.md` und `CHANGELOG.md` .
- Datenschutz: Daten verlassen das Gerät nur durch den ausdrücklichen JSON-Export.
