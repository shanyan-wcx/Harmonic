import { Album, Artist, MusicFolder } from '../utils/Interface';
import { curves, SymbolGlyphModifier } from '@kit.ArkUI';
import { getAlbumList, getArtist, getArtistInfo, star, unstar } from '../utils/Api';

@Builder
export function ArtistDetailBuilder() {
  ArtistDetail()
}

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
  @Consume musicFolders: MusicFolder[]
  @Consume libraryStates: Record<number, boolean>
  @Consume needUpdate: boolean
  @Consume nowPage: number
  @State tempAlbums: Album[] = []
  @State tempLibraryAlbums: Album[] = []
  @State albumPerRow: number = 3
  @State profileSize: number = 256
  @State coverSize: number = 256
  @State showProgress: boolean = false

  async aboutToAppear() {
    this.showProgress = true
    this.artist!.biography = await getArtistInfo(this.baseURL, this.username, this.password, this.artist!.id)
    this.tempLibraryAlbums = []
    let keys = Object.keys(this.libraryStates)
    for (const id of keys) {
      if (this.libraryStates[id] === true) {
        if (!this.musicFolders.some(item => item.id === Number(id))) {
          this.libraryStates[id] = false
          continue;
        }
        let offset = 0
        let size = 500
        while (true) {
          let albums = await getAlbumList(this.baseURL, this.username, this.password, offset, Number(id))
          if (albums === undefined || albums.length === 0) {
            break;
          }
          this.tempAlbums.push(...albums)
          if (albums.length < size) {
            break;
          }
          offset += size;
        }
        this.tempLibraryAlbums.unshift(...this.tempAlbums.filter(album => album.artistId === this.artist?.id))
        this.tempAlbums = []
      }
    }
    this.artist!.album = this.tempLibraryAlbums
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
            .width('100%')
            .height(1)
            .margin({ left: 20, right: 20 })
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
                .backgroundColor(Color.Transparent)
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
          .edgeEffect(EdgeEffect.Fade, {alwaysEnabled: false})
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
    .menus([{
      value: "star",
      symbolIcon: new SymbolGlyphModifier(this.artist!.starred === undefined ? $r('sys.symbol.heart') : $r('sys.symbol.heart_fill')),
      action: async () => {
        if (this.artist!.starred !== undefined) {
          let starStatus = await unstar(this.baseURL, this.username, this.password, this.artist!.id, 'artist')
          if (starStatus === true) {
            this.getUIContext().getPromptAction().showToast({
              message: '取消收藏成功！',
              duration: 500
            });
            this.artist!.starred = undefined
            if (this.nowPage === 0) {
              this.needUpdate = !this.needUpdate
            }
          } else {
            this.getUIContext().getPromptAction().showToast({
              message: '取消收藏失败，请检查网络！',
              duration: 500
            });
          }
        } else {
          let starStatus = await star(this.baseURL, this.username, this.password, this.artist!.id, 'artist')
          if (starStatus === true) {
            this.getUIContext().getPromptAction().showToast({
              message: '收藏成功！',
              duration: 500
            });
            let tmp_artist: Artist | undefined =
              await getArtist(this.baseURL, this.username, this.password, this.artist!.id)
            if (tmp_artist !== undefined && tmp_artist.starred !== undefined) {
              this.artist!.starred = tmp_artist.starred
            }
            if (this.nowPage === 0) {
              this.needUpdate = !this.needUpdate
            }
          } else {
            this.getUIContext().getPromptAction().showToast({
              message: '收藏失败，请检查网络！',
              duration: 500
            });
          }
        }
      }
    }])
  }
}