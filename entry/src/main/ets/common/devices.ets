export interface DeviceItem {
  alias: string;
  group: string;
  state: 'on' | 'off' | 'action';
  url?: string;
  url_on?: string;
  url_off?: string;
}


