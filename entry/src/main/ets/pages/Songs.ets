import { Song, StructuredLyric, Line, MusicFolder } from '../utils/Interface'
import { media } from '@kit.MediaKit'
import { getAllSongs, getLyrics, getSong } from '../utils/Api'
import { avSession as AVSessionManager } from '@kit.AVSessionKit';

@Component
export default struct Songs {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @StorageLink('playMode') playMode: number = 0
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume songs: Song[]
  @Consume showProgress: boolean
  @Consume showLibrary: boolean
  @Consume showMenu: boolean
  @State coverSize: number = 128
  @Consume nowPlayingSong: Song | undefined
  @Consume nowPlayingLyrics: StructuredLyric | undefined
  @Consume nowPlayingLyricsByGroup: Line[][]
  @Consume nowPlayingList: Song[]
  @Consume nowPlayingListOriginal: Song[]
  @Consume nowPlayingIndex: number
  @Consume isPlaying: boolean
  @Consume needUpdate: boolean
  @Consume longPressSong: Song | undefined
  @Consume avPlayer: media.AVPlayer | undefined
  @Consume songsPage: number
  @Consume musicFolders: MusicFolder[]
  @Consume libraryStates: Record<number, boolean>
  private songsScroller: Scroller = new Scroller

  shuffleList<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      let temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
    return array;
  }

  getNowPlayingIndex(song: Song, list: Song[]) {
    for (let index = 0; index < list.length; index++) {
      if (list[index].id === song.id) {
        this.nowPlayingIndex = index
        break;
      }
    }
  }

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

  async aboutToAppear() {
    this.needUpdate = !this.needUpdate
  }

  build() {
    Stack() {
      Column() {
        List({ scroller: this.songsScroller }) {
          ForEach(this.songs, (song: Song, index) => {
            ListItem() {
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
                    Text(song.artist)
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
              }
              .width('100%')
              .height(80)
              .borderRadius(10)
              .padding({ left: 20, right: 20 })
              .margin({
                bottom: this.startPlaying
                  ? (index === this.songs.length - 1 ? 95 : 0)
                  : (index === this.songs.length - 1 ? 10 : 0)
              })
              .backgroundColor(Color.Transparent)
              .onClick(async () => {
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
            }
          })
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .alignListItem(ListItemAlign.Center)
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
        .onReachEnd(async () => {
          let size = 500
          let keys = Object.keys(this.libraryStates)
          for (const id of keys) {
            if (this.libraryStates[id] === true) {
              if (!this.musicFolders.some(item => item.id === Number(id))) {
                this.libraryStates[id] = false
                continue;
              }
              let pageSongs =
                await getAllSongs(this.baseURL, this.username, this.password, this.songsPage * size, Number(id))
              if (pageSongs === undefined || pageSongs.length === 0) {
                continue;
              }
              this.songs.push(...pageSongs)
            }
          }
          this.songsPage++
        })
        .visibility(this.songs.length > 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)

        Column() {
          Text("没有歌曲")
            .fontSize(32)
            .fontColor($r('app.color.font'))
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 140 })
        .justifyContent(FlexAlign.Center)
        .visibility(this.songs.length === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .height('100%')

      Button({ type: ButtonType.Normal }) {
        Image($r('app.media.totop'))
          .width(26)
          .aspectRatio(1)
      }
      .position({
        right: 15,
        bottom: this.startPlaying ? 100 : 15
      })
      .animation({ duration: 510, curve: Curve.EaseInOut })
      .width(48)
      .height(48)
      .borderRadius(8)
      .backgroundColor(Color.Transparent)
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .shadow({
        radius: 20,
        color: $r('app.color.shadow'),
      })
      .onClick(async () => {
        this.songsScroller.scrollEdge(Edge.Top)
      })
    }
    .width('100%')
    .height('100%')
  }
}