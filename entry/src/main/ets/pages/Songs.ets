import { curves } from '@kit.ArkUI'
import { media } from '@kit.MediaKit'
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { getLyrics } from '../utils/Api'
import { Song, StructuredLyric, Line } from '../utils/Interface'

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
  @Consume sleepTime: number
  @Consume avPlayer: media.AVPlayer | null
  @StorageLink('playMode') playMode: number = 0
  @Consume session: AVSessionManager.AVSession | null
  @State coverSize: number = 128

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

  getStar() {
    this.nowPlayingStar = false
    for (let song of this.starredSongs) {
      if (song.id === this.nowPlayingSong!.id) {
        this.nowPlayingStar = true
        break
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
      List() {
        ForEach(this.songs, (song: Song, index) => {
          ListItem() {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${song.id}&size=${this.coverSize}`)
                  .alt($rawfile('nocover.png'))
                  .objectFit(ImageFit.Fill)
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
            }
            .width('100%')
            .height(80)
            .borderRadius(10)
            .backgroundColor('#00000000')
            .padding({ left: 20, right: 20 })
            .margin({ bottom: this.startPlaying === true && index === this.songs.length - 1 ? 85 : 0 })
            .animation({ curve: curves.springMotion(0.6, 1) })
            .onClick(async () => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              await this.avPlayer!.reset()
              this.nowPlayingSong = song
              this.nowPlayingLyrics = await getLyrics(song.id)
              if (this.nowPlayingLyrics !== null) {
                this.groupLyrics()
              }
              this.nowPlayingListOriginal = this.songs
              if (this.playMode === 2) {
                let songs = this.songs.slice()
                this.nowPlayingList = this.shuffleList(songs)
              } else {
                this.nowPlayingList = this.songs
              }
              this.getNowPlayingIndex(song, this.nowPlayingList)
              this.getStar()
              this.isPlaying = true
              this.avPlayer!.url = this.baseURL + '/stream' + this.auth + `&id=${song.id}&format=raw`;
              this.startPlaying = true
            })
          }
        })
      }
      .width('100%')
      .height('100%')
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .visibility(this.songs.length > 0 ? Visibility.Visible : Visibility.None)

      Column() {
        Text("没有歌曲")
          .fontSize(32)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .visibility(this.songs.length === 0 && this.serverStatus === true ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}