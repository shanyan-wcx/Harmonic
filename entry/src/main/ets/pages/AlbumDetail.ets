import { curves } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { getAlbumSong, getArtist, getLyrics, getSong } from '../utils/Api';
import { Album, Artist, Line, Song, StructuredLyric } from '../utils/Interface';

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
  @State artists: Artist[] = []
  @Consume artist: Artist | undefined
  @Consume nowPlayingSong: Song | undefined
  @Consume nowPlayingLyrics: StructuredLyric | undefined
  @Consume nowPlayingLyricsByGroup: Line[][]
  @Consume nowPlayingList: Song[]
  @Consume nowPlayingListOriginal: Song[]
  @Consume nowPlayingIndex: number
  @Consume starredSongs: Song[]
  @Consume isPlaying: boolean
  @Consume startPlaying: boolean
  @Consume discs: Song[][]
  @Consume showMenu: boolean
  @Consume longPressSong: Song | undefined
  @Consume avPlayer: media.AVPlayer | undefined
  @StorageLink('playMode') playMode: number = 0
  @Consume session: AVSessionManager.AVSession | undefined
  @State coverSize: number = 256
  @State showDiscHeader: boolean = false
  @State discsKeys: number[] = []
  @State showProgress: boolean = false

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
    this.album.song = await getAlbumSong(this.baseURL, this.username, this.password, this.album.id);
    const groupedSongsMap = new Map<number, Song[]>();
    this.album.song!.forEach((song) => {
      let disc = song.discNumber;
      if (disc === undefined) {
        disc = 0;
      }
      if (!groupedSongsMap.has(disc)) {
        groupedSongsMap.set(disc, []);
      }
      groupedSongsMap.get(disc)?.push(song);
    });
    const sortedKeys = Array.from(groupedSongsMap.keys()).sort((a, b) => a - b);
    this.discs = sortedKeys.map(key => groupedSongsMap.get(key)!);
    this.discsKeys = sortedKeys;
    this.showDiscHeader = !(sortedKeys.length === 1 && (sortedKeys[0] === 0 || sortedKeys[0] === 1));
    this.showProgress = false
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${this.album.id}&size=${this.coverSize}`)
              .alt($rawfile('nocover.png'))
              .objectFit(ImageFit.Contain)
              .width(140)
              .aspectRatio(1)
              .borderRadius(10)
              .margin({ left: 20 })
            Column() {
              Text(this.album.name)
                .fontSize(24)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Bold)
              Button({ type: ButtonType.Normal }) {
                Text(this.album.artist)
                  .fontSize(17)
                  .fontColor($r('app.color.font_secondary'))
              }
              .margin({ top: 5 })
              .backgroundColor(Color.Transparent)
              .stateEffect(false)
              .onClick(async () => {
                this.artist = await getArtist(this.baseURL, this.username, this.password, this.album.artistId)
                this.pageStack.replacePathByName('ArtistDetail', undefined);
              })
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
              Text(this.album.year !== undefined ? this.album.year!.toString() : '-')
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

          if (this.showDiscHeader) {
            ForEach(this.discs, (disc: Song[], index) => {
              Column() {
                Text(this.discsKeys[index] === 0 ? "DISC" : "DISC " + this.discsKeys[index])
                  .width('100%')
                  .fontSize(17)
                  .fontColor($r('app.color.font'))
                  .fontWeight(FontWeight.Bold)
                  .padding({ left: 20, top: 20 })
                ForEach(disc, (song: Song, index2) => {
                  Button({ type: ButtonType.Normal }) {
                    Row() {
                      Text(song.track !== undefined ? song.track.toString() : '-')
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
                    this.nowPlayingListOriginal = this.album.song!.slice()
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
                Divider()
                  .width('90%')
                  .height(1)
                  .color($r('app.color.divider'))
                  .visibility(index === this.discs.length - 1 ? Visibility.None : Visibility.Visible)
              }
            })
          } else {
            ForEach(this.discs[0], (song: Song, index) => {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  Text(song.track !== undefined ? song.track.toString() : '-')
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
                this.nowPlayingListOriginal = this.album.song!.slice()
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
