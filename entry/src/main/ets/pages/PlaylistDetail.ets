import { curves } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { getLyrics, getPlaylist, getSong } from '../utils/Api';
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

@Component
export default struct PlaylistDetail {
  @Consume pageStack: NavPathStack
  @Consume showControlButton: boolean
  @Consume playlist: Playlist | undefined
  @Consume nowPlayingSong: Song | undefined
  @Consume nowPlayingLyrics: StructuredLyric | undefined
  @Consume nowPlayingLyricsByGroup: Line[][]
  @Consume nowPlayingList: Song[]
  @Consume nowPlayingListOriginal: Song[]
  @Consume nowPlayingIndex: number
  @Consume starredSongs: Song[]
  @Consume isPlaying: boolean
  @Consume startPlaying: boolean
  @Consume showMenu: boolean
  @Consume longPressSong: Song | undefined
  @Consume longPressIndex: number
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume addOrDelete: boolean
  @Consume getCoverUrl: string
  @Consume avPlayer: media.AVPlayer | undefined
  @Consume session: AVSessionManager.AVSession | undefined
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @StorageLink('playMode') playMode: number = 0
  @State coverSize: number = 128
  @State showProgress: boolean = false
  editPlaylist: CustomDialogController = new CustomDialogController({
    builder: editPlaylistBuilder(),
    width: 350,
    height: 310,
    backgroundColor: $r('app.color.start_window_background')
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

  shuffleList<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      let temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
    return array;
  }

  async aboutToAppear() {
    this.showProgress = true
    this.addOrDelete = false
    this.playlist = await getPlaylist(this.baseURL, this.username, this.password, this.playlist!.id)
    this.showProgress = false
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
              .backgroundColor(Color.Transparent)
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
            .width('100%')
            .height(1)
            .margin({ left: 20, right: 20 })
            .color($r('app.color.divider'))

          ForEach(this.playlist!.entry, (song: Song, index) => {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text((index + 1).toString())
                  .fontSize(18)
                  .fontColor($r('app.color.font_secondary'))
                  .width(70)
                  .textAlign(TextAlign.Center)
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
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 15, right: 15 })
                .width('100%')
                .layoutWeight(1)
              }
              .width('100%')
              .height('100%')
            }
            .width('100%')
            .height(80)
            .borderRadius(10)
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
              this.nowPlayingListOriginal = this.playlist!.entry!.slice()
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
                  this.longPressIndex = index
                  this.showMenu = true
                  let tmp_song: Song | undefined = await getSong(this.baseURL, this.username, this.password, this.longPressSong!.id)
                  if(tmp_song !== undefined && tmp_song.starred !== undefined){
                    this.longPressSong!.starred = tmp_song.starred
                  }
                })
            )
          })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: this.startPlaying === true ? 95 : 10 })
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