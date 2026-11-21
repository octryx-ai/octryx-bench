## 3 Domänenmodell

### Präzisierte Pflege- und Öffnungsfelder

- Persistierte Gerätefelder für editierbare Pflegegrenzen: `Machine.backflushDays` (Integer,
  Standard 7), `Machine.backflushShots` (Integer, Standard 200), `Machine.brewSecondsLimit`
  (nullable Integer, Standard null, nur Backflush), `Machine.descaleDaysOverride` (nullable
  Integer, Standard null), `Grinder.grinderCleanDays` (Integer, Standard 28).
  Alle gesetzten Grenzen sind positive Integer. Null bei Entkalkung verwendet die
  Wasserstaffel: `care.descale.hardDays` 30 bei >150 ppm, `care.descale.mediumDays` 60 bei
  100–150 ppm einschliesslich, `care.descale.softDays` 90 bei <100 ppm. Ohne Härte keine
  berechnete Fälligkeit, ausser ein expliziter `descaleDaysOverride` liegt vor.
- `CareEvent` referenziert genau ein Gerät über `machineId` oder `grinderId`; `kind` bindet
  das Ereignis an `backflush`, `descale` oder `grinderClean`. Nur das passende Ereignis
  setzt die Zähler dieser Aufgabe zurück. Keine Übertragung zwischen Geräten/Aufgaben.
  Die Grenze in Sekunden ist keine Entkalkungs- oder Mühlenreinigungsgrenze.
- `Pack.openedAt` ist null oder ein UTC-RFC3339-Zeitstempel mit Millisekunden, z. B.
  `2026-11-18T08:30:00.000Z`. „Öffnen“ setzt die aktuelle Zeit. Im Packungsformular kann
  der Nutzer den Zeitpunkt korrigieren oder mit „Öffnung zurücknehmen“ / „Undo opening“
  wieder null setzen. Jede Änderung aktualisiert `updatedAt`, verändert aber weder
  Bestand noch Röstdatum/Ruhezeit. Historische Brew-Snapshots bleiben unverändert.

Jeder Datensatz: `id` (UUIDv4, String, stabil), `createdAt` , `updatedAt` (UTC ISO-8601, ms), `deletedAt` (nullable). Gespeichert mit drift/SQLite.
Datumsfelder `roastDate` , `readyDate` , `doneAt` -Tag sind reine Datumswerte (`YYYY-MM-DD`, ohne Zeitzone). „Heute“ ist immer das lokale
Kalenderdatum des Geräts.

**Löschen:** Mühle, Maschine, Bohne, Packung, Wasserprofil werden nie hart gelöscht: `deletedAt` wird gesetzt und `updatedAt = deletedAt` . Der
Datensatz verschwindet aus Listen und Auswahlfeldern, bleibt aber für Brühungen und Historie auflösbar. Brühungen und Pflegeereignisse dürfen
ebenfalls so gelöscht werden.

- **Entität**: Felder (Typ, Einheit)

- **Grinder (Mühle)**: name; `scaleMin` , `scaleMax` , `scaleStep` (Dezimalzahl, Rasterstufe wie das Gerät wirklich rastet, z. B. 0.5);
  `finerDirection` (`down`\|`up`); `deadSpaceG` (g, bestätigte Spülmenge); `kind` (`flat`|`conical`|`blade`|`other`); `createdOn` (lokales Datum)
- **Machine**: name; `brewTempC` (°C); `preinfusionS` (s); `pressureProfile` (Text); `defaultWaterProfileId` ; `backflushSupported` (bool, false);
  `brewSecondsLimit` (nullable, positive ganze s); `createdOn` (lokales Datum, Pflege-Basis ohne Ereignis)
- **WaterProfile**: name; `hardnessPpm` (ppm als CaCO₃, Pflicht, gespeichert); optional (nullable): `alkalinityPpm` , `tdsPpm` , `ph` , `sodiumMgL` ,
  `chlorineMgL`
- **Bean**: name; roaster; `roastLevel` (`light`\|`medium`\|`mediumDark`\|`dark`); `kind` (`espressoBlend`\|`filter`\|`allround`); `minStockG`
  (nullable = Standard); `leadTimeDays` (Lieferzeit, Standard 3, auf Bohnenebene)
- **Pack (Packung)**: beanId; `roastDate` ; `sizeG` (g); `remainingG` (g); `openedAt` (nullable)
- **Brew**: `method` (`espresso`\|`v60`\|`chemex`\|`kalita`\|`aeropress`\|`batch`); `machineId` (Pflicht bei `espresso` , sonst null); grinderId;
  packId; `grindSetting` ; `doseG` ; `purgeG` (g, Standard 0, verworfener Totraum); `yieldG` (nur Espresso); `shotTimeS` (s, nur Espresso);
  `waterTempC` ; waterProfileId; Filter: `waterTotalG` , `bloomG` , `pours` (Liste `{atS, cumulativeG}` ), `drawdownS` (s); `taste`
  (`sour`\|`bitter`\|`weak`\|`balanced`); `rating` 1–5; note; `startedAt`
- **CareEvent**: machineId oder grinderId; `kind` (`backflush`\|`descale`\|`grinderClean`); `doneAt`
- **Setting**: `hardnessUnit` (`fH`\|`dH`\|`ppm`, Standard `fH` )

Einheiten: g, ml, s, °C; Härte intern ppm. Wasser: 1 g = 1 ml. Welche Ruhezeit-Methode für eine Bohne gilt (`restMethod`): `espressoBlend` und
`allround` → Espresso (die längere Ruhezeit), `filter` → Filter.
