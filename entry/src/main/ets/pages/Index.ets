import { curves, promptAction, window } from '@kit.ArkUI';
import { common, ConfigurationConstant, Configuration, EnvironmentCallback } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import CryptoJS from '@ohos/crypto-js';
import { getAlbum, getArtist, getArtistInfo, getIndexes, getLyrics, getPlaylists, ping } from '../utils/Api'
import { Album, Artist, Playlist, Song, StructuredLyric, Line } from '../utils/Interface';
import Albums from './Albums';
import Artists from './Artists';
import Play from './Play';
import Playlists from './Playlists';
import Songs from './Songs';
import Setting from './Setting';
import About from './About';
import Stats from './Stats';

let context = getContext(this) as common.UIAbilityContext;
let applicationContext = context.getApplicationContext();

@Entry
@Component
struct Index {
  @Provide mainWindow: window.Window | null = null
  @State title: string = '歌曲';
  @Provide pageStack: NavPathStack = new NavPathStack()
  @State statusBarHeight: number = 0;
  @State shadowRadius: number = 0;
  @Provide showSidebar: boolean = false;
  @Provide showControlButton: boolean = true;
  @Provide artists: Artist[] = []
  @Provide albums: Album[] = []
  @Provide songs: Song[] = []
  @Provide playlists: Playlist[] = []
  @Provide showProgress: boolean = false
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Provide salt: string = 'abcdef'
  @Provide version: string = '1.16.1'
  @Provide client: string = 'Harmonic'
  @Provide auth: string = `?u=${this.username}&t=${CryptoJS.MD5(this.password +
  this.salt)}&s=${this.salt}&v=${this.version}&c=${this.client}&f=json`
  @Provide getCoverUrl: string = '/getCoverArt'
  @Provide coverSize: number = 1024
  @Provide nowPage: number = 0
  @Provide serverStatus: boolean = true
  @Provide nowPlayingSong: Song | null = null
  @Provide nowPlayingLyrics: StructuredLyric | null = null
  @Provide nowPlayingLyricsByGroup: Line[][] = []
  @Provide nowPlayingList: Song[] = []
  @Provide nowPlayingListOriginal: Song[] = []
  @Provide nowPlayingIndex: number = 0
  @Provide lyricsIndex: number = 0
  @Provide startPlaying: boolean = false
  @Provide isPlaying: boolean = false
  @Provide nowPlayedTime: number = 0
  @Provide showPlay: boolean = false
  @Provide showDevice: boolean = false
  @Provide showCover: boolean = true
  @Provide sleepTime: number = 0
  @Provide album: Album | null = null
  @Provide artist: Artist | null = null
  @Provide playlist: Playlist | null = null
  @Provide discs: Song[][] = []
  @Provide avPlayer: media.AVPlayer | null = null
  @State controlButtonWidth: number = 24
  @StorageLink('theme') @Watch('changeStatusBar') theme: number = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  @StorageLink('playMode') playMode: number = 0
  @State themeIcon: Resource = $r('app.media.auto')
  @State sidebarIcon: Resource = $r('app.media.sidebar')
  environmentCallback: EnvironmentCallback = {
    async onConfigurationUpdated(newConfig: Configuration) {
      let systemTheme: number | undefined = newConfig.colorMode
      let mainWindow = await window.getLastWindow(getContext(this))
      if (systemTheme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#FFFFFF',
        })
        this.showControlButton = false
        this.sidebarIcon = $rawfile('sidebar_dark.png')
        this.showControlButton = true
      } else {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#000000',
        })
        this.showControlButton = false
        this.sidebarIcon = $rawfile('sidebar.png')
        this.showControlButton = true
      }
    },
    onMemoryLevel(level) {
    }
  }

  private getStatusBarHeight() {
    window.getLastWindow(getContext(this), (error, topWindow) => {
      if (topWindow) {
        let area = topWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.statusBarHeight = px2vp(area.topRect.height)
      }
    });
  }

  async changeStatusBar() {
    let mainWindow = await window.getLastWindow(getContext(this))
    if (this.theme === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      mainWindow.setWindowSystemBarProperties({
        statusBarContentColor: '#000000',
      })
      this.themeIcon = $r('app.media.light')
      this.sidebarIcon = $rawfile('sidebar.png')
    } else if (this.theme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      mainWindow.setWindowSystemBarProperties({
        statusBarContentColor: '#FFFFFF',
      })
      this.themeIcon = $r('app.media.dark')
      this.sidebarIcon = $rawfile('sidebar_dark.png')
    } else {
      this.themeIcon = $r('app.media.auto')
      let systemTheme: number | undefined = context.config.colorMode
      if (systemTheme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#FFFFFF',
        })
        this.sidebarIcon = $rawfile('sidebar_dark.png')
      } else {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#000000',
        })
        this.sidebarIcon = $rawfile('sidebar.png')
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

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('durationUpdate', (duration: number) => {
    })
    avPlayer.on('timeUpdate', async (time: number) => {
      this.nowPlayedTime = time / 1000
      if (this.sleepTime > 0 && this.isPlaying === true) {
        this.sleepTime -= 0.1
        if (this.sleepTime <= 0) {
          this.avPlayer!.pause()
          this.isPlaying = false
          this.sleepTime = 0
        }
      }
      if (this.nowPlayingLyrics !== null && this.nowPlayingLyrics.synced === true) {
        for (let index = 1; index <= this.nowPlayingLyricsByGroup.length; index++) {
          if (index === this.nowPlayingLyricsByGroup.length || this.nowPlayingLyricsByGroup[index][0].start! > time) {
            this.lyricsIndex = index - 1
            break
          }
        }
      }
    })
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      console.info(`播放器跳转成功，当前时间为 ${seekDoneTime}`);
    })
    avPlayer.on('speedDone', (speed: number) => {
      console.info(`播放器设置速度成功，当前速度为 ${speed}`);
    })
    avPlayer.on('error', (err: BusinessError) => {
      console.error(`播放器出现错误，code is ${err.code}, message is ${err.message}`);
      avPlayer.reset();
    })
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          console.info('播放器重置。');
          break;
        case 'initialized':
          console.info('播放器初始化。');
          this.lyricsIndex = 0
          avPlayer.prepare();
          break;
        case 'prepared':
          console.info('播放器就绪。');
          if (this.isPlaying === true) {
            this.avPlayer!.play()
          } else {
            this.avPlayer!.pause()
          }
          break;
        case 'playing':
          console.info('播放器开始播放。');
          break;
        case 'paused':
          console.info('播放器暂停。');
          break;
        case 'completed':
          console.info('播放完毕。');
          if (this.playMode === 1) {
            await avPlayer.reset();
            this.avPlayer!.url = this.baseURL + '/stream' + this.auth + `&id=${this.nowPlayingSong!.id}&format=raw`;
          } else {
            await avPlayer.reset();
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
            this.avPlayer!.url = this.baseURL + '/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
          }
          break;
        case 'stopped':
          console.info('播放器停止。');
          this.sleepTime = 0
          await avPlayer.reset();
          break;
        case 'released':
          console.info('播放器释放。');
          break;
        default:
          console.info('播放器状态未知。');
          break;
      }
    })
    avPlayer.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            this.isPlaying = false
            this.avPlayer!.pause()
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            this.isPlaying = false
            this.avPlayer!.pause()
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            this.isPlaying = true
            this.avPlayer!.play()
            break;
          default:
            break;
        }
      }
    })
  }

  @Builder
  menuBuilder() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Image($r('app.media.refresh'))
          .width(24)
          .aspectRatio(1)
      }
      .width(48)
      .aspectRatio(1)
      .borderRadius(8)
      .backgroundColor('#00000000')
      .onClick(async () => {
        animateTo({
          duration: 300,
          curve: Curve.EaseOut,
        }, () => {
          this.showSidebar = false
        })
        this.serverStatus = true
        this.showProgress = true
        let status: string | null = await ping()
        console.log("Server status", status)
        if (status === 'ok') {
          this.artists = []
          this.albums = []
          this.songs = []
          this.playlists = []
          this.artists = await getIndexes()
          this.artists.sort((a, b) => a.name.localeCompare(b.name, 'zh'))
          for (const artist of this.artists) {
            artist.biography = await getArtistInfo(artist.id)
            artist.album = await getArtist(artist.id);
            this.albums = this.albums.concat(artist.album!);
            this.albums.sort((a, b) => a.title.localeCompare(b.title, 'zh'))
            for (const album of artist.album!) {
              album.song = await getAlbum(album.id);
              this.songs = this.songs.concat(album.song!);
              this.songs.sort((a, b) => a.title.localeCompare(b.title, 'zh'))
            }
          }
          this.playlists = (await getPlaylists()).sort((a, b) => {
            return Date.parse(b.changed) - Date.parse(a.changed);
          })
          console.log("获取到艺术家", this.artists.length)
          console.log("获取到专辑", this.albums.length)
          console.log("获取到歌曲", this.songs.length)
          console.log("获取到歌单", this.playlists.length)
        } else {
          this.serverStatus = false
          promptAction.showToast({
            message: '连接服务器失败，请检查网络！',
            duration: 500
          });
        }
        this.showProgress = false
      })

      Button({ type: ButtonType.Normal }) {
        Image(this.themeIcon)
          .width(24)
          .aspectRatio(1)
      }
      .width(48)
      .aspectRatio(1)
      .borderRadius(8)
      .backgroundColor('#00000000')
      .onClick(() => {
        animateTo({
          duration: 300,
          curve: Curve.EaseOut,
        }, () => {
          this.showSidebar = false
        })
        if (this.theme === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
          this.theme = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
          this.themeIcon = $r('app.media.light')
        } else if (this.theme === 1) {
          this.theme = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
          this.themeIcon = $r('app.media.dark')
        } else {
          this.theme = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
          this.themeIcon = $r('app.media.auto')
        }
        context.getApplicationContext().setColorMode(this.theme)
      })
    }
    .height('100%')
    .padding({ right: 10 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  bindContentCoverBuilder() {
    Column() {
      Play()
    }
    .transition(TransitionEffect.translate({ y: 1000 }).animation({ curve: curves.springMotion(0.6, 1) }))
  }

  @Builder
  titlebar() {
    Row() {
      Text(this.title)
        .fontSize(23)
        .fontColor($r('app.color.font'))
        .fontWeight(FontWeight.Medium)
    }
    .width("100%")
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 72, top: 1 })
  }

  async aboutToAppear() {
    context.getApplicationContext().setColorMode(this.theme)
    this.mainWindow = await window.getLastWindow(getContext(this))
    this.changeStatusBar()
    applicationContext.on('environment', this.environmentCallback);
    this.getStatusBarHeight()
    this.registerInterception()
    if (this.baseURL === '') {
      this.serverStatus = false
    } else {
      this.showProgress = true
      let status: string | null = await ping()
      console.log("Server status", status)
      if (status === 'ok') {
        this.artists = await getIndexes()
        this.artists.sort((a, b) => a.name.localeCompare(b.name, 'zh'))
        for (const artist of this.artists) {
          artist.biography = await getArtistInfo(artist.id)
          artist.album = await getArtist(artist.id);
          this.albums = this.albums.concat(artist.album!);
          this.albums.sort((a, b) => a.title.localeCompare(b.title, 'zh'))
          for (const album of artist.album!) {
            album.song = await getAlbum(album.id);
            this.songs = this.songs.concat(album.song!);
            this.songs.sort((a, b) => a.title.localeCompare(b.title, 'zh'))
          }
        }
        this.playlists = (await getPlaylists()).sort((a, b) => {
          return Date.parse(b.changed) - Date.parse(a.changed);
        })
        console.log("获取到艺术家", this.artists.length)
        console.log("获取到专辑", this.albums.length)
        console.log("获取到歌曲", this.songs.length)
        console.log("获取到歌单", this.playlists.length)
      } else {
        this.serverStatus = false
        promptAction.showToast({
          message: '连接服务器失败，请检查网络！',
          duration: 500
        });
      }
      this.showProgress = false
    }
    this.avPlayer = await media.createAVPlayer();
    this.setAVPlayerCallback(this.avPlayer!);
  }

  registerInterception() {
    this.pageStack.setInterception({
      willShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar",
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === "string") {
          this.showControlButton = true
          animateTo({
            duration: 300,
            curve: Curve.EaseOut,
          }, () => {
            this.controlButtonWidth = 24
          })
          return;
        } else {
          animateTo({
            duration: 300,
            curve: Curve.EaseOut,
          }, () => {
            this.controlButtonWidth = 0
          })
          this.showControlButton = false
          return;
        }
      }
    })
  }

  build() {
    SideBarContainer(SideBarContainerType.Overlay) {
      Column() {
        Column() {
          Button({ type: ButtonType.Normal }) {
            Row() {
              Image("")
              Text("歌曲")
                .fontSize(20)
                .fontColor($r('app.color.font'))
            }
          }
          .width('100%')
          .height(60)
          .backgroundColor($r('app.color.bar_background'))
          .onClick(() => {
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.showSidebar = false
            })
            this.nowPage = 0
            this.title = '歌曲'
          })

          Button({ type: ButtonType.Normal }) {
            Row() {
              Image("")
              Text("专辑")
                .fontSize(20)
                .fontColor($r('app.color.font'))
            }
          }
          .width('100%')
          .height(60)
          .backgroundColor($r('app.color.bar_background'))
          .onClick(() => {
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.showSidebar = false
            })
            this.nowPage = 1
            this.title = '专辑'
          })

          Button({ type: ButtonType.Normal }) {
            Row() {
              Image("")
              Text("艺术家")
                .fontSize(20)
                .fontColor($r('app.color.font'))
            }
          }
          .width('100%')
          .height(60)
          .backgroundColor($r('app.color.bar_background'))
          .onClick(() => {
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.showSidebar = false
            })
            this.nowPage = 2
            this.title = '艺术家'
          })
        }
        .width('90%')
        .height('auto')
        .borderRadius(20)
        .clip(true)
        .backgroundColor($r('app.color.bar_background'))

        Column() {
          Playlists()
        }
        .width('90%')
        .height('100%')
        .layoutWeight(1)
        .margin({ top: 20, bottom: 20 })
        .borderRadius(20)
        .clip(true)
        .backgroundColor($r('app.color.bar_background'))

        Column() {
          Button({ type: ButtonType.Normal }) {
            Row() {
              Image("")
              Text("统计")
                .fontSize(20)
                .fontColor($r('app.color.font'))
            }
          }
          .width('100%')
          .height(60)
          .backgroundColor($r('app.color.bar_background'))
          .onClick(() => {
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.showSidebar = false
            })
            this.nowPage = 3
            this.title = '统计'
          })

          Button({ type: ButtonType.Normal }) {
            Row() {
              Image("")
              Text("设置")
                .fontSize(20)
                .fontColor($r('app.color.font'))
            }
          }
          .width('100%')
          .height(60)
          .backgroundColor($r('app.color.bar_background'))
          .onClick(() => {
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.showSidebar = false
            })
            this.nowPage = 4
            this.title = '设置'
          })

          Button({ type: ButtonType.Normal }) {
            Row() {
              Image("")
              Text("关于")
                .fontSize(20)
                .fontColor($r('app.color.font'))
            }
          }
          .width('100%')
          .height(60)
          .backgroundColor($r('app.color.bar_background'))
          .onClick(() => {
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.showSidebar = false
            })
            this.nowPage = 5
            this.title = '关于'
          })
        }
        .width('90%')
        .height('auto')
        .borderRadius(20)
        .clip(true)
        .backgroundColor($r('app.color.bar_background'))
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.content_background'))
      .padding({ top: this.statusBarHeight + 57, bottom: 27 })
      .shadow({
        radius: this.shadowRadius,
        color: '#95000000',
        offsetX: 0,
        offsetY: 0
      })

      Stack() {
        Navigation(this.pageStack) {
          Stack() {
            Column() {
              Column() {
                Songs()
              }
              .height('100%')
              .width('100%')
              .visibility(this.nowPage === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)

              Column() {
                Albums()
              }
              .height('100%')
              .width('100%')
              .visibility(this.nowPage === 1 && this.showProgress === false ? Visibility.Visible : Visibility.None)

              Column() {
                Artists()
              }
              .height('100%')
              .width('100%')
              .visibility(this.nowPage === 2 && this.showProgress === false ? Visibility.Visible : Visibility.None)
            }
            .height('100%')
            .width('100%')
            .visibility(this.serverStatus === true ? Visibility.Visible : Visibility.None)

            Column() {
              Stats()
            }
            .height('100%')
            .width('100%')
            .visibility(this.nowPage === 3 ? Visibility.Visible : Visibility.None)

            Column() {
              Setting()
            }
            .height('100%')
            .width('100%')
            .visibility(this.nowPage === 4 ? Visibility.Visible : Visibility.None)

            Column() {
              About()
            }
            .height('100%')
            .width('100%')
            .visibility(this.nowPage === 5 ? Visibility.Visible : Visibility.None)

            Column() {
              LoadingProgress()
                .width("100%")
                .height(80)
                .color($r('app.color.font'))
            }
            .height('100%')
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .visibility(this.showProgress === true && this.nowPage <= 2 ? Visibility.Visible : Visibility.None)

            Column() {
              Text("连接服务器失败")
                .fontSize(24)
                .fontColor($r('app.color.font'))
              Button() {
                Text("重试")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
              .width(100)
              .height(50)
              .margin({ top: 20 })
              .backgroundColor($r('app.color.bar_background'))
              .onClick(async () => {
                if (this.baseURL === '') {
                  promptAction.showToast({
                    message: '请先设置服务器！',
                    duration: 500
                  });
                } else {
                  this.serverStatus = true
                  this.showProgress = true
                  let status: string | null = await ping()
                  console.log("Server status", status)
                  if (status === 'ok') {
                    this.artists = []
                    this.albums = []
                    this.songs = []
                    this.playlists = []
                    this.artists = await getIndexes()
                    this.artists.sort((a, b) => a.name.localeCompare(b.name, 'zh'))
                    for (const artist of this.artists) {
                      artist.album = await getArtist(artist.id);
                      this.albums = this.albums.concat(artist.album!);
                      this.albums.sort((a, b) => a.title.localeCompare(b.title, 'zh'))
                      for (const album of artist.album!) {
                        album.song = await getAlbum(album.id);
                        this.songs = this.songs.concat(album.song!);
                        this.songs.sort((a, b) => a.title.localeCompare(b.title, 'zh'))
                      }
                    }
                    console.log("获取到艺术家", this.artists.length)
                    console.log("获取到专辑", this.albums.length)
                    console.log("获取到歌曲", this.songs.length)
                  } else {
                    this.serverStatus = false
                    promptAction.showToast({
                      message: '连接服务器失败，请检查网络或设置！',
                      duration: 500
                    });
                  }
                  this.showProgress = false
                }
              })
            }
            .height('100%')
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .visibility(this.serverStatus === false && this.nowPage <= 2 ? Visibility.Visible : Visibility.None)
          }
        }
        .mode(NavigationMode.Stack)
        .title(this.titlebar())
        .titleMode(NavigationTitleMode.Mini)
        .hideBackButton(true)
        .padding({ top: this.statusBarHeight })
        .menus(this.menuBuilder())
        .onClick(() => {
          animateTo({
            duration: 300,
            curve: Curve.EaseOut,
          }, () => {
            this.showSidebar = false
          })
        })

        Row() {
          Row() {
            Image(this.baseURL + this.getCoverUrl + this.auth +
              `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
              .alt($rawfile('nocover.png'))
              .objectFit(ImageFit.Fill)
              .width(60)
              .aspectRatio(1)
              .borderRadius(5)
            Column() {
              Marquee({
                start: true,
                step: 3,
                src: this.nowPlayingSong?.title
              })
                .fontSize(18)
                .fontColor($r('app.color.font'))
              Marquee({
                start: true,
                step: 3,
                src: this.nowPlayingSong?.artist + " - " + this.nowPlayingSong?.album
              })
                .fontSize(15)
                .fontColor($r('app.color.font_secondary'))
                .margin({ top: 5 })
            }
            .margin({ left: 10, right: 10 })
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .layoutWeight(1)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)

          Row() {
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.prev'))
                .width(30)
                .height(30)
            }
            .width(35)
            .height(35)
            .backgroundColor('#00000000')
            .onClick(async () => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
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
              this.avPlayer!.url = this.baseURL + '/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
            })

            Stack() {
              Progress({
                value: this.nowPlayedTime / this.nowPlayingSong?.duration! * 100,
                total: 100,
                type: ProgressType.Ring
              })
                .width(45)
                .height(45)
                .color($r('app.color.progress'))
                .backgroundColor($r('app.color.progress_background'))
                .style({
                  strokeWidth: 3
                })

              Button({ type: ButtonType.Circle }) {
                Image(this.isPlaying === true ? $r('app.media.play') : $r('app.media.pause'))
                  .width(25)
                  .height(25)
              }
              .width(45)
              .height(45)
              .backgroundColor('#00000000')
              .onClick(() => {
                this.isPlaying = !this.isPlaying
                if (this.isPlaying === false) {
                  this.avPlayer!.pause()
                } else {
                  this.avPlayer!.play()
                }
                animateTo({
                  duration: 300,
                  curve: Curve.EaseOut,
                }, () => {
                  this.showSidebar = false
                })
              })
            }

            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.next'))
                .width(30)
                .height(30)
            }
            .width(35)
            .height(35)
            .backgroundColor('#00000000')
            .onClick(async () => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
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
              this.avPlayer!.url = this.baseURL + '/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
            })
          }
          .width(125)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .height(85)
        .backgroundColor($r('app.color.bar_background'))
        .padding({ left: 15, right: 15, bottom: 5 })
        .position({
          bottom: 0
        })
        .bindContentCover($$this.showPlay, this.bindContentCoverBuilder(), {
          modalTransition: ModalTransition.NONE,
        })
        .onClick(() => {
          if (this.showPlay === true) {
            this.showPlay = false
          }
          this.showPlay = true
        })
        .visibility(this.startPlaying === true ? Visibility.Visible : Visibility.Hidden)
        .transition(TransitionEffect.translate({ y: 100 }).animation({ curve: curves.springMotion(0.6, 1) }))
      }
      .width("100%")
      .height('100%')
      .onTouch(() => {
        animateTo({
          duration: 300,
          curve: Curve.EaseOut,
        }, () => {
          this.showSidebar = false
        })
      })
    }
    .width("100%")
    .height('100%')
    .backgroundColor($r('app.color.content_background'))
    .showSideBar(this.showSidebar)
    .showControlButton(this.showControlButton)
    .controlButton({
      top: 16 + this.statusBarHeight,
      left: 24,
      width: this.controlButtonWidth,
      height: 24,
      icons: {
        shown: this.sidebarIcon,
        hidden: this.sidebarIcon,
        switching: this.sidebarIcon
      }
    })
    .sideBarPosition(SideBarPosition.Start)
    .onChange((show: boolean) => {
      if (show === true) {
        this.shadowRadius = 100
        this.showSidebar = true
      } else {
        setTimeout(() => {
          this.shadowRadius = 0
          this.showSidebar = false
        }, 300)
      }
    })
  }
}