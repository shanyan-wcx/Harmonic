import { Album, Artist } from '../utils/Interface'
import { curves, window } from '@kit.ArkUI';

@Builder
export function ArtistDetailBuilder() {
  ArtistDetail()
}

function calculateRow(itemsPerRow: number, totalItems: number): string {
  const rows = Math.ceil(totalItems / itemsPerRow);
  const rowFractions: Array<string> = Array(rows).fill('1fr');
  return rowFractions.join(' ');
}

function calculateColumns(itemsPerRow: number): string {
  const rowFractions: Array<string> = Array(itemsPerRow).fill('1fr');
  return rowFractions.join(' ');
}

@Entry
@Component
export default struct ArtistDetail {
  @Consume mainWindow: window.Window
  @State displayWidth: number = 0
  @Consume pageStack: NavPathStack
  @Consume showControlButton: boolean
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @Consume artist: Artist | null
  @Consume startPlaying: boolean
  @Consume album: Album
  @State albumPerRow: number = 3
  @State profileSize: number = 256
  @State coverSize: number = 256

  aboutToAppear() {
    this.displayWidth = px2vp(this.mainWindow.getWindowProperties().windowRect.width)
    this.mainWindow.on('windowSizeChange', (size) => {
      this.displayWidth = px2vp(size.width)
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${this.artist!.id}&size=${this.profileSize}`)
            .alt($rawfile('noprofile.jpg'))
            .objectFit(ImageFit.Fill)
            .width(120)
            .aspectRatio(1)
            .borderRadius(100)
          Column() {
            Text(this.artist!.name)
              .fontSize(24)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.artist!.biography)
              .fontSize(18)
              .fontColor($r('app.color.font_secondary'))
              .margin({ top: 10 })
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.JUSTIFY)
          }
          .width('100%')
          .height('auto')
          .padding({
            top: 20,
            bottom: 20,
            left: 40,
            right: 40
          })

          Divider()
            .width('90%')
            .height(1)
            .color($r('app.color.divider'))

          Text("专辑")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, top: 20, bottom: 5 })

          Grid() {
            ForEach(this.artist!.album, (album: Album, index) => {
              GridItem() {
                Button({ type: ButtonType.Normal }) {
                  Column() {
                    Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                      .alt($rawfile('nocover.png'))
                      .objectFit(ImageFit.Fill)
                      .width('100%')
                      .aspectRatio(1)
                      .borderRadius(10)
                      .margin(10)
                  }
                  .width('100%')
                  .aspectRatio(1)
                }
                .width('100%')
                .aspectRatio(1)
                .borderRadius(10)
                .backgroundColor('#00000000')
                .onClick(() => {
                  this.album = album
                  this.pageStack.replacePathByName('AlbumDetail', null);
                })
              }
            })
          }
          .width('100%')
          .height((this.displayWidth - 20) / this.albumPerRow * Math.ceil(this.artist!.albumCount / this.albumPerRow))
          .columnsTemplate(calculateColumns(this.albumPerRow))
          .rowsTemplate(calculateRow(this.albumPerRow, this.artist!.albumCount))
          .columnsGap(0)
          .rowsGap(0)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Fade)
          .padding({ left: 10, right: 10 })
        }
        .width('100%')
        .height('auto')
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: this.startPlaying === true ? 85 : 0 })
      .animation({ curve: curves.springMotion(0.6, 1) })
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .backgroundColor($r('app.color.content_background'))
  }
}