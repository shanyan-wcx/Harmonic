import { getFrequentAlbums, getRecentAlbums, getStarredAlbums, getStarredArtists } from '../utils/Api';
import { Album, Artist } from '../utils/Interface';
import { curves } from '@kit.ArkUI';

@Component
export default struct Home {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @State recentAlbums: Album[] | undefined = []
  @State frequentAlbums: Album[] | undefined = []
  @State starredAlbums: Album[] | undefined = []
  @State starredArtists: Artist[] | undefined = []
  @Consume album: Album | null
  @Consume artist: Artist | null
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume auth: string
  @Consume getCoverUrl: string
  @State coverSize: number = 320
  @State profileSize: number = 256
  @Consume showProgress: boolean

  async aboutToAppear() {
    this.recentAlbums = await getRecentAlbums(this.baseURL, this.username, this.password)
    this.frequentAlbums = await getFrequentAlbums(this.baseURL, this.username, this.password)
    this.starredAlbums = await getStarredAlbums(this.baseURL, this.username, this.password)
    this.starredArtists = await getStarredArtists(this.baseURL, this.username, this.password)
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Text("最近添加")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 15, bottom: 5 })
            .textAlign(TextAlign.Start)
          List() {
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
                .backgroundColor('#00000000')
                .onClick(() => {
                  animateTo({
                    duration: 300,
                    curve: Curve.EaseOut,
                  }, () => {
                    this.showSidebar = false
                  })
                  this.album = album
                  this.pageStack.pushPathByName('AlbumDetail', null);
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
        .height('30%')
        .visibility(this.recentAlbums === undefined || this.recentAlbums!.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Text("最常播放")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 15, bottom: 5 })
            .textAlign(TextAlign.Start)
          List() {
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
                .margin({ left: index === 0 ? 10 : 0, right: index === this.recentAlbums!.length - 1 ? 10 : 0 })
                .animation({ curve: curves.springMotion(0.6, 1) })
                .borderRadius(10)
                .backgroundColor('#00000000')
                .onClick(() => {
                  animateTo({
                    duration: 300,
                    curve: Curve.EaseOut,
                  }, () => {
                    this.showSidebar = false
                  })
                  this.album = album
                  this.pageStack.pushPathByName('AlbumDetail', null);
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
        .height('30%')
        .visibility(this.frequentAlbums === undefined || this.frequentAlbums!.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Text("收藏专辑")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 15, bottom: 5 })
            .textAlign(TextAlign.Start)
          List() {
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
                .margin({ left: index === 0 ? 10 : 0, right: index === this.recentAlbums!.length - 1 ? 10 : 0 })
                .animation({ curve: curves.springMotion(0.6, 1) })
                .borderRadius(10)
                .backgroundColor('#00000000')
                .onClick(() => {
                  animateTo({
                    duration: 300,
                    curve: Curve.EaseOut,
                  }, () => {
                    this.showSidebar = false
                  })
                  this.album = album
                  this.pageStack.pushPathByName('AlbumDetail', null);
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
        .height('30%')
        .visibility(this.starredAlbums === undefined || this.starredAlbums!.length === 0 ? Visibility.None :
        Visibility.Visible)

        Column() {
          Text("收藏艺术家")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 15, bottom: 5 })
            .textAlign(TextAlign.Start)
          List() {
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
                      .width('auto')
                      .fontSize(16)
                      .fontColor($r('app.color.font'))
                      .margin({ bottom: 10, left: 10, right: 10 })
                      .maxLines(1)
                      .textAlign(TextAlign.Center)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('auto')
                  .height('100%')
                }
                .width('auto')
                .height('100%')
                .margin({ left: index === 0 ? 10 : 0, right: index === this.recentAlbums!.length - 1 ? 10 : 0 })
                .animation({ curve: curves.springMotion(0.6, 1) })
                .borderRadius(10)
                .backgroundColor('#00000000')
                .onClick(() => {
                  animateTo({
                    duration: 300,
                    curve: Curve.EaseOut,
                  }, () => {
                    this.showSidebar = false
                  })
                  this.artist = artist
                  this.pageStack.pushPathByName('ArtistDetail', null);
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
        .height('30%')
        .visibility(this.starredArtists === undefined || this.starredArtists!.length === 0 ? Visibility.None :
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
        .visibility(((this.starredArtists === undefined || this.starredArtists!.length === 0) &&
          (this.starredAlbums === undefined || this.starredAlbums!.length === 0) &&
          (this.frequentAlbums === undefined || this.frequentAlbums!.length === 0) &&
          (this.recentAlbums === undefined || this.recentAlbums!.length === 0)) && this.showProgress === false ? Visibility.Visible : Visibility.None)
      }
      .padding({ bottom: this.startPlaying === true ? 95 : 20 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Fade)
    .align(Alignment.Top)
  }
}