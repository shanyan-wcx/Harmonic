import { Album, Artist } from '../utils/Interface';
import { curves } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

let deviceTypeInfo: string = deviceInfo.deviceType;

@Component
export default struct Home {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume recentAlbums: Album[]
  @Consume newestAlbums: Album[]
  @Consume frequentAlbums: Album[]
  @Consume starredAlbums: Album[]
  @Consume starredArtists: Artist[]
  @Consume randomAlbums: Album[]
  @Consume album: Album | undefined
  @Consume artist: Artist | undefined
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume auth: string
  @Consume getCoverUrl: string
  @State coverSize: number = 320
  @State profileSize: number = 256
  @Consume showProgress: boolean
  @Consume sidebarType: number
  @Consume displayWidth: number
  @Consume needUpdate: boolean
  @Consume showLibrary: boolean
  private recentAlbumsScroller: Scroller = new Scroller
  private newestAlbumsScroller: Scroller = new Scroller
  private frequentAlbumsScroller: Scroller = new Scroller
  private randomAlbumsScroller: Scroller = new Scroller
  private starredAlbumsScroller: Scroller = new Scroller
  private starredArtistsScroller: Scroller = new Scroller

  async aboutToAppear() {
    this.needUpdate = !this.needUpdate
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            Text("最近播放")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({ bottom: 5 })

            Row() {
              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .margin({ right: 10 })
              .onClick(() => {
                this.recentAlbumsScroller.scrollPage({
                  next: false,
                  animation: true
                })
              })

              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.recentAlbumsScroller.scrollPage({
                  next: true,
                  animation: true
                })
              })
            }
            .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom)

          List({ scroller: this.recentAlbumsScroller }) {
            ForEach(this.recentAlbums, (album: Album, index) => {
              ListItem() {
                Button({ type: ButtonType.Normal }) {
                  Column() {
                    Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                      .alt($rawfile('nocover.png'))
                      .objectFit(ImageFit.Contain)
                      .height('100%')
                      .aspectRatio(1)
                      .borderRadius(10)
                      .margin(10)
                  }
                  .width('auto')
                  .height('100%')
                }
                .width('auto')
                .height('100%')
                .margin({ left: index === 0 ? 10 : 0, right: index === this.recentAlbums!.length - 1 ? 10 : 0 })
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
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height(this.displayWidth > 1400 ? 250 : 210)
        .visibility(this.showProgress === true || this.recentAlbums.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Row() {
            Text("最近添加")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({ bottom: 5 })

            Row() {
              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .margin({ right: 10 })
              .onClick(() => {
                this.newestAlbumsScroller.scrollPage({
                  next: false,
                  animation: true
                })
              })

              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.newestAlbumsScroller.scrollPage({
                  next: true,
                  animation: true
                })
              })
            }
            .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom)

          List({ scroller: this.newestAlbumsScroller }) {
            ForEach(this.newestAlbums, (album: Album, index) => {
              ListItem() {
                Button({ type: ButtonType.Normal }) {
                  Column() {
                    Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                      .alt($rawfile('nocover.png'))
                      .objectFit(ImageFit.Contain)
                      .height('100%')
                      .aspectRatio(1)
                      .borderRadius(10)
                      .margin(10)
                  }
                  .width('auto')
                  .height('100%')
                }
                .width('auto')
                .height('100%')
                .margin({ left: index === 0 ? 10 : 0, right: index === this.newestAlbums!.length - 1 ? 10 : 0 })
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
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height(this.displayWidth > 1400 ? 250 : 210)
        .visibility(this.showProgress === true || this.newestAlbums.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Row() {
            Text("最常播放")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({ bottom: 5 })

            Row() {
              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .margin({ right: 10 })
              .onClick(() => {
                this.frequentAlbumsScroller.scrollPage({
                  next: false,
                  animation: true
                })
              })

              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.frequentAlbumsScroller.scrollPage({
                  next: true,
                  animation: true
                })
              })
            }
            .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom)

          List({ scroller: this.frequentAlbumsScroller }) {
            ForEach(this.frequentAlbums, (album: Album, index) => {
              ListItem() {
                Button({ type: ButtonType.Normal }) {
                  Column() {
                    Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                      .alt($rawfile('nocover.png'))
                      .objectFit(ImageFit.Contain)
                      .height('100%')
                      .aspectRatio(1)
                      .borderRadius(10)
                      .margin(10)
                  }
                  .width('auto')
                  .height('100%')
                }
                .width('auto')
                .height('100%')
                .margin({ left: index === 0 ? 10 : 0, right: index === this.frequentAlbums!.length - 1 ? 10 : 0 })
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
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height(this.displayWidth > 1400 ? 250 : 210)
        .visibility(this.showProgress === true || this.frequentAlbums.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Row() {
            Text("随机专辑")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({ bottom: 5 })

            Row() {
              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .margin({ right: 10 })
              .onClick(() => {
                this.randomAlbumsScroller.scrollPage({
                  next: false,
                  animation: true
                })
              })

              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.randomAlbumsScroller.scrollPage({
                  next: true,
                  animation: true
                })
              })
            }
            .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom)

          List({ scroller: this.randomAlbumsScroller }) {
            ForEach(this.randomAlbums, (album: Album, index) => {
              ListItem() {
                Button({ type: ButtonType.Normal }) {
                  Column() {
                    Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                      .alt($rawfile('nocover.png'))
                      .objectFit(ImageFit.Contain)
                      .height('100%')
                      .aspectRatio(1)
                      .borderRadius(10)
                      .margin(10)
                  }
                  .width('auto')
                  .height('100%')
                }
                .width('auto')
                .height('100%')
                .margin({ left: index === 0 ? 10 : 0, right: index === this.randomAlbums!.length - 1 ? 10 : 0 })
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
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height(this.displayWidth > 1400 ? 250 : 210)
        .visibility(this.showProgress === true || this.randomAlbums.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Row() {
            Text("收藏专辑")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({ bottom: 5 })

            Row() {
              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .margin({ right: 10 })
              .onClick(() => {
                this.starredAlbumsScroller.scrollPage({
                  next: false,
                  animation: true
                })
              })

              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.starredAlbumsScroller.scrollPage({
                  next: true,
                  animation: true
                })
              })
            }
            .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom)

          List({ scroller: this.starredAlbumsScroller }) {
            ForEach(this.starredAlbums, (album: Album, index) => {
              ListItem() {
                Button({ type: ButtonType.Normal }) {
                  Column() {
                    Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                      .alt($rawfile('nocover.png'))
                      .objectFit(ImageFit.Contain)
                      .height('100%')
                      .aspectRatio(1)
                      .borderRadius(10)
                      .margin(10)
                  }
                  .width('auto')
                  .height('100%')
                }
                .width('auto')
                .height('100%')
                .margin({ left: index === 0 ? 10 : 0, right: index === this.starredAlbums!.length - 1 ? 10 : 0 })
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
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height(this.displayWidth > 1400 ? 250 : 210)
        .visibility(this.showProgress === true || this.starredAlbums.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Row() {
            Text("收藏艺术家")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .margin({ bottom: 5 })

            Row() {
              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .margin({ right: 10 })
              .onClick(() => {
                this.starredArtistsScroller.scrollPage({
                  next: false,
                  animation: true
                })
              })

              Button({ type: ButtonType.Normal }) {
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .fontColor([$r('app.color.font')])
              }
              .width(30)
              .height(30)
              .borderRadius(5)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.starredArtistsScroller.scrollPage({
                  next: true,
                  animation: true
                })
              })
            }
            .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Bottom)

          List({ scroller: this.starredArtistsScroller }) {
            ForEach(this.starredArtists, (artist: Artist, index) => {
              ListItem() {
                Button({ type: ButtonType.Normal }) {
                  Column() {
                    Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${artist.id}&size=${this.profileSize}`)
                      .alt($rawfile('noprofile.jpg'))
                      .objectFit(ImageFit.Cover)
                      .height('100%')
                      .layoutWeight(1)
                      .aspectRatio(1)
                      .borderRadius(100)
                      .margin(10)
                    Text(artist.name)
                      .width('100%')
                      .fontSize(16)
                      .fontColor($r('app.color.font'))
                      .margin({ bottom: 10, left: 10, right: 10 })
                      .maxLines(1)
                      .textAlign(TextAlign.Center)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                  .height('100%')
                }
                .width(this.displayWidth > 1400 ? 160 : 124)
                .height('100%')
                .margin({ left: index === 0 ? 10 : 0, right: index === this.starredArtists!.length - 1 ? 10 : 0 })
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
          .layoutWeight(1)
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height(this.displayWidth > 1400 ? 230 : 195)
        .visibility(this.showProgress === true || this.starredArtists.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Text("什么都没有")
            .fontSize(32)
            .fontColor($r('app.color.font'))
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 160 })
        .justifyContent(FlexAlign.Center)
        .visibility(this.starredArtists.length === 0 && this.starredAlbums.length === 0 &&
          this.frequentAlbums.length === 0 && this.newestAlbums.length === 0 && this.recentAlbums.length === 0 &&
          this.showProgress === false ? Visibility.Visible : Visibility.None)
      }
      .padding({ bottom: this.startPlaying === true ? 95 : 10 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
    .align(Alignment.Top)
  }
}