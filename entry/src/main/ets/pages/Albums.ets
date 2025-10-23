import { Album, MusicFolder, Song } from '../utils/Interface';
import { getAlbumList } from '../utils/Api';
import { coverImage } from '../utils/Component';

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
  @Consume albums: Album[]
  @Consume album: Album | undefined
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume serverStatus: boolean
  @Consume discs: Song[][]
  @Consume displayWidth: number
  @Consume showProgress: boolean
  @Consume needUpdate: boolean
  @Consume showLibrary: boolean
  @Consume albumsPage: number
  @Consume musicFolders: MusicFolder[]
  @Consume libraryStates: Record<number, boolean>
  @State coverSize: number = 320
  private albumsScroller: Scroller = new Scroller();

  async aboutToAppear() {
    this.needUpdate = !this.needUpdate
  }

  build() {
    Stack() {
      Column() {
        Grid(this.albumsScroller) {
          ForEach(this.albums, (album: Album, index) => {
            GridItem() {
              Button({ type: ButtonType.Normal }) {
                Column() {
                  Column(){
                    coverImage({
                      url: this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`,
                      radius: 10
                    })
                  }
                  .width('100%')
                  .layoutWeight(1)
                  .aspectRatio(1)
                  .justifyContent(FlexAlign.Center)

                  Text(album.title)
                    .fontSize(16)
                    .fontColor($r('app.color.font'))
                    .margin({ top: 5 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .wordBreak(WordBreak.BREAK_ALL)
                  Text(album.artist)
                    .fontSize(14)
                    .fontColor($r('app.color.font_secondary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .wordBreak(WordBreak.BREAK_ALL)
                }
                .width('100%')
                .height('auto')
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .height('auto')
              .borderRadius(10)
              .clip(true)
              .padding({ left: 10, right: 10, top: 10, bottom: 7 })
              .margin({ bottom: this.startPlaying === true && index === this.albums.length - 1 ? 85 : 0 })
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
        .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
        .padding({ left: 10, right: 10, bottom: 10 })
        .onReachEnd(async () => {
          let size = 500
          let keys = Object.keys(this.libraryStates)
          for (const id of keys) {
            if (this.libraryStates[id] === true) {
              if (!this.musicFolders.some(item => item.id === Number(id))) {
                this.libraryStates[id] = false
                continue;
              }
              let pageAlbums =
                await getAlbumList(this.baseURL, this.username, this.password, this.albumsPage * size, Number(id))
              if (pageAlbums === undefined || pageAlbums.length === 0) {
                continue;
              }
              this.albums.push(...pageAlbums)
            }
          }
          this.albumsPage++
        })
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
        this.albumsScroller.scrollEdge(Edge.Top)
      })
      .visibility(this.showProgress === false ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}