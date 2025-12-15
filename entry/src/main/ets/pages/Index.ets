import router from '@ohos.router';
//index leitet sofort zur controlpage weiter
@Entry
@Component
struct Index {
  build() {
    // nichts anzeigen
  }

  aboutToAppear() {
    router.replaceUrl({ url: 'pages/ControlPage' });
  }
}
/*
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Button("Einstellungen")
        .onClick(() => {
          router.pushUrl({ url: "pages/SettingsPage" })
        })
        .padding(20)

      RelativeContainer() {
        Text(this.message)
          .id('HelloWorld')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.message = 'Welcome';
          })
      }
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}
*/