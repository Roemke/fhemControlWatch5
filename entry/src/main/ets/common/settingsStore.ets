import fileio from '@ohos.fileio';

// 1. Interface MUSS ganz oben stehen – außerhalb aller Komponenten
interface SettingsData {
  listUrl?: string;
}

/*
 Hmm, hier arbeite ich mit fileio fuer die Daten, prefs ging nicht, warum nicht, im Projekt einkauf scheint es zu gehen.
 */
// 2. Pfad-Konstante
const SETTINGS_PATH: string = '/data/storage/el2/base/files/settings.json';
const DEFAULT_LIST_URL: string = "http://192.168.0.203:8084/fhem?cmd={mdjson()}&XHR=1";

// 3. Speichern
export async function saveListUrl(url: string): Promise<void> {
  const json: string = JSON.stringify({ listUrl: url });
  const fd: number = await fileio.open(SETTINGS_PATH, 0o102);
  await fileio.write(fd, json);
  await fileio.close(fd);
}

// 4. Laden
export async function loadListUrl(): Promise<string> {
  try {
    const fd: number = await fileio.open(SETTINGS_PATH, 0o0);
    const buffer: ArrayBuffer = new ArrayBuffer(512);

    const result = await fileio.read(fd, buffer);
    await fileio.close(fd);

    const count: number = typeof result === "number"
      ? result
      : (result.bytesRead ?? 0);

    const raw: string = String.fromCharCode(...new Uint8Array(buffer, 0, count));

    let parsed: SettingsData = {};

    if (raw && raw.trim().startsWith("{")) {
      parsed = JSON.parse(raw) as SettingsData;
    }

    return parsed.listUrl ?? "http://192.168.0.10:8080/list.json";
  } catch (_) {
    return DEFAULT_LIST_URL;
  }
}