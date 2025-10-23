import { Artist } from '../utils/Interface'
import { artistImage } from '../utils/Component'

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
  @Consume artists: Artist[]
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume artist: Artist | undefined
  @Consume serverStatus: boolean
  @Consume displayWidth: number
  @Consume showProgress: boolean
  @Consume needUpdate: boolean
  @Consume showLibrary: boolean
  @State profileSize: number = 256
  private artistsScroller: Scroller = new Scroller();

  async aboutToAppear() {
    this.needUpdate = !this.needUpdate
  }

  build() {
    Stack() {
      Column() {
        Grid(this.artistsScroller) {
          ForEach(this.artists, (artist: Artist, index) => {
            GridItem() {
              Button({ type: ButtonType.Normal }) {
                Column() {
                  Column(){
                    artistImage({
                      url: this.baseURL + this.getCoverUrl + this.auth + `&id=${artist.id}&size=${this.profileSize}`
                    })
                  }
                    .width('100%')
                    .aspectRatio(1)
                    .justifyContent(FlexAlign.Center)
                  Text(artist.name)
                    .width('100%')
                    .fontSize(16)
                    .fontColor($r('app.color.font'))
                    .margin({ top: 10 })
                    .maxLines(1)
                    .textAlign(TextAlign.Center)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .wordBreak(WordBreak.BREAK_ALL)
                }
                .padding(10)
                .width('100%')
                .height('auto')
              }
              .width('100%')
              .height('auto')
              .margin({ bottom: this.startPlaying === true && index === this.artists.length - 1 ? 85 : 0 })
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
        .columnsTemplate(this.displayWidth > 1400 ? "1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr" :
          (this.displayWidth > 1200 ? "1fr 1fr 1fr 1fr 1fr 1fr 1fr" :
            (this.displayWidth > 1000 ? "1fr 1fr 1fr 1fr 1fr 1fr" : (this.displayWidth > 800 ? "1fr 1fr 1fr 1fr 1fr" :
              (this.displayWidth > 400 ? "1fr 1fr 1fr 1fr" : "1fr 1fr 1fr")))))
        .columnsGap(0)
        .rowsGap(0)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
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

      Button({ type: ButtonType.Normal }) {
        Image($r('app.media.totop'))
          .width(20)
          .aspectRatio(1)
          .draggable(false)
      }
      .position({
        right: 15,
        bottom: this.startPlaying ? 100 : 15
      })
      .animation({ duration: 510, curve: Curve.EaseInOut })
      .width(36)
      .height(36)
      .borderRadius(6)
      .backgroundColor(Color.Transparent)
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .shadow({
        radius: 12,
        color: $r('sys.color.ohos_id_shadow_default_lg_dark'),
      })
      .onClick(async () => {
        this.artistsScroller.scrollEdge(Edge.Top)
      })
      .visibility(this.showProgress === false ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}