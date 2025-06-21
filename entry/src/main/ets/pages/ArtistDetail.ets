import { Album, Artist } from '../utils/Interface';
import { curves } from '@kit.ArkUI';
import { getArtistAlbum, getArtistInfo } from '../utils/Api';

@Builder
export function ArtistDetailBuilder() {
  ArtistDetail()
}

@Entry
@Component
export default struct ArtistDetail {
  @Consume displayWidth: number
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
  @Consume artist: Artist | undefined
  @Consume startPlaying: boolean
  @Consume album: Album
  @State albumPerRow: number = 3
  @State profileSize: number = 256
  @State coverSize: number = 256
  @State showProgress: boolean = false

  async aboutToAppear() {
    this.showProgress = true
    this.artist!.biography = await getArtistInfo(this.baseURL, this.username, this.password, this.artist!.id)
    this.artist!.album = await getArtistAlbum(this.baseURL, this.username, this.password, this.artist!.id)
    this.showProgress = false
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${this.artist!.id}&size=${this.profileSize}`)
            .alt($rawfile('noprofile.jpg'))
            .objectFit(ImageFit.Cover)
            .width(120)
            .aspectRatio(1)
            .borderRadius(10000)
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
                      .objectFit(ImageFit.Contain)
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
                  this.pageStack.replacePathByName('AlbumDetail', undefined);
                })
              }
            })
          }
          .width('100%')
          .columnsTemplate(this.displayWidth > 1400 ? "1fr 1fr 1fr 1fr 1fr 1fr 1fr" :
            (this.displayWidth > 1000 ? "1fr 1fr 1fr 1fr 1fr 1fr" :
              (this.displayWidth > 800 ? "1fr 1fr 1fr 1fr 1fr" : (this.displayWidth > 400 ? "1fr 1fr 1fr 1fr" : "1fr 1fr 1fr"))))
          .columnsGap(0)
          .rowsGap(0)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Fade)
          .padding({ left: 10, right: 10, bottom: 10 })
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
      .visibility(this.showProgress === false ? Visibility.Visible : Visibility.None)

      Column() {
        LoadingProgress()
          .width("100%")
          .height(80)
          .color($r('app.color.font'))
          .margin({ bottom: 160 })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .visibility(this.showProgress === true ? Visibility.Visible : Visibility.None)
    }
    .backgroundColor($r('app.color.content_background'))
  }
}