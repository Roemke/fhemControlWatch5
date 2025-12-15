import router from '@ohos.router';
import fileio from '@ohos.fileio';
import { saveListUrl } from '../common/settingsStore';


interface EditUrlParams {
  currentUrl?: string;
}

@Entry
@Component
export struct EditUrlPage {
  @State url: string = "";

  aboutToAppear() {
    const params = router.getParams() as EditUrlParams;
    this.url = params.currentUrl ?? this.url;
  }

  build() {
    Column({ space: 12 }) {

      Text("URL bearbeiten")
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      // GROßER Editor, volle Seite
      TextArea({
        text: this.url,
        placeholder: "http://..."
      })
        .onChange((v: string) => this.url = v)
        .height('60%')
        .fontSize(16)
        .padding(10)

      Button("Speichern")
        .onClick(async () => {
          await saveListUrl(this.url);
          router.back();
        })
        .height(44)

    }
    .padding(16)
  }
}
