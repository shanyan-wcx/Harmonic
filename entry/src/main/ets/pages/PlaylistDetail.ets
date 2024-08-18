import { curves } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { getLyrics, getStarred } from '../utils/Api';
import { Playlist, Song, StructuredLyric, Line } from '../utils/Interface'
import editPlaylistBuilder from './dialogs/EditPlaylist';

function formatDuration(seconds: number): string {
  const roundedSeconds = Math.floor(seconds);
  const hours = Math.floor(roundedSeconds / 3600);
  const minutes = Math.floor((roundedSeconds % 3600) / 60);
  const secs = roundedSeconds % 60;
  const paddedMinutes = minutes.toString().padStart(2, '0');
  const paddedSeconds = secs.toString().padStart(2, '0');
  let formattedTime = `${paddedMinutes}:${paddedSeconds}`;
  if (hours > 0) {
    const paddedHours = hours.toString().padStart(2, '0');
    formattedTime = `${paddedHours}:${formattedTime}`;
  }
  return formattedTime;
}

function formatDate(dateString: string): string {
  const date = new Date(dateString);
  const year = date.getUTCFullYear();
  const month = ('0' + (date.getUTCMonth() + 1)).slice(-2);
  const day = ('0' + date.getUTCDate()).slice(-2);
  return `${year}-${month}-${day}`;
}

@Builder
export function PlaylistDetailBuilder() {
  PlaylistDetail()
}

@Entry
@Component
export default struct PlaylistDetail {
  @Consume pageStack: NavPathStack
  @Consume showControlButton: boolean
  @Consume playlist: Playlist | null
  @Consume nowPlayingSong: Song | null
  @Consume nowPlayingLyrics: StructuredLyric | null
  @Consume nowPlayingLyricsByGroup: Line[][]
  @Consume nowPlayingList: Song[]
  @Consume nowPlayingListOriginal: Song[]
  @Consume nowPlayingIndex: number
  @Consume starredSongs: Song[]
  @Consume nowPlayingStar: boolean
  @Consume isPlaying: boolean
  @Consume startPlaying: boolean
  @Consume showMenu: boolean
  @Consume longPressSong: Song | null
  @Consume longPressStar: boolean
  @Consume longPressIndex: number
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume addOrDelete: boolean
  @Consume avPlayer: media.AVPlayer | null
  @Consume session: AVSessionManager.AVSession | null
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @StorageLink('playMode') playMode: number = 0
  editPlaylist: CustomDialogController = new CustomDialogController({
    builder: editPlaylistBuilder(),
    width: 340,
    height: 310,
    backgroundColor: $r('app.color.content_background')
  })

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
    let starred = await getStarred()
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

  aboutToAppear() {
    this.addOrDelete = false
  }

  aboutToDisappear() {
    this.addOrDelete = true
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Flex({ direction: FlexDirection.Row }) {
              Text(this.playlist!.name)
                .fontSize(28)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Button({ type: ButtonType.Circle }) {
                Image($r('app.media.edit'))
                  .width(20)
                  .height(20)
              }
              .width(35)
              .height(35)
              .margin({ left: 5 })
              .backgroundColor('#00000000')
              .onClick(() => {
                this.editPlaylist.open()
              })
            }
            .width('100%')
            .padding({ left: 40, right: 35 })

            Text(this.playlist!.comment)
              .fontSize(18)
              .fontColor($r('app.color.font_secondary'))
              .margin({ top: 5 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ left: 40, right: 40 })
              .visibility(this.playlist!.comment !== undefined ? Visibility.Visible : Visibility.None)
            Row() {
              Text(formatDate(this.playlist!.created))
                .fontSize(15)
                .fontColor($r('app.color.font_secondary'))
              Text("创建")
                .fontSize(15)
                .fontColor($r('app.color.font_secondary'))
            }
            .margin({ top: 5 })
            .padding({ left: 40, right: 40 })
          }
          .padding({ top: 15 })
          .width('100%')
          .height('auto')
          .alignItems(HorizontalAlign.Start)

          Row() {
            Column() {
              Text(this.playlist!.songCount.toString())
                .fontSize(20)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
              Text("歌曲")
                .fontSize(15)
                .fontColor($r('app.color.font_secondary'))
                .margin({ top: 5 })
            }

            Column() {
              Text(formatDuration(this.playlist!.duration))
                .fontSize(20)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
              Text("时长")
                .fontSize(15)
                .fontColor($r('app.color.font_secondary'))
                .margin({ top: 5 })
            }
          }
          .width('100%')
          .height('auto')
          .padding(20)
          .justifyContent(FlexAlign.SpaceAround)

          Divider()
            .width('90%')
            .height(1)
            .color($r('app.color.divider'))

          ForEach(this.playlist!.entry, (song: Song, index) => {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text((index + 1).toString())
                  .fontSize(18)
                  .fontColor($r('app.color.font_secondary'))
                  .width(80)
                  .textAlign(TextAlign.Center)
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
                .alignItems(HorizontalAlign.Start)
                .padding({ right: 15 })
                .width('100%')
                .layoutWeight(1)
              }
              .width('100%')
              .height('100%')
            }
            .width('100%')
            .height(80)
            .backgroundColor('#00000000')
            .onClick(async () => {
              await this.avPlayer!.reset()
              this.nowPlayingSong = song
              this.nowPlayingLyrics = await getLyrics(song.id)
              if (this.nowPlayingLyrics !== null) {
                this.groupLyrics()
              }
              this.nowPlayingListOriginal = this.playlist!.entry!.slice()
              if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_SHUFFLE) {
                this.nowPlayingList = this.shuffleList(this.nowPlayingListOriginal.slice())
              } else {
                this.nowPlayingList = this.nowPlayingListOriginal.slice()
              }
              this.getNowPlayingIndex(song, this.nowPlayingList)
              this.nowPlayingStar = await this.getStar(song)
              this.isPlaying = true
              this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${song.id}&format=raw`;
              this.startPlaying = true
            })
            .gesture(
              LongPressGesture()
                .onAction(async (event: GestureEvent) => {
                  this.longPressSong = song
                  this.longPressStar = await this.getStar(song)
                  this.longPressIndex = index
                  this.showMenu = true
                })
            )
          })
        }
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