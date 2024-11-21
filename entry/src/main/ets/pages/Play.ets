import { promptAction, window } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { createShare, getCover, getLyrics, getStarred, star, unstar } from '../utils/Api';
import { Song, StructuredLyric, Line, Artist, Album } from '../utils/Interface'
import selectPlaylistBuilder from './dialogs/SelectPlaylist';
import infoBuilder from './dialogs/Info';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

let context = getContext(this) as common.UIAbilityContext;

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

function formatSleepTime(seconds: number): string {
  if (seconds < 60) {
    const roundedSeconds = Math.floor(seconds);
    return `${roundedSeconds} sec`;
  } else if (seconds < 3600) {
    const minutes = Math.floor(seconds / 60);
    return `${minutes} min`;
  } else {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${hours} hr ${minutes} min`;
  }
}

@Component
export default struct Play {
  @State progressWidth: number = 0
  @State statusBarHeight: number = 0
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume displayWidth: number
  @Consume displayHeight: number
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
  @Consume @Watch('scrollLyrics') lyricsIndex: number
  @Consume nowPlayedTime: number
  @Consume isPlaying: boolean
  @Consume startPlaying: boolean
  @Consume showPlay: boolean
  @Consume showCover: boolean
  @Consume sleepTime: number
  @Consume avPlayer: media.AVPlayer | null
  @Consume pageStack: NavPathStack
  @Consume artists: Artist[]
  @Consume albums: Album[]
  @Consume artist: Artist | null
  @Consume album: Album | null
  @Consume playModeIcon: Resource
  @Consume session: AVSessionManager.AVSession | null
  @Consume selectedPlaylists: boolean[]
  @Consume sidebarType: number
  @Provide selectDeviceHeight: number = 300
  @State showSleep: boolean = false
  @State showList: boolean = false
  @State showMore: boolean = false
  @State sleepValue: number = 0
  @State coverSize: number = 512
  @StorageLink('playMode') @Watch('changePlayMode') playMode: number = AVSessionManager.LoopMode.LOOP_MODE_LIST
  @StorageLink('fadeVolume') fadeVolume: boolean = false
  private listScroller: Scroller = new Scroller
  private lyricsScroller: Scroller = new Scroller
  private controller: SwiperController = new SwiperController();
  selectPlaylist: CustomDialogController = new CustomDialogController({
    builder: selectPlaylistBuilder(),
    width: 340,
    height: 372,
    backgroundColor: $r('app.color.content_background'),
  })
  info: CustomDialogController = new CustomDialogController({
    builder: infoBuilder(),
    width: 340,
    height: 345,
    backgroundColor: $r('app.color.content_background'),
  })

  private getStatusBarHeight() {
    window.getLastWindow(getContext(this), (error, topWindow) => {
      if (topWindow) {
        let area = topWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.statusBarHeight = px2vp(area.topRect.height)
      }
    });
  }

  async setPlaybackState(state: number) {
    let playbackState: AVSessionManager.AVPlaybackState = {
      state: state,
      loopMode: this.playMode,
      position: {
        elapsedTime: this.nowPlayedTime * 1000,
        updateTime: new Date().getTime(),
      },
      isFavorite: this.nowPlayingStar
    };
    this.session!.setAVPlaybackState(playbackState, (err) => {
      if (err) {
        console.error(`设置Session状态失败，Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info("设置Session状态", state);
      }
    });
  }

  async changePlayMode() {
    if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_SINGLE) {
      this.playModeIcon = $r('app.media.single')
      this.nowPlayingList = this.nowPlayingListOriginal.slice()
      this.getNowPlayingIndex(this.nowPlayingSong!, this.nowPlayingList)
    } else if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_LIST) {
      this.playModeIcon = $r('app.media.loop')
      this.nowPlayingList = this.nowPlayingListOriginal.slice()
      this.getNowPlayingIndex(this.nowPlayingSong!, this.nowPlayingList)
    } else {
      this.playModeIcon = $r('app.media.shuffle')
      this.nowPlayingList = this.shuffleList(this.nowPlayingListOriginal.slice())
      this.getNowPlayingIndex(this.nowPlayingSong!, this.nowPlayingList)
    }
    if (this.isPlaying === true) {
      await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
    } else {
      await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
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

  getArtist() {
    for (let artist of this.artists) {
      if (artist.name === this.nowPlayingSong!.artist) {
        this.artist = artist
        break
      }
    }
  }

  getAlbum() {
    for (let album of this.albums) {
      if (album.name === this.nowPlayingSong!.album) {
        this.album = album
        break
      }
    }
  }

  fadeIn() {
    let duration = 1000
    let volume = 0;
    const step = 50; // 调整间隔时间，单位 ms
    const increment = step / duration; // 每次增加的音量比例
    this.avPlayer!.setVolume(volume);
    this.avPlayer!.play();
    const interval = setInterval(() => {
      volume += increment;
      if (volume >= 1.0) {
        this.avPlayer!.setVolume(1.0);
        clearInterval(interval);
      } else {
        this.avPlayer!.setVolume(volume);
      }
    }, step);
  }

  fadeOut() {
    let duration = 1000
    let volume = 1.0; // 假设当前音量是最大值
    const step = 50; // 调整间隔时间，单位 ms
    const decrement = step / duration; // 每次减少的音量比例
    const interval = setInterval(() => {
      volume -= decrement;
      if (volume <= 0.0) {
        this.avPlayer!.setVolume(0.0);
        clearInterval(interval);
        this.avPlayer!.pause(); // 在音量完全降为 0 后暂停
      } else {
        this.avPlayer!.setVolume(volume);
      }
    }, step);
  }

  scrollLyrics() {
    this.lyricsScroller.scrollToIndex(this.lyricsIndex, true, ScrollAlign.CENTER)
  }

  async aboutToAppear() {
    this.getStatusBarHeight()
  }

  @Builder
  sleepBuilder() {
    Column() {
      Column() {
        Row() {
          Text('时长')
            .fontSize(19)
            .fontColor($r('app.color.font'))
          Text(Math.floor(this.sleepValue) + " 分钟")
            .fontSize(19)
            .fontColor($r('app.color.font'))
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Slider({
          value: $$this.sleepValue,
          min: 0,
          max: 120,
          step: 1,
          style: SliderStyle.OutSet,
          direction: Axis.Horizontal,
          reverse: false
        })
          .width('100%')
          .blockColor($r('app.color.progress'))
          .selectedColor($r('app.color.progress'))
          .trackThickness(5)
      }
      .width('90%')
      .borderRadius(10)
      .margin({ bottom: 20 })
      .padding({
        top: 20,
        left: 20,
        right: 20,
        bottom: 10
      })
      .clip(true)
      .backgroundColor($r('app.color.bar_background'))

      Button({ type: ButtonType.Normal }) {
        Text("设置")
          .fontSize(20)
          .fontColor($r('app.color.font'))
      }
      .width('80%')
      .height(60)
      .borderRadius(15)
      .backgroundColor($r('app.color.bar_background'))
      .onClick(() => {
        this.sleepTime = this.sleepValue * 60
        this.showSleep = false
      })
    }
    .margin({ bottom: 25 })
  }

  @Builder
  listBuilder() {
    Column() {
      List({ scroller: this.listScroller }) {
        ForEach(this.nowPlayingList, (song: Song, index) => {
          ListItem() {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${song.id}&size=${this.coverSize}`)
                  .alt($rawfile('nocover.png'))
                  .objectFit(ImageFit.Fill)
                  .width(45)
                  .aspectRatio(1)
                  .borderRadius(5)
                Column() {
                  Text(song.title)
                    .fontSize(17)
                    .fontColor($r('app.color.font'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(song.artist + " - " + song.album)
                    .fontSize(14)
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
            .height(60)
            .borderRadius(10)
            .padding({ left: 20, right: 20 })
            .backgroundColor(index === this.nowPlayingIndex ? $r('app.color.progress_background') :
            $r('app.color.bar_background'))
            .onClick(async () => {
              this.showList = false
              await this.avPlayer!.reset()
              this.nowPlayingSong = song
              this.nowPlayingLyrics = await getLyrics(song.id)
              if (this.nowPlayingLyrics !== null) {
                this.groupLyrics()
              }
              this.nowPlayingIndex = index
              this.isPlaying = true
              this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${song.id}&format=raw`;
            })
          }
        })
      }
      .width('100%')
      .height('100%')
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
    }
    .width('90%')
    .height(this.nowPlayingList.length > 7 ? 420 : this.nowPlayingList.length * 60)
    .borderRadius(10)
    .margin({ bottom: 25 })
    .clip(true)
    .backgroundColor($r('app.color.bar_background'))
    .onAppear(() => {
      this.listScroller.scrollToIndex(this.nowPlayingIndex, false, ScrollAlign.CENTER)
    })
  }

  @Builder
  moreBuilder() {
    Column() {
      Button({ type: ButtonType.Normal }) {
        Text("歌曲信息")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMore = false
        this.info.open()
      })

      Button({ type: ButtonType.Normal }) {
        Text("添加到歌单")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMore = false
        this.selectPlaylist.open()
      })

      Button({ type: ButtonType.Normal }) {
        Text("艺术家：" + this.nowPlayingSong?.artist)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMore = false
        this.showPlay = false
        this.getArtist()
        this.pageStack.pop()
        this.pageStack.pushPathByName('ArtistDetail', null);
      })

      Button({ type: ButtonType.Normal }) {
        Text("专辑：" + this.nowPlayingSong?.album)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMore = false
        this.showPlay = false
        this.getAlbum()
        this.pageStack.pop()
        this.pageStack.pushPathByName('AlbumDetail', null);
      })

      Button({ type: ButtonType.Normal }) {
        Text("清除睡眠定时")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMore = false
        this.sleepTime = 0
      })

      Button({ type: ButtonType.Normal }) {
        Text("关闭播放器")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMore = false
        this.nowPlayingSong = null
        this.nowPlayingList = []
        this.avPlayer!.stop()
        setTimeout(() => {
          this.isPlaying = false
          this.startPlaying = false
          this.showPlay = false
          this.sleepTime = 0
        }, 10)
      })
    }
    .width('90%')
    .height('auto')
    .borderRadius(10)
    .margin({ bottom: 25 })
    .clip(true)
    .backgroundColor($r('app.color.bar_background'))
  }

  build() {
    Column() {
      Stack() {
        Column()
          .backgroundImage(this.baseURL + this.getCoverUrl + this.auth +
            `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
          .backgroundImageSize(ImageSize.FILL)
          .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
          .backgroundBrightness({
            rate: 0.5,
            lightUpDegree: context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? 0.15 : 0.5
          })
          .width('100%')
          .height('100%')
        Row() {
          Column() {
            Row() {
              Button({ type: ButtonType.Circle }) {
                Image($r('app.media.down'))
                  .width(30)
                  .height(30)
              }
              .width(40)
              .height(40)
              .backgroundColor('#00000000')
              .margin({ left: 25 })
              .onClick(() => {
                if (this.showPlay === false) {
                  this.showPlay = true
                }
                this.showPlay = false
              })

              Row() {
                Text("睡眠定时")
                  .fontSize(18)
                  .fontColor($r('app.color.font'))
                  .margin({ right: 10 })
                Text(formatSleepTime(this.sleepTime))
                  .fontSize(18)
                  .fontColor($r('app.color.font'))
              }
              .width('auto')
              .height(40)
              .padding({ left: 15, right: 15 })
              .borderRadius(10)
              .backgroundColor($r('app.color.content_background'))
              .visibility(this.sleepTime > 0 ? Visibility.Visible : Visibility.None)

              Button({ type: ButtonType.Circle }) {
                Image($r('app.media.radiowave'))
                  .width(30)
                  .height(30)
              }
              .width(40)
              .height(40)
              .margin({ right: 25 })
              .backgroundColor('#00000000')
              .onClick(async () => {
                let url = await createShare(this.nowPlayingSong!.id)
                if (url !== null) {
                  let shareData: systemShare.SharedData = new systemShare.SharedData({
                    utd: utd.UniformDataType.HYPERLINK,
                    content: url,
                    description: this.nowPlayingSong!.title + " - " + this.nowPlayingSong!.artist,
                    thumbnail: new Uint8Array(await getCover(this.nowPlayingSong!.id, 128))
                  });
                  let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
                  let context = getContext(this) as common.UIAbilityContext;
                  controller.show(context, {
                    selectionMode: systemShare.SelectionMode.SINGLE,
                    previewMode: systemShare.SharePreviewMode.DEFAULT,
                  }).then(() => {
                    console.info('分享成功。');
                  }).catch((error: BusinessError) => {
                    console.error(`分享失败，code: ${error.code}, message: ${error.message}`);
                  });
                } else {
                  promptAction.showToast({
                    message: '创建分享链接失败，请检查网络！',
                    duration: 500
                  });
                }
              })
            }
            .width("100%")
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 20 })

            Row() {
              Column() {
                Marquee({
                  start: true,
                  step: 3,
                  src: this.nowPlayingSong?.title
                })
                  .fontSize(28)
                  .fontColor($r('app.color.font'))
                  .fontWeight(FontWeight.Medium)
                Text(this.nowPlayingSong?.artist)
                  .fontSize(18)
                  .fontColor($r('app.color.font'))
                  .margin({ top: 5 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width("100%")
              .layoutWeight(1)
              .margin({ right: 20 })
              .alignItems(HorizontalAlign.Start)

              Button() {
                Image(this.nowPlayingStar === true ? $r('app.media.star') : $r('app.media.unstar'))
                  .width(30)
                  .height(30)
              }
              .width(40)
              .height(40)
              .backgroundColor('#00000000')
              .onClick(async () => {
                if (this.nowPlayingStar === true) {
                  let starStatus = await unstar(this.nowPlayingSong!.id)
                  if (starStatus === true) {
                    this.nowPlayingStar = false
                    let starred = await getStarred()
                    if (starred !== null) {
                      this.starredSongs = starred!.song!
                    }
                    if (this.isPlaying === true) {
                      await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
                    } else {
                      await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
                    }
                  }
                } else {
                  let starStatus = await star(this.nowPlayingSong!.id)
                  if (starStatus === true) {
                    this.nowPlayingStar = true
                    let starred = await getStarred()
                    if (starred !== null) {
                      this.starredSongs = starred!.song!
                    }
                    if (this.isPlaying === true) {
                      await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
                    } else {
                      await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
                    }
                  }
                }
              })
            }
            .width("80%")
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 20, bottom: 20 })

            if (this.sidebarType === SideBarContainerType.Overlay) {
              Swiper(this.controller) {
                Column() {
                  Image(this.baseURL + this.getCoverUrl + this.auth +
                    `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
                    .alt($rawfile('nocover.png'))
                    .height('100%')
                    .aspectRatio(1)
                    .borderRadius(10)
                    .objectFit(ImageFit.Fill)
                }
                .width('100%')
                .height('100%')
                .margin({ bottom: 40 })
                .onTouch((event?: TouchEvent) => {
                  if (event?.type === TouchType.Move) {
                    this.lyricsScroller.scrollToIndex(this.lyricsIndex, false, ScrollAlign.CENTER)
                  }
                })

                Column() {
                  List({ scroller: this.lyricsScroller }) {
                    if (this.nowPlayingLyrics !== null && this.nowPlayingLyricsByGroup.length > 0) {
                      ForEach(this.nowPlayingLyricsByGroup, (group: Line[], index) => {
                        ListItem() {
                          Column() {
                            ForEach(group, (line: Line, index2) => {
                              Text(line.value)
                                .width('100%')
                                .height('auto')
                                .padding({ left: 20, right: 20 })
                                .margin({ bottom: index2 === 0 ? 5 : 0 })
                                .fontSize(this.lyricsIndex === index &&
                                  this.nowPlayingLyrics?.synced === true ?
                                  28 :
                                  23)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(this.lyricsIndex === index &&
                                  this.nowPlayingLyrics?.synced === true ?
                                $r('app.color.font_lyrics') :
                                $r('app.color.font_lyrics_secondary'))
                                .textAlign(TextAlign.Center)
                                .animation({ duration: 400 })
                            })
                          }
                        }
                        .margin({
                          top: index === 0 ? 125 : 15,
                          bottom: index === this.nowPlayingLyricsByGroup.length - 1 ? 125 : 15
                        })
                      })
                    } else {
                      ListItem() {
                        Column() {
                          Text("没有歌词")
                            .fontSize(28)
                            .fontWeight(FontWeight.Bold)
                            .fontColor($r('app.color.font_lyrics'))
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                      }
                      .width('100%')
                      .height('100%')
                    }
                  }
                  .height('100%')
                  .aspectRatio(1)
                  .borderRadius(10)
                  .listDirection(Axis.Vertical)
                  .scrollBar(BarState.Off)
                }
                .width('100%')
                .height('100%')
                .margin({ bottom: 40 })
              }
              .loop(false)
              .indicator(
                Indicator.dot()
                  .selectedColor($r('app.color.indicator'))
              )
              .height('45%')
              .width('90%')
              .margin({ top: 20 })
              .visibility(this.showCover === true ? Visibility.Visible : Visibility.None)
            } else {
              Column() {
                Image(this.baseURL + this.getCoverUrl + this.auth +
                  `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
                  .alt($rawfile('nocover.png'))
                  .height('100%')
                  .aspectRatio(1)
                  .borderRadius(10)
                  .objectFit(ImageFit.Fill)
              }
              .height('45%')
              .width('90%')
              .margin({ top: 20 })
              .padding({ bottom: 40 })
              .visibility(this.showCover === true ? Visibility.Visible : Visibility.None)
            }

            Column() {
              Column() {
                Row() {
                  Text(formatDuration(this.nowPlayedTime))
                    .fontSize(16)
                    .fontColor($r('app.color.font'))
                    .fontWeight(FontWeight.Medium)
                  Text(formatDuration(this.nowPlayingSong?.duration!))
                    .fontSize(16)
                    .fontColor($r('app.color.font'))
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)

                Progress({
                  value: this.nowPlayedTime / this.nowPlayingSong?.duration! * 100,
                  total: 100,
                  type: ProgressType.Linear
                })
                  .style({ strokeWidth: 5 })
                  .width('100%')
                  .margin({ top: 10, bottom: 15 })
                  .color($r('app.color.progress'))
                  .onAreaChange((oldValue: Area, newValue: Area) => {
                    this.progressWidth = newValue.width as number;
                  })
                  .gesture(
                    GestureGroup(
                      GestureMode.Exclusive,
                      TapGesture({ fingers: 1, count: 1 })
                        .onAction((event: GestureEvent) => {
                          let touchProgress = Math.round((event.fingerList[0].localX / this.progressWidth) * 100)
                          let progress = 0
                          if (touchProgress < 0) {
                            progress = 0
                          } else if (touchProgress >= 100) {
                            progress = 99
                          } else {
                            progress = touchProgress
                          }
                          this.avPlayer!.seek(progress * this.nowPlayingSong!.duration * 10)
                        })
                    )
                  )
              }
              .width('100%')
              .visibility(this.displayHeight > 300 ? Visibility.Visible : Visibility.None)

              Row() {
                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.prev'))
                    .width(45)
                    .height(45)
                }
                .width(55)
                .height(55)
                .backgroundColor('#00000000')
                .onClick(async () => {
                  await this.avPlayer!.reset();
                  if (this.nowPlayingIndex === 0) {
                    this.nowPlayingIndex = this.nowPlayingList.length - 1
                  } else {
                    this.nowPlayingIndex -= 1
                  }
                  this.nowPlayingSong = this.nowPlayingList[this.nowPlayingIndex]
                  this.nowPlayingLyrics = await getLyrics(this.nowPlayingSong.id)
                  if (this.nowPlayingLyrics !== null) {
                    this.groupLyrics()
                  }
                  this.avPlayer!.url =
                    this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
                })

                Button({ type: ButtonType.Circle }) {
                  Image(this.isPlaying === true ? $r('app.media.play') : $r('app.media.pause'))
                    .width(47)
                    .height(47)
                }
                .width(70)
                .height(70)
                .backgroundColor('#00000000')
                .onClick(() => {
                  this.isPlaying = !this.isPlaying
                  if (this.isPlaying === false) {
                    if (this.fadeVolume === true) {
                      this.fadeOut()
                    } else {
                      this.avPlayer!.pause()
                    }
                  } else {
                    if (this.fadeVolume === true) {
                      this.fadeIn()
                    } else {
                      this.avPlayer!.play()
                    }
                  }
                })

                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.next'))
                    .width(45)
                    .height(45)
                }
                .width(55)
                .height(55)
                .backgroundColor('#00000000')
                .onClick(async () => {
                  await this.avPlayer!.reset();
                  if (this.nowPlayingIndex === this.nowPlayingList.length - 1) {
                    this.nowPlayingIndex = 0
                  } else {
                    this.nowPlayingIndex += 1
                  }
                  this.nowPlayingSong = this.nowPlayingList[this.nowPlayingIndex]
                  this.nowPlayingLyrics = await getLyrics(this.nowPlayingSong.id)
                  if (this.nowPlayingLyrics !== null) {
                    this.groupLyrics()
                  }
                  this.avPlayer!.url =
                    this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
                })
              }
              .width('80%')
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                Button({ type: ButtonType.Circle }) {
                  Image(this.playModeIcon)
                    .width(30)
                    .height(30)
                }
                .width(40)
                .height(40)
                .backgroundColor('#00000000')
                .onClick(async () => {
                  if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_SINGLE) {
                    this.playMode = AVSessionManager.LoopMode.LOOP_MODE_LIST
                  } else if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_LIST) {
                    this.playMode = AVSessionManager.LoopMode.LOOP_MODE_SHUFFLE
                  } else {
                    this.playMode = AVSessionManager.LoopMode.LOOP_MODE_SINGLE
                  }
                })

                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.sleep'))
                    .width(30)
                    .height(30)
                }
                .width(40)
                .height(40)
                .backgroundColor('#00000000')
                .onClick(() => {
                  this.showSleep = true
                })
                .bindSheet($$this.showSleep, this.sleepBuilder, {
                  showClose: false,
                  height: SheetSize.FIT_CONTENT,
                  preferType: SheetType.BOTTOM,
                  backgroundColor: $r('app.color.content_background'),
                  title: {
                    title: '睡眠定时'
                  }
                })

                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.list'))
                    .width(30)
                    .height(30)
                }
                .width(40)
                .height(40)
                .backgroundColor('#00000000')
                .onClick(() => {
                  this.showList = true
                })
                .bindSheet($$this.showList, this.listBuilder, {
                  showClose: false,
                  height: SheetSize.FIT_CONTENT,
                  preferType: SheetType.BOTTOM,
                  backgroundColor: $r('app.color.content_background'),
                  title: {
                    title: '播放队列'
                  }
                })

                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.more'))
                    .width(30)
                    .height(30)
                }
                .width(40)
                .height(40)
                .backgroundColor('#00000000')
                .onClick(() => {
                  this.showMore = true
                })
                .bindSheet($$this.showMore, this.moreBuilder, {
                  showClose: false,
                  height: SheetSize.FIT_CONTENT,
                  preferType: SheetType.BOTTOM,
                  backgroundColor: $r('app.color.content_background'),
                  title: {
                    title: '更多'
                  }
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .visibility(this.displayHeight > 300 ? Visibility.Visible : Visibility.None)
            }
            .width('80%')
            .height('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: this.showCover === true ? 20 : 40, bottom: 20 })
            .offset({
              y: -20
            })
          }
          .width('100%')
          .height('100%')
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          if (this.sidebarType === SideBarContainerType.Embed) {
            Column() {
              List({ scroller: this.lyricsScroller }) {
                if (this.nowPlayingLyrics !== null && this.nowPlayingLyricsByGroup.length > 0) {
                  ForEach(this.nowPlayingLyricsByGroup, (group: Line[], index) => {
                    ListItem() {
                      Column() {
                        ForEach(group, (line: Line, index2) => {
                          Text(line.value)
                            .width('100%')
                            .height('auto')
                            .padding({ left: 20, right: 20 })
                            .margin({ bottom: index2 === 0 ? 5 : 0 })
                            .fontSize(this.lyricsIndex === index &&
                              this.nowPlayingLyrics?.synced === true ?
                              28 :
                              23)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(this.lyricsIndex === index &&
                              this.nowPlayingLyrics?.synced === true ?
                            $r('app.color.font_lyrics') :
                            $r('app.color.font_lyrics_secondary'))
                            .textAlign(TextAlign.Center)
                            .animation({ duration: 400 })
                        })
                      }
                    }
                    .margin({
                      top: index === 0 ? '50%' : 15,
                      bottom: index === this.nowPlayingLyricsByGroup.length - 1 ? '50%' : 15
                    })
                  })
                } else {
                  ListItem() {
                    Column() {
                      Text("没有歌词")
                        .fontSize(28)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('app.color.font_lyrics'))
                    }
                    .width('100%')
                    .height('100%')
                    .justifyContent(FlexAlign.Center)
                  }
                  .width('100%')
                  .height('100%')
                }
              }
              .width('100%')
              .height('100%')
              .borderRadius(10)
              .listDirection(Axis.Vertical)
              .scrollBar(BarState.Off)
            }
            .width('50%')
            .height('65%')
            .margin({ bottom: 20 })
          }
        }
        .width('100%')
        .height('100%')
        .padding({ top: this.statusBarHeight })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }
}