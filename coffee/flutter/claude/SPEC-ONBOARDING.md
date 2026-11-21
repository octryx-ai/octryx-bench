# Onboarding-Ablauf R12 (Ergänzung zu SPEC.md, OE-74)

Auslagerung aus SPEC.md Abschnitt 4 (Dateigrösse); Regel R12 gilt unverändert.

**R12 Onboarding-Ablauf.** Das Onboarding hat genau 4 Seiten: 1 Willkommen, 2 Funktionen (drei Punkte: Brühungen erfassen; Bohnen und Ruhezeit führen;
Empfehlung zur Verbesserung), 3 Mühle anlegen, 4 Bohne anlegen. Beim Start gilt: `onboardingDone = true` → Shell mit Ziel Heute; `false` oder fehlend
→ Onboarding Seite 1, unabhängig davon, ob schon Daten existieren. Schlägt das Lesen des Flags fehl, gilt `onboardingDone = true` (keine Schleife).
Das Flag wird nur beim Abschluss („Los geht’s“ auf Seite 4) oder bei „Überspringen“ auf `true` gesetzt, nie früher. Fortschrittstext auf Seite `k`:
„`k` von 4“ / „`k` of 4“, Füllanteil der Punkte = `k / 4`. Seite 3 und 4 sind je einzeln mit „Später“ überspringbar (ohne Datensatz):
„Später“ auf Seite 3 → Seite 4; „Später“ auf Seite 4 schliesst das
Onboarding ab wie „Los geht’s“. Nach erfolgreichem Speichern auf Seite 3 geht es automatisch zu Seite 4; nach erfolgreichem Speichern auf Seite 4
bleibt die Seite stehen, zeigt „Angelegt: {Name}“ und die primäre Aktion „Los geht’s“ → Flag `true`, Heute (kein automatischer Wechsel). Schlägt
das Schreiben des Flags fehl (Abschluss oder Überspringen), bleibt der Nutzer auf der Seite, ein Fehlerbanner „Einstellung konnte nicht gespeichert
werden“ / „Setting could not be saved“ mit Aktion „Erneut versuchen“ / „Retry“ erscheint; Heute wird erst nach erfolgreichem Schreiben gezeigt, damit
das Onboarding nach Abschluss oder Überspringen nie wieder erscheint. Heute-Regel für Bohnen ohne Packung: unter „Jetzt trinkbereit“ steht eine
Region „Ohne Packung“ / „No pack yet“ mit der Bohnenkarte und dem Hinweis „Packung hinzufügen“ / „Add a pack“; Heute zeigt den Leer-Zustand nur,
wenn keine Bohne existiert. Pro
Onboarding-Lauf wird höchstens eine Mühle und eine Bohne angelegt; Zurückgehen auf eine gespeicherte Seite zeigt „Angelegt: {Name}“ / „Created:
{name}“ und legt nichts neu an. Eine Bohne im Onboarding hat keine Packung.
Beispiel (Flag-Logik): Flag fehlt → Onboarding. Flag `true` → Heute. Lesefehler → Heute. Überspringen auf Seite 2 → Flag `true`, Heute; zweiter Start
→ Heute. App auf Seite 3 geschlossen, Mühle „M1“ gespeichert → Flag `false`, nächster Start Seite 1; „M1“ ist (bei laufender Sitzung) weiter vorhanden
und wird nicht doppelt angelegt. Seite 2: „2 von 4“, Füllanteil 2 / 4 = 50 %. Seite 4: „4 von 4“, 100 %. Abschluss mit Mühle „M1“ (Skala 1–30, Schritt
0.5, Totraum 2.5 g) und Bohne „Bohne 1“ (medium, `allround`) → Ausrüstung zeigt Karte „M1“ mit „2.5 g“, Bohnenliste zeigt „Bohne 1“ ohne Chip,
Heute zeigt „Bohne 1“ in der Region „Ohne Packung“ (nicht unter „Jetzt trinkbereit“, da keine
Packung existiert). Flag-Schreibfehler beim Abschluss → Fehlerbanner, Seite 4 bleibt, Heute erst nach „Erneut versuchen“ mit Erfolg.
