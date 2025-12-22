import http from '@ohos.net.http';
import { DeviceItem } from './devices';
import { loadListUrl } from './settingsStore';

function normalizeUrl(url?: string): string | undefined {
  if (!url) {
    return undefined;
  }
  // encodeURI ist hier korrekt (nicht encodeURIComponent!)
  return encodeURI(url);
}

export async function fetchDevices(): Promise<DeviceItem[]> {
  const url: string = await loadListUrl();

  const httpRequest = http.createHttp();
  const response = await httpRequest.request(url, {
    method: http.RequestMethod.GET,
    expectDataType: http.HttpDataType.STRING
  });

  if (response.responseCode !== 200) {
    throw new Error('HTTP error');
  }

  const raw: string = response.result as string;
  const parsed: DeviceItem[] = JSON.parse(raw) as DeviceItem[];

  if (!Array.isArray(parsed) || parsed.length === 0) {
    throw new Error('Invalid list');
  }
  const normalized: DeviceItem[] = parsed.map((d: DeviceItem) => {
    let alias : string = "";
    alias = (d.group == "Media") ?  '📡' :
            (d.group == "Licht") ? '💡'  :
              (d.group == "Combined") ?  '⚠️' : ' ';
    const item: DeviceItem = {
      alias: alias + d.alias,
      group: d.group,
      state: d.state,
      url: normalizeUrl(d.url),
      url_on: normalizeUrl(d.url_on),
      url_off: normalizeUrl(d.url_off)
    };
    return item;
  });

  return normalized;
}
