import { curves } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { i18n } from '@kit.LocalizationKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { getLyrics, getStarred } from '../utils/Api';
import { Line, Song, StructuredLyric } from '../utils/Interface';

let indexUtil = i18n.getInstance();
let indexList = indexUtil.getIndexList();
indexList[0] = '#'
indexList.splice(indexList.length - 1, 1)

@Component
export default struct Songs {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @Consume songs: Song[]
  @Consume nowPlayingSong: Song | null
  @Consume nowPlayingLyrics: StructuredLyric | null
  @Consume nowPlayingLyricsByGroup: Line[][]
  @Consume nowPlayingList: Song[]
  @Consume nowPlayingListOriginal: Song[]
  @Consume nowPlayingIndex: number
  @Consume nowPlayingStar: boolean
  @Consume starredSongs: Song[]
  @Consume isPlaying: boolean
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume serverStatus: boolean
  @Consume showMenu: boolean
  @Consume longPressSong: Song | null
  @Consume longPressStar: boolean
  @Consume sleepTime: number
  @Consume selectedIndex: number
  @Consume showProgress: boolean
  @Consume avPlayer: media.AVPlayer | null
  @StorageLink('playMode') playMode: number = 0
  @Consume session: AVSessionManager.AVSession | null
  @State coverSize: number = 128
  private listScroller: Scroller = new Scroller

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

  async getStar(song: Song) {
    let starredSongs: Song[] = []
    let starred = await getStarred(this.baseURL, this.username, this.password)
    if (starred !== null) {
      starredSongs = starred!.song!
    }
    if (starredSongs.length > 0) {
      for (let starredSong of starredSongs) {
        if (song.id === starredSong.id) {
          return true
        }
      }
    }
    return false
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
    Stack({ alignContent: Alignment.End }) {
      List({ scroller: this.listScroller }) {
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
            .margin({ bottom: index === this.songs.length - 1 ? (this.startPlaying ? 85 : 10) : 0 })
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
              if (this.nowPlayingLyrics !== null) {
                this.groupLyrics()
              }
              this.nowPlayingListOriginal = this.songs.slice()
              if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_SHUFFLE) {
                this.nowPlayingList = this.shuffleList(this.nowPlayingListOriginal.slice())
              } else {
                this.nowPlayingList = this.nowPlayingListOriginal.slice()
              }
              this.getNowPlayingIndex(song, this.nowPlayingList)
              this.nowPlayingStar = await this.getStar(song)
              this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${song.id}&format=raw`;
            })
            .gesture(
              LongPressGesture()
                .onAction(async (event: GestureEvent) => {
                  this.longPressSong = song
                  this.showMenu = true
                  this.longPressStar = await this.getStar(song)
                })
            )
          }
        })
      }
      .width('100%')
      .height('100%')
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .visibility(this.songs.length > 0 ? Visibility.Visible : Visibility.None)
      .onScrollIndex((firstIndex: number) => {
        let initial = indexUtil.getIndex(this.songs[firstIndex].title);
        if (initial === '…') {
          this.selectedIndex = 0
        } else {
          for (let index = 0; index < indexList.length; index++) {
            if (indexList[index] === initial) {
              this.selectedIndex = index
              break
            }
          }
        }
      })

      Column() {
        Text("没有歌曲")
          .fontSize(32)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 160 })
      .visibility(this.songs.length === 0 && this.serverStatus === true ? Visibility.Visible : Visibility.None)

      AlphabetIndexer({ arrayValue: indexList, selected: 0 })
        .selected(this.selectedIndex)
        .color($r('app.color.font_secondary'))
        .selectedColor($r('app.color.font'))
        .selectedBackgroundColor($r('app.color.index'))
        .itemSize(20)
        .itemBorderRadius(20)
        .font({
          size: 12
        })
        .selectedFont({
          size: 13
        })
        .margin({ right: 5 })
        .visibility(this.songs.length > 0 ? Visibility.Visible : Visibility.None)
        .onSelect((index: number) => {
          if (index === 0) {
            this.listScroller.scrollToIndex(0, false, ScrollAlign.START)
          } else {
            let find = false
            while (index) {
              for (let index2 = 0; index2 < this.songs.length; index2++) {
                if (indexUtil.getIndex(this.songs[index2].title) === indexList[index]) {
                  this.listScroller.scrollToIndex(index2, false, ScrollAlign.START)
                  find = true
                  break;
                }
              }
              if (find === true) {
                break
              }
              index--
            }
            if (find === false) {
              this.listScroller.scrollToIndex(0, false, ScrollAlign.START)
            }
          }
        })
    }
    .width('100%')
    .height('100%')
  }
}