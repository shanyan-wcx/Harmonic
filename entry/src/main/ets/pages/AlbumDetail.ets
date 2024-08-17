import { curves } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { getLyrics, getStarred } from '../utils/Api';
import { Album, Song, StructuredLyric, Line } from '../utils/Interface'

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

@Builder
export function AlbumDetailBuilder() {
  AlbumDetail()
}

@Component
export default struct AlbumDetail {
  @Consume album: Album
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
  @Consume discs: Song[][]
  @Consume showMenu: boolean
  @Consume longPressSong: Song | null
  @Consume longPressStar: boolean
  @Consume avPlayer: media.AVPlayer | null
  @StorageLink('playMode') playMode: number = 0
  @Consume session: AVSessionManager.AVSession | null
  @State coverSize: number = 256

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

  aboutToAppear(): void {
    const groupedSongsMap = new Map<number, Song[]>();
    this.album.song!.forEach((song) => {
      const discNumber = song.discNumber ?? 0;
      if (!groupedSongsMap.has(discNumber)) {
        groupedSongsMap.set(discNumber, []);
      }
      groupedSongsMap.get(discNumber)?.push(song);
    });
    this.discs = Array.from(groupedSongsMap.values());
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${this.album.id}&size=${this.coverSize}`)
              .width(140)
              .aspectRatio(1)
              .borderRadius(10)
              .margin({ left: 20 })
              .shadow({
                offsetX: 0,
                offsetY: 0,
                radius: 25,
                color: '#25000000'
              })
            Column() {
              Text(this.album.title)
                .fontSize(24)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
              Text(this.album.artist)
                .fontSize(17)
                .fontColor($r('app.color.font_secondary'))
                .margin({ top: 5 })
            }
            .margin({ left: 15, right: 15 })
            .padding({ bottom: 20 })
            .width('100%')
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height('auto')
          .margin({ top: 15 })
          .justifyContent(FlexAlign.Start)

          Row() {
            Column() {
              Text(this.album.songCount.toString())
                .fontSize(20)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
              Text("歌曲")
                .fontSize(15)
                .fontColor($r('app.color.font_secondary'))
                .margin({ top: 5 })
            }

            Column() {
              Text(formatDuration(this.album.duration))
                .fontSize(20)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
              Text("时长")
                .fontSize(15)
                .fontColor($r('app.color.font_secondary'))
                .margin({ top: 5 })
            }

            Column() {
              Text(this.album.year.toString())
                .fontSize(20)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
              Text("年份")
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

          ForEach(this.discs, (disc: Song[], index) => {
            Text("DISC " + (index + 1))
              .width('100%')
              .fontSize(17)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Bold)
              .padding({ left: 20, top: 20 })
            ForEach(disc, (song: Song, index2) => {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  Text(song.track.toString())
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
              .borderRadius(10)
              .backgroundColor('#00000000')
              .onClick(async () => {
                await this.avPlayer!.reset()
                this.nowPlayingSong = song
                this.nowPlayingLyrics = await getLyrics(song.id)
                if (this.nowPlayingLyrics !== null) {
                  this.groupLyrics()
                }
                this.nowPlayingListOriginal = this.album.song!.slice()
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
                    this.showMenu = true
                  })
              )
            })
            Divider()
              .width('90%')
              .height(1)
              .color($r('app.color.divider'))
              .visibility(index === this.discs.length - 1 ? Visibility.None : Visibility.Visible)
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