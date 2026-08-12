# User Guide — SampleSheet Generator (WES, Pathology)

This app creates the Illumina `SampleSheet.csv` for a NovaSeq X Plus WES run.
You enter each sample and choose its index; the app builds and checks the sheet
for you and lets you export it.

> If the app is not yet installed on your computer, see **`docs/INSTALL.md`**
> (installation is a one-time setup).

---

## 1. Start the app

1. Open the project folder.
2. Double-click **`samplesheet-generator-pathology.Rproj`**. RStudio opens.
3. In RStudio, open **`app.R`** (top-left file list) and click **Run App**
   (top-right of the editor).
4. The app opens in a window.

> RStudio may briefly show a message about `renv` when the project opens.
> This is normal. As long as the app starts when you click **Run App**,
> everything is working.

---

## 2. Create a sample sheet

### Enter the run name (optional)

- Type the **RunName** in the top field if you know it.
- If you don't know it yet, leave it empty — the sheet will contain `NA` in
  place of the run name, and the file will be named `NA-samplesheet.csv`. You
  (or Kai) can fill the run name in later.

### Add a sample

For each sample:

1. Type the **Sample_ID** (for example `1234-26_3-N`).
2. In the **Index** field, start typing to search — you can search by the
   index name (e.g. `74`) or by sequence. Pick the correct index.
3. Click **Probe hinzufügen** (Add sample).

The sample appears in the table on the right, with its i7/i5 sequences filled
in automatically. An index you have already used disappears from the list, so
you cannot accidentally assign it twice.

> The **"IndexUDP (nur Vorschau)"** column is shown only to help you check your
> work — it is **not** written into the sample sheet.

### Remove a sample

Click the row in the table, then click **Ausgewählte Zeile entfernen**
(Remove selected row). The index becomes available again.

---

## 3. Read the check ("Prüfung")

The app checks your samples continuously. You will see one of three states:

- **Green — "Keine Probleme gefunden."** Everything is fine; you can export.
- **Yellow — Warnungen.** Something is unusual (for example a Sample_ID that
  does not match the expected pattern), but the sheet is still valid. A green
  note confirms: **"Der Lauf kann trotz Warnungen exportiert werden."** You can
  export.
- **Red — Fehler.** There is a real problem (for example a duplicate Sample_ID,
  or an invalid character). **Export is blocked** until you fix it. Each message
  tells you which row and what is wrong.

---

## 4. Export the sample sheet

1. When the check shows green or yellow (not red), the **SampleSheet
   exportieren** button is active.
2. Click it. Choose where to save.
3. The file is saved as `<RunName>-samplesheet.csv` (or `NA-samplesheet.csv`
   if you left the run name empty).

If the button is grey, export is not possible yet — either you have no samples,
or there are errors to fix (see the check panel).

---

## 5. Important note on accuracy

The app checks the **format** of each Sample_ID, but it **cannot** know whether
you typed the correct number. A Sample_ID that is valid but wrong (for example
`_1` typed instead of `_3`) will not be caught. **Always double-check the
Sample_IDs against your source before exporting.** The review table is there to
help you do this.

---
---

# Benutzerhandbuch — SampleSheet Generator (WES, Pathologie)

Diese App erstellt das Illumina-`SampleSheet.csv` für einen NovaSeq X Plus
WES-Lauf. Sie geben jede Probe ein und wählen ihren Index; die App erstellt und
prüft das SampleSheet und ermöglicht den Export.

> Falls die App auf Ihrem Rechner noch nicht installiert ist, siehe
> **`docs/INSTALL.md`** (die Installation ist eine einmalige Einrichtung).

---

## 1. App starten

1. Öffnen Sie den Projektordner.
2. Doppelklicken Sie auf **`samplesheet-generator-pathology.Rproj`**.
   RStudio öffnet sich.
3. Öffnen Sie in RStudio die Datei **`app.R`** (Dateiliste oben links) und
   klicken Sie auf **Run App** (oben rechts im Editor).
4. Die App öffnet sich in einem Fenster.

> RStudio zeigt beim Öffnen des Projekts eventuell kurz eine `renv`-Meldung an.
> Das ist normal. Solange die App nach dem Klick auf **Run App** startet,
> funktioniert alles.

---

## 2. SampleSheet erstellen

### Runnamen eingeben (optional)

- Geben Sie oben den **RunName** ein, falls bekannt.
- Falls noch nicht bekannt, lassen Sie das Feld leer — im SampleSheet steht dann
  `NA` als Runname, und die Datei heißt `NA-samplesheet.csv`. Sie (oder Kai)
  können den Runnamen später ergänzen.

### Probe hinzufügen

Für jede Probe:

1. Geben Sie die **Sample_ID** ein (zum Beispiel `1234-26_3-N`).
2. Im Feld **Index** tippen, um zu suchen — Sie können nach dem Indexnamen
   (z. B. `74`) oder nach der Sequenz suchen. Wählen Sie den richtigen Index.
3. Klicken Sie auf **Probe hinzufügen**.

Die Probe erscheint rechts in der Tabelle, mit automatisch eingetragenen
i7/i5-Sequenzen. Ein bereits verwendeter Index verschwindet aus der Liste, damit
er nicht versehentlich doppelt vergeben wird.

> Die Spalte **"IndexUDP (nur Vorschau)"** dient nur zur Kontrolle — sie wird
> **nicht** in das SampleSheet geschrieben.

### Probe entfernen

Klicken Sie auf die Zeile in der Tabelle und dann auf **Ausgewählte Zeile
entfernen**. Der Index wird wieder verfügbar.

---

## 3. Prüfung lesen

Die App prüft Ihre Proben laufend. Sie sehen einen von drei Zuständen:

- **Grün — "Keine Probleme gefunden."** Alles in Ordnung; Export möglich.
- **Gelb — Warnungen.** Etwas ist ungewöhnlich (z. B. eine Sample_ID, die nicht
  dem erwarteten Muster entspricht), das SampleSheet ist aber gültig. Ein grüner
  Hinweis bestätigt: **"Der Lauf kann trotz Warnungen exportiert werden."**
  Export möglich.
- **Rot — Fehler.** Es liegt ein echtes Problem vor (z. B. eine doppelte
  Sample_ID oder ein ungültiges Zeichen). **Der Export ist gesperrt**, bis es
  behoben ist. Jede Meldung nennt die betroffene Zeile und das Problem.

---

## 4. SampleSheet exportieren

1. Wenn die Prüfung grün oder gelb (nicht rot) ist, ist die Schaltfläche
   **SampleSheet exportieren** aktiv.
2. Klicken Sie darauf. Wählen Sie den Speicherort.
3. Die Datei wird als `<RunName>-samplesheet.csv` gespeichert (oder
   `NA-samplesheet.csv`, falls der Runname leer war).

Ist die Schaltfläche grau, ist der Export noch nicht möglich — entweder gibt es
keine Proben oder es sind Fehler zu beheben (siehe Prüfungsbereich).

---

## 5. Wichtiger Hinweis zur Genauigkeit

Die App prüft das **Format** jeder Sample_ID, kann aber **nicht** wissen, ob Sie
die richtige Nummer eingegeben haben. Eine gültige, aber falsche Sample_ID (z. B.
`_1` statt `_3`) wird nicht erkannt. **Kontrollieren Sie die Sample_IDs vor dem
Export immer gegen Ihre Quelle.** Die Übersichtstabelle hilft Ihnen dabei.