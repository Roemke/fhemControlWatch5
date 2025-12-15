import router from '@ohos.router';
import fileio from '@ohos.fileio';
import { loadListUrl, saveListUrl } from '../common/settingsStore';



// 5. Component
@Entry
@Component
export struct SettingsPage {
  @State listUrl: string = "";

  async aboutToAppear() {
    this.listUrl = await loadListUrl();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {

        Text("Liste-URL konfigurieren")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .padding({ top: 12 })

        Text("Aktuelle URL:")
          .fontSize(14)

        Text(this.listUrl)
          .fontSize(12)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Button("URL bearbeiten")
          .onClick(() => {
            router.pushUrl({
              url: 'pages/EditUrlPage',
              params: { currentUrl: this.listUrl }
            });
          })

      }
      .padding({ left: 20, right: 20, bottom: 12 })
    }
  }
}
