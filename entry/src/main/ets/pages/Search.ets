import { Album, Artist, Line, SearchResult, Song, StructuredLyric } from '../utils/Interface';
import { curves } from '@kit.ArkUI';
import { getLyrics, getSong, search } from '../utils/Api';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';

@Component
export default struct Search_ {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @State songs: Song[] = []
  @State albums: Album[] = []
  @State artists: Artist[] = []
  @State searchQuery: string = ""
  @Consume artist: Artist | undefined
  @Consume album: Album
  @Consume nowPlayingSong: Song | undefined
  @Consume nowPlayingLyrics: StructuredLyric | undefined
  @Consume nowPlayingLyricsByGroup: Line[][]
  @Consume nowPlayingList: Song[]
  @Consume nowPlayingListOriginal: Song[]
  @Consume nowPlayingIndex: number
  @Consume isPlaying: boolean
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume serverStatus: boolean
  @Consume showMenu: boolean
  @Consume longPressSong: Song | undefined
  @Consume sleepTime: number
  @Consume selectedIndex: number
  @Consume showProgress: boolean
  @Consume avPlayer: media.AVPlayer | undefined
  @Consume pageStack: NavPathStack
  @StorageLink('playMode') playMode: number = 0
  @Consume session: AVSessionManager.AVSession | undefined
  @State coverSize: number = 256
  @State profileSize: number = 256
  @Consume displayWidth: number

  groupLyrics() {
    this.nowPlayingLyricsByGroup = []
    let index = -1
    for (let line of this.nowPlayingLyrics!.line) {
      if (this.nowPlayingLyricsByGroup.length === 0 || line.start !== this.nowPlayingLyricsByGroup[index][0].start) {
        index++
        this.nowPlayingLyricsByGroup.push([])
        this.nowPlayingLyricsByGroup[index].push(line)
      } else {
        this.nowPlayingLyricsByGroup[index].push(line)
      }
    }
  }

  getNowPlayingIndex(song: Song, list: Song[]) {
    for (let index = 0; index < list.length; index++) {
      if (list[index].id === song.id) {
        this.nowPlayingIndex = index
        break;
      }
    }
  }

  shuffleList<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      let temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
    return array;
  }

  build() {
    Column() {
      Row() {
        TextInput({
          placeholder: '请输入...',
          text: $$this.searchQuery
        })
          .width("100%")
          .height(this.displayWidth > 1400 ? 50 : 40)
          .layoutWeight(1)
          .borderRadius(15)
          .margin({ left: 20, right: 10 })
          .caretColor($r('app.color.font_secondary'))
          .fontColor($r('app.color.font'))
          .fontSize(this.displayWidth > 1400 ? 22 : 20)
          .placeholderFont({
            size: this.displayWidth > 1400 ? 22 : 20
          })
          .type(InputType.Normal)
          .enterKeyType(EnterKeyType.Search)
          .onSubmit(async (enterKey: EnterKeyType, event: SubmitEvent) => {
            if (this.searchQuery !== "") {
              this.showProgress = true;
              this.songs = [];
              this.albums = [];
              this.artists = [];
              let searchResult: SearchResult | undefined =
                await search(this.baseURL, this.username, this.password, this.searchQuery)
              if (searchResult !== undefined) {
                if (searchResult.song !== undefined) {
                  this.songs = searchResult.song;
                }
                if (searchResult.album !== undefined) {
                  this.albums = searchResult.album;
                }
                if (searchResult.artist !== undefined) {
                  this.artists = searchResult.artist;
                }
              }
              this.showProgress = false;
            }
          })

        Button({ type: ButtonType.Normal }) {
          Text("搜索")
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(this.displayWidth > 1400 ? 20 : 18)
            .fontColor($r('app.color.font'))
        }
        .width(this.displayWidth > 1400 ? 100 : 80)
        .height(this.displayWidth > 1400 ? 50 : 40)
        .borderRadius(15)
        .padding({ left: 20, right: 20 })
        .margin({ right: 20 })
        .backgroundColor($r('app.color.bar_background'))
        .onClick(async () => {
          if (this.searchQuery !== "") {
            this.showProgress = true;
            this.songs = [];
            this.albums = [];
            this.artists = [];
            let searchResult: SearchResult | undefined =
              await search(this.baseURL, this.username, this.password, this.searchQuery)
            if (searchResult !== undefined) {
              if (searchResult.song !== undefined) {
                this.songs = searchResult.song;
              }
              if (searchResult.album !== undefined) {
                this.albums = searchResult.album;
              }
              if (searchResult.artist !== undefined) {
                this.artists = searchResult.artist;
              }
            }
            this.showProgress = false;
          }
        })
      }
      .margin({ bottom: 15 })

      Scroll() {
        Column() {
          Column() {
            Text("歌曲")
              .width('100%')
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .margin({ top: 10, bottom: 10 })
              .padding({ left: 20 })
              .textAlign(TextAlign.Start)

            ForEach(this.songs, (song: Song, index) => {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${song.id}&size=${this.coverSize}`)
                    .alt($rawfile('nocover.png'))
                    .objectFit(ImageFit.Contain)
                    .width(60)
                    .aspectRatio(1)
                    .borderRadius(5)
                  Column() {
                    Text(song.title)
                      .fontSize(18)
                      .fontColor($r('app.color.font'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(song.artist + " - " + song.album)
                      .fontSize(15)
                      .fontColor($r('app.color.font_secondary'))
                      .margin({ top: 5 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                  .layoutWeight(1)
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .height('100%')
                .padding({ right: 15 })
              }
              .width('100%')
              .height(80)
              .borderRadius(10)
              .backgroundColor('#00000000')
              .padding({ left: 20, right: 20 })
              .animation({ curve: curves.springMotion(0.6, 1) })
              .onClick(async () => {
                animateTo({
                  duration: 300,
                  curve: Curve.EaseOut,
                }, () => {
                  this.showSidebar = false
                })
                this.startPlaying = true
                await this.avPlayer!.reset()
                this.isPlaying = true
                this.nowPlayingSong = song
                this.nowPlayingLyrics = await getLyrics(this.baseURL, this.username, this.password, song.id)
                if (this.nowPlayingLyrics !== undefined) {
                  this.groupLyrics()
                }
                this.nowPlayingListOriginal = this.songs.slice()
                if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_SHUFFLE) {
                  this.nowPlayingList = this.shuffleList(this.nowPlayingListOriginal.slice())
                } else {
                  this.nowPlayingList = this.nowPlayingListOriginal.slice()
                }
                this.getNowPlayingIndex(song, this.nowPlayingList)
                this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${song.id}&format=raw`;
              })
              .gesture(
                LongPressGesture()
                  .onAction(async (event: GestureEvent) => {
                    this.longPressSong = song
                    this.showMenu = true
                    let tmp_song: Song | undefined =
                      await getSong(this.baseURL, this.username, this.password, this.longPressSong!.id)
                    if (tmp_song !== undefined && tmp_song.starred !== undefined) {
                      this.longPressSong!.starred = tmp_song.starred
                    }
                  })
              )
            })
          }
          .width('100%')
          .visibility(this.songs.length > 0 ? Visibility.Visible : Visibility.None)

          Column() {
            Text("专辑")
              .width('100%')
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .margin({ top: 10, bottom: 10 })
              .padding({ left: 20 })
              .textAlign(TextAlign.Start)

            List() {
              ForEach(this.albums, (album: Album, index) => {
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
                  .margin({ left: index === 0 ? 10 : 0, right: index === this.albums.length - 1 ? 10 : 0 })
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
          .height('30%')
          .visibility(this.albums.length > 0 ? Visibility.Visible : Visibility.None)

          Column() {
            Text("艺术家")
              .width('100%')
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .margin({ top: 10, bottom: 10 })
              .padding({ left: 20 })
              .textAlign(TextAlign.Start)

            List() {
              ForEach(this.artists, (artist: Artist, index) => {
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
                  .margin({ left: index === 0 ? 10 : 0, right: index === this.artists.length - 1 ? 10 : 0 })
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
          .height('30%')
          .visibility(this.artists.length > 0 ? Visibility.Visible : Visibility.None)

          Column() {
            Text("没有结果")
              .fontSize(32)
              .fontColor($r('app.color.font'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ bottom: 160 })
          .visibility(this.songs.length === 0 && this.albums.length === 0 && this.artists.length === 0 &&
            this.showProgress === false ? Visibility.Visible : Visibility.None)

          Column()
            .height(this.startPlaying === true ? 95 : 10)
        }
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
  }
}