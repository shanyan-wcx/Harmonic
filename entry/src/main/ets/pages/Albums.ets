import { Album, Artist, Song } from '../utils/Interface';
import { curves } from '@kit.ArkUI';
import { getAlbumList } from '../utils/Api';
import { i18n, intl } from '@kit.LocalizationKit';

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
export default struct Albums {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @State artists: Artist[] = []
  @State albums: Album[] = []
  @Consume album: Album | undefined
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume serverStatus: boolean
  @Consume discs: Song[][]
  @Consume displayWidth: number
  @Consume showProgress: boolean
  @State coverSize: number = 320

  async aboutToAppear() {
    this.showProgress = true
    let offset = 0
    let size = 500
    while (true) {
      let albums = await getAlbumList(this.baseURL, this.username, this.password, offset)
      if (albums === undefined || albums.length === 0) {
        break;
      }
      this.albums.push(...albums);
      if (albums.length < size){
        break;
      }
      offset += size;
    }
    this.albums.sort((a, b) => {
      return collator.compare(transliterator.transform(a.name), transliterator.transform(b.name));
    })
    this.showProgress = false
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.albums, (album: Album, index) => {
          GridItem() {
            Button({ type: ButtonType.Normal }) {
              Column() {
                Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                  .alt($rawfile('nocover.png'))
                  .objectFit(ImageFit.Contain)
                  .width('100%')
                  .aspectRatio(1)
                  .borderRadius(10)
                  .margin(10)
              }
              .width('100%')
              .height('auto')
            }
            .width('100%')
            .height('auto')
            .margin({ bottom: this.startPlaying === true && index === this.albums.length - 1 ? 85 : 0 })
            .animation({ curve: curves.springMotion(0.6, 1) })
            .borderRadius(10)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.album = album
              this.pageStack.pushPathByName('AlbumDetail', undefined);
            })
          }
        })
      }
      .width('100%')
      .height('100%')
      .columnsTemplate(this.displayWidth > 1400 ? "1fr 1fr 1fr 1fr 1fr 1fr" :
        (this.displayWidth > 1000 ? "1fr 1fr 1fr 1fr 1fr" :
          (this.displayWidth > 800 ? "1fr 1fr 1fr 1fr" : (this.displayWidth > 400 ? "1fr 1fr 1fr" : "1fr 1fr"))))
      .columnsGap(0)
      .rowsGap(0)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .padding({ left: 10, right: 10, bottom: 10 })
      .visibility(this.albums.length > 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)

      Column() {
        Text("没有专辑")
          .fontSize(32)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 160 })
      .justifyContent(FlexAlign.Center)
      .visibility(this.albums.length === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}