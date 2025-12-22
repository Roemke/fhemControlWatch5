import router from '@ohos.router';
import { DeviceItem } from '../common/devices';
import { fetchDevices } from '../common/deviceService';
import http from '@ohos.net.http';
import vibrator from '@ohos.vibrator';


@Entry
@Component
struct ControlPage {

  // ---------- State ----------
  @State loading: boolean = true; //@state - ändert sich die var, dann ui aktualisiert
  @State loadError: boolean = false;
  @State devices: DeviceItem[] = [];
  @State debugText: string = '';
  @State currentGroup: string = 'not set';
  @State actionInProgress: string | null = null;
  @State private errorItemAlias: string | null = null;
  private icon : string = "";


  // ---------- Lifecycle ----------
  async aboutToAppear() {
    await this.loadDevices();
  }

  // ---------- Logik ----------
  async loadDevices() {
    this.loading = true;
    this.loadError = false;

    try {
      this.devices = await fetchDevices();
    } catch (e) {
      if (e instanceof Error) {
        this.debugText = e.message;
      } else {
        this.debugText = JSON.stringify(e);
      }
      this.devices = [];
      this.loadError = true;
    } finally {
      this.loading = false;
    }
  }

  //
  build() {
    Scroll(){
    Column() {
      if (this.loading) {
        this.renderCenteredMessage("Lade …");
      } else if (this.loadError) {
        this.renderCenteredError();//greift auf debug-Text zu
      } else {
        // Liste anzeigen
        //this.setHeader();
        this.renderDeviceList();
      }
    }}
  }

  @Builder
  setHeader() : void { //ist raus
    Text(this.currentGroup)
      .fontSize(12)
      .fontColor('#AAAAAA')
      .padding({ top: 8, bottom: 8 })
      .textAlign(TextAlign.Center)
      .width('10%')
  }
  @Builder
  renderDeviceList(): void {
    List() {
      ForEach(this.devices, (item: DeviceItem, index:number) => {
        ListItem() {
          this.renderDevice(item);
        }
      }, (item: DeviceItem) => `${item.alias}_${item.state}_${item.group}`)//das ist ein key, er muss sich ändern
    }
    //.onScrollIndex((start: number, end: number, center: number) => {
    //  this.onListScroll(start,end,center);
    //})


  }

  @Builder
  renderCenteredMessage(text: string):void {
    Column({ space: 12 }) {
      Text(text)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(24)
  }

  @Builder
  renderCenteredError():void {
    Column({ space: 16 }) {
      Text(this.debugText)
        .fontSize(12)
        .textAlign(TextAlign.Center)
        .maxLines(6);
      Button("Einstellungen")
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(24)
  }
  //some helper
  @Builder renderStateButton(
    label: string,
    active: boolean,
    onClick: () => void
  ) :void {
    Button(label)
      .width(70)
      .height(36)
      .backgroundColor(active ? '#4CAF50' : '#444444')
      .fontColor('#FFFFFF')
      .onClick(onClick)
  }
  @Builder renderDevice(item: DeviceItem):void {
    Column({ space: 8 }) {
      Text(item.alias)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)

      // Buttons
      if (item.state === 'action') {
        // Sonderfall: Alles Aus
        Button(this.actionInProgress === item.alias ? '...done!' : 'Do it!')
          .width(140)
          .height(44)
          .backgroundColor(this.actionInProgress === item.alias  ? '#a30f0f' : '#D32F2F')
          .fontColor('#FFFFFF')
          .onClick(() => this.sendAction(item))
      } else {
        Row({ space: 12 }) {
          this.renderStateButton(
            'AN',
            item.state === 'on',
            () => this.sendCommand(item, 'on')
          )

          this.renderStateButton(
            'AUS',
            item.state === 'off',
            () => this.sendCommand(item, 'off')
          )
        }.justifyContent(FlexAlign.Center)
      }
      if (this.errorItemAlias === item.alias) {
        Text('!')
          .fontSize(22)
          .fontColor('#FF3B30')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
        }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
  //scrollen verbessern
  private onListScroll(start: number, end: number, center:number): void {
    if (center == start + 1)
       center = start; //kleine korrektur beim hochscrollen
    const group = this.devices[center].group;

    if (group !== this.currentGroup) {
      this.currentGroup = group;
    }
  }

  //senden des Befehls
  private async sendCommand(item: DeviceItem, target: 'on' | 'off'): Promise<void> {
    //console.info(`SEND ${item.alias} -> ${target}`)

    const url: string | undefined =
      target === 'on' ? item.url_on : item.url_off;

    if (!url) {
      console.error('Keine URL für', item.alias);
      return;
    }
    const client = http.createHttp();
    try {
      console.log('URL: '+url);
      const response = await client.request(url,
          {
            method: http.RequestMethod.GET,
            connectTimeout: 5000,
            readTimeout: 5000
          });

      if (response.responseCode !== 200) {
        console.error('HTTP Fehler', response.responseCode);
        return;
      }

      this.devices = this.devices.map(d => {
        if (d.alias === item.alias) {
          return {
            alias: d.alias,
            group: d.group,
            state: target,
            url: d.url,
            url_on: d.url_on,
            url_off: d.url_off
          };
        }
        return d;
      });
      //vibrator.vibrate(200); // klappt nicht

      this.errorItemAlias = null;
    }catch (err) {
      console.error('Netzwerkfehler', JSON.stringify(err));
      this.errorItemAlias = item.alias;

      // nach kurzer Zeit wieder ausblenden
      setTimeout(() => {
        this.errorItemAlias = null;
      }, 800);
    }
  }

  private async  sendAction(item: DeviceItem):  Promise<void> {
    if (this.actionInProgress !== null) {
      return; // optional: Doppelklick blockieren
    }

    // später: echter HTTP-Call
    const url: string | undefined = item.url;

    if (!url || url=="") {
      console.error('Keine URL für', item.alias);
      return;
    }
    this.actionInProgress = item.alias;

    const client = http.createHttp();
    try {
      console.log('URL: ' + url);
      const response = await client.request(url,
        {
          method: http.RequestMethod.GET,
          connectTimeout: 5000,
          readTimeout: 5000
        });

      if (response.responseCode !== 200) {
        this.actionInProgress = item.alias;
      }
    } catch (err) {
        console.error('Netzwerkfehler', JSON.stringify(err));
    }
    finally {
      await this.loadDevices();
      setTimeout(() => {
        this.actionInProgress = null;
      }, 1200);
    }
  }
}
