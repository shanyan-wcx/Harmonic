import { Artist } from '../utils/Interface'
import { curves } from '@kit.ArkUI'
import { i18n, intl } from '@kit.LocalizationKit';
import { getIndexes } from '../utils/Api';

let transliterator = i18n.Transliterator.getInstance('Any-Latn');
let options: intl.CollatorOptions = {
  localeMatcher: "lookup",
  usage: "sort",
  sensitivity: "variant",
  numeric: true
};
let locale = new intl.Locale();
let collator = new intl.Collator(locale.toString(), options);

@Component
export default struct Artists {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @State artists: Artist[] = []
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume artist: Artist | undefined
  @Consume serverStatus: boolean
  @Consume displayWidth: number
  @Consume showProgress: boolean
  @State profileSize: number = 256

  async aboutToAppear() {
    this.showProgress = true
    this.artists = await getIndexes(this.baseURL, this.username, this.password)
    this.artists.sort((a, b) => {
      return collator.compare(transliterator.transform(a.name), transliterator.transform(b.name));
    })
    this.showProgress = false
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.artists, (artist: Artist, index) => {
          GridItem() {
            Button({ type: ButtonType.Normal }) {
              Column() {
                Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${artist.id}&size=${this.profileSize}`)
                  .alt($rawfile('noprofile.jpg'))
                  .objectFit(ImageFit.Cover)
                  .width('100%')
                  .aspectRatio(1)
                  .borderRadius(10000)
                  .margin({ top: 10, left: 10, right: 10 })
                Text(artist.name)
                  .width('100%')
                  .fontSize(16)
                  .fontColor($r('app.color.font'))
                  .margin(10)
                  .maxLines(1)
                  .textAlign(TextAlign.Center)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .height('auto')
            }
            .width('100%')
            .height('auto')
            .margin({ bottom: this.startPlaying === true && index === this.artists.length - 1 ? 85 : 0 })
            .animation({ curve: curves.springMotion(0.6, 1) })
            .borderRadius(10)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.artist = artist
              this.pageStack.pushPathByName('ArtistDetail', undefined);
            })
          }
        })
      }
      .width('100%')
      .height('100%')
      .columnsTemplate(this.displayWidth > 1400 ? "1fr 1fr 1fr 1fr 1fr 1fr 1fr" :
        (this.displayWidth > 1000 ? "1fr 1fr 1fr 1fr 1fr 1fr" : (this.displayWidth > 800 ? "1fr 1fr 1fr 1fr 1fr" :
          (this.displayWidth > 400 ? "1fr 1fr 1fr 1fr" : "1fr 1fr 1fr"))))
      .columnsGap(0)
      .rowsGap(0)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade, {alwaysEnabled: false})
      .padding({ left: 10, right: 10, bottom: 10 })
      .visibility(this.artists.length > 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)

      Column() {
        Text("没有艺术家")
          .fontSize(32)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 160 })
      .justifyContent(FlexAlign.Center)
      .visibility(this.artists.length === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}