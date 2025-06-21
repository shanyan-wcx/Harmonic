import { curves, promptAction, window } from '@kit.ArkUI';
import {
  common,
  Configuration,
  ConfigurationConstant,
  EnvironmentCallback,
  wantAgent,
  WantAgent
} from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { image } from '@kit.ImageKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { picker } from '@kit.CoreFileKit';
import CryptoJS from '@ohos/crypto-js';
import {
  getCover,
  getLyrics,
  getPlaylist,
  getPlaylists,
  getSong,
  star,
  unstar,
  updatePlaylist
} from '../utils/Api';
import { Album, Artist, Line, Playlist, Song, StructuredLyric } from '../utils/Interface';
import Albums from './Albums';
import Artists from './Artists';
import Play from './Play';
import Playlists from './Playlists';
import Setting from './Setting';
import About from './About';
import selectPlaylistBuilder from './dialogs/SelectPlaylist';
import infoBuilder from './dialogs/Info';
import Search_ from './Search';
import Home from './Home';

let context = getContext(this) as common.UIAbilityContext;
let applicationContext = context.getApplicationContext();
let deviceTypeInfo: string = deviceInfo.deviceType;

@Entry
@Component
struct Index {
  @Provide mainWindow: window.Window | undefined = undefined
  @State title: string = '首页';
  @Provide pageStack: NavPathStack = new NavPathStack()
  @State statusBarHeight: number = 0;
  @State shadowRadius: number = 0;
  @Provide showSidebar: boolean = false;
  @Provide showControlButton: boolean = true;
  @Provide artists: Artist[] = []
  @Provide albums: Album[] = []
  @Provide songs: Song[] = []
  @Provide playlists: Playlist[] = []
  @Provide selectedPlaylists: boolean[] = []
  @Provide showProgress: boolean = false
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Provide salt: string = 'abcdef'
  @Provide version: string = '1.16.1'
  @Provide client: string = 'Harmonic'
  @Provide auth: string = `?u=${this.username}&t=${CryptoJS.MD5(this.password +
  this.salt)}&s=${this.salt}&v=${this.version}&c=${this.client}&f=json`
  @Provide getCoverUrl: string = '/rest/getCoverArt'
  @Provide nowPage: number = 0
  @Provide serverStatus: boolean = true
  @Provide nowPlayingSong: Song | undefined = undefined
  @Provide nowPlayingLyrics: StructuredLyric | undefined = undefined
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
  @Provide showMenu: boolean = false
  @Provide longPressSong: Song | undefined = undefined
  @Provide longPressIndex: number = -1
  @Provide sleepTime: number = 0
  @Provide selectedIndex: number = 0
  @Provide album: Album | undefined = undefined
  @Provide artist: Artist | undefined = undefined
  @Provide playlist: Playlist | undefined = undefined
  @Provide discs: Song[][] = []
  @Provide starredSongs: Song[] = []
  @Provide addOrDelete: boolean = true
  @Provide playModeIcon: Resource = $r('app.media.loop')
  @Provide avPlayer: media.AVPlayer | undefined = undefined
  @Provide session: AVSessionManager.AVSession | undefined = undefined
  @Provide displayWidth: number = 0
  @Provide displayHeight: number = 0
  @Provide sidebarType: number = SideBarContainerType.Overlay
  @State coverSize: number = 64
  @State controlButtonWidth: number = 48
  @State themeIcon: Resource = $r('app.media.auto')
  @State sidebarIcon: Resource = $r('app.media.sidebar')
  @State sideBarWidth: number = 240
  @StorageLink('theme') @Watch('changeStatusBar') theme: number = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  @StorageLink('playMode') playMode: number = AVSessionManager.LoopMode.LOOP_MODE_LIST
  @StorageLink('audioNormalizatio') audioNormalization: boolean = false
  @StorageLink('fadeVolume') fadeVolume: boolean = false
  @StorageLink('firstStart') firstStart: boolean = true
  @StorageLink('downloadDir') downloadDir: string = ''
  selectPlaylist: CustomDialogController = new CustomDialogController({
    builder: selectPlaylistBuilder(),
    width: 340,
    height: 372,
    backgroundColor: $r('app.color.content_background')
  })
  info: CustomDialogController = new CustomDialogController({
    builder: infoBuilder(),
    width: 340,
    height: 345,
    backgroundColor: $r('app.color.content_background'),
  })
  environmentCallback: EnvironmentCallback = {
    async onConfigurationUpdated(newConfig: Configuration) {
      let systemTheme: number | undefined = newConfig.colorMode
      let mainWindow = await window.getLastWindow(getContext(this))
      if (systemTheme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#FFFFFF',
        })
      } else {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#000000',
        })
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
    } else if (this.theme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      mainWindow.setWindowSystemBarProperties({
        statusBarContentColor: '#FFFFFF',
      })
      this.themeIcon = $r('app.media.dark')
    } else {
      this.themeIcon = $r('app.media.auto')
      let systemTheme: number | undefined = context.config.colorMode
      if (systemTheme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#FFFFFF',
        })
      } else {
        mainWindow.setWindowSystemBarProperties({
          statusBarContentColor: '#000000',
        })
      }
    }
  }

  createDir() {
    const documentViewPicker = new picker.DocumentViewPicker(context);
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
    documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      this.downloadDir = documentSaveResult[0];
      console.info('下载目录创建成功：' + this.downloadDir);
    }).catch((err: BusinessError) => {
      console.error(`下载目录创建失败, code is ${err.code}, message is ${err.message}`);
    })
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

  convertToLrc(lyrics: StructuredLyric | undefined): string {
    if (!lyrics || !lyrics.line || lyrics.line.length === 0) {
      return "";
    }
    const lrcLines: string[] = [];
    const addedTimestamps = new Set<string>();
    lyrics.line.forEach(line => {
      if (line.start !== undefined) {
        const minutes = Math.floor(line.start / 60000).toString().padStart(2, '0');
        const seconds = ((line.start % 60000) / 1000).toFixed(2);
        let timeTag = `[${minutes}:${seconds.padStart(5, '0')}]`;
        if (timeTag === '[00:00.00]') {
          timeTag = '[00:00.01]';
        }
        if (!addedTimestamps.has(timeTag)) {
          lrcLines.push(`${timeTag}${line.value}`);
          addedTimestamps.add(timeTag);
        }
      }
    });
    return lrcLines.join("\n") + "\n";
  }

  getPixelMap(cover: ArrayBuffer): PixelMap {
    const imageSource: image.ImageSource = image.createImageSource(cover);
    let pixelMap = imageSource.createPixelMapSync()
    return pixelMap
  }

  claerSongs(array: Song[]): Song[] {
    const uniqueItems = new Map<string, Song>();
    array.forEach(item => uniqueItems.set(item.id, item));
    return Array.from(uniqueItems.values());
  }

  clearAlbums(array: Album[]): Album[] {
    const uniqueItems = new Map<string, Album>();
    array.forEach(item => uniqueItems.set(item.id, item));
    return Array.from(uniqueItems.values());
  }

  clearArtists(array: Artist[]): Artist[] {
    const uniqueItems = new Map<string, Artist>();
    array.forEach(item => uniqueItems.set(item.id, item));
    return Array.from(uniqueItems.values());
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

  async startContinuousTask() {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.shanyan.harmonic",
          abilityName: "com.shanyan.harmonic.EntryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
        console.info(`启动长时任务。`);
      }).catch((err: BusinessError) => {
        console.error(`启动长时任务出错，代码 ${err.code}，错误信息 ${err.message}`);
      });
    });
  }

  async stopContinuousTask() {
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      console.info(`停止长时任务。`);
    }).catch((err: BusinessError) => {
      console.error(`停止长时任务出错，代码 ${err.code}，错误信息 ${err.message}`);
    });
  }

  async setSessionInfo() {
    let metadata: AVSessionManager.AVMetadata = {
      assetId: '0',
      title: this.nowPlayingSong!.title,
      mediaImage: this.getPixelMap(await getCover(this.baseURL, this.username, this.password, this.nowPlayingSong!.id,
        512)),
      duration: this.nowPlayingSong!.duration * 1000,
      artist: this.nowPlayingSong!.artist,
      lyric: this.convertToLrc(this.nowPlayingLyrics),
    };
    this.session!.setAVMetadata(metadata).then(() => {
      console.info(`SetAVMetadata successfully`);
    }).catch((err: BusinessError) => {
      console.error(`Failed to set AVMetadata. Code: ${err.code}, message: ${err.message}`);
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
      isFavorite: this.nowPlayingSong?.starred !== undefined ? true : false
    };
    this.session!.setAVPlaybackState(playbackState, (err) => {
      if (err) {
        console.error(`设置Session状态失败，Code: ${err.code}, message: ${err.message}`);
      } else {
        console.info("设置Session状态", state);
      }
    });
  }

  async setSessionCallback() {
    this.session!.on('play', () => {
      this.isPlaying = true
      if (this.fadeVolume === true) {
        this.fadeIn()
      } else {
        this.avPlayer!.play()
      }
    });
    this.session!.on('pause', () => {
      this.isPlaying = false
      if (this.fadeVolume === true) {
        this.fadeOut()
      } else {
        this.avPlayer!.pause()
      }
    });
    this.session!.on('stop', async () => {
      this.startPlaying = false
      this.isPlaying = false
      this.showPlay = false
      this.avPlayer!.stop()
    });
    this.session!.on('playPrevious', async () => {
      await this.avPlayer!.reset();
      if (this.nowPlayingIndex === 0) {
        this.nowPlayingIndex = this.nowPlayingList.length - 1
      } else {
        this.nowPlayingIndex -= 1
      }
      this.nowPlayingSong = this.nowPlayingList[this.nowPlayingIndex]
      this.nowPlayingLyrics = await getLyrics(this.baseURL, this.username, this.password, this.nowPlayingSong.id)
      if (this.nowPlayingLyrics !== undefined) {
        this.groupLyrics()
      }
      this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
    });
    this.session!.on('playNext', async () => {
      await this.avPlayer!.reset();
      if (this.nowPlayingIndex === this.nowPlayingList.length - 1) {
        this.nowPlayingIndex = 0
      } else {
        this.nowPlayingIndex += 1
      }
      this.nowPlayingSong = this.nowPlayingList[this.nowPlayingIndex]
      this.nowPlayingLyrics = await getLyrics(this.baseURL, this.username, this.password, this.nowPlayingSong.id)
      if (this.nowPlayingLyrics !== undefined) {
        this.groupLyrics()
      }
      this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
    });
    this.session!.on('seek', (time: number) => {
      this.avPlayer!.seek(time)
    });
    this.session!.on('setLoopMode', async (mode: AVSessionManager.LoopMode) => {
      if (mode === AVSessionManager.LoopMode.LOOP_MODE_SINGLE) {
        this.playMode = AVSessionManager.LoopMode.LOOP_MODE_LIST
      } else if (mode === AVSessionManager.LoopMode.LOOP_MODE_LIST) {
        this.playMode = AVSessionManager.LoopMode.LOOP_MODE_SHUFFLE
      } else if (mode === AVSessionManager.LoopMode.LOOP_MODE_SHUFFLE) {
        this.playMode = AVSessionManager.LoopMode.LOOP_MODE_SINGLE
      }
    })
    this.session!.on('toggleFavorite', async (assetId: string) => {
      if (this.nowPlayingSong?.starred !== undefined) {
        let starStatus = await unstar(this.baseURL, this.username, this.password, this.nowPlayingSong!.id)
        if (starStatus === true) {
          this.nowPlayingSong.starred = undefined
          if (this.isPlaying === true) {
            await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
          } else {
            await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
          }
        }
      } else {
        let starStatus = await star(this.baseURL, this.username, this.password, this.nowPlayingSong!.id)
        if (starStatus === true) {
          let tmp_song: Song | undefined =
            await getSong(this.baseURL, this.username, this.password, this.nowPlayingSong!.id)
          if (tmp_song !== undefined && tmp_song.starred !== undefined) {
            this.nowPlayingSong!.starred = tmp_song.starred
          }
          if (this.isPlaying === true) {
            await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
          } else {
            await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
          }
        }
      }
    });
    this.session!.off('setSpeed');
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('timeUpdate', async (time: number) => {
      this.nowPlayedTime = time / 1000
      if (this.sleepTime > 0 && this.isPlaying === true) {
        this.sleepTime -= 0.1
        if (this.sleepTime <= 0) {
          if (this.fadeVolume === true) {
            this.fadeOut()
          } else {
            this.avPlayer!.pause()
          }
          this.isPlaying = false
          this.sleepTime = 0
        }
      }
      if (this.nowPlayingLyrics !== undefined && this.nowPlayingLyrics.synced === true) {
        for (let index = 1; index <= this.nowPlayingLyricsByGroup.length; index++) {
          if (index === this.nowPlayingLyricsByGroup.length || this.nowPlayingLyricsByGroup[index][0].start! > time) {
            this.lyricsIndex = index - 1
            break
          }
        }
      }
    })
    avPlayer.on('seekDone', async (seekDoneTime: number) => {
      console.info(`播放器跳转成功，当前时间为 ${seekDoneTime}`);
      if (this.isPlaying === true) {
        await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
      } else {
        await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
      }
    })
    avPlayer.on('volumeChange', (vol: number) => {
      console.info('设置播放音量' + vol)
    })
    avPlayer.on('error', async (err: BusinessError) => {
      await avPlayer.reset();
      console.error(`播放器出现错误，code is ${err.code}, message is ${err.message}`);
      if (err.code === 5400106) {
        promptAction.showToast({
          message: '播放失败，格式不支持或文件不存在！',
          duration: 500
        });
      } else if (err.code === 5400104) {
        promptAction.showToast({
          message: '播放失败，请检查网络连接！',
          duration: 500
        });
      }
    })
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          console.info('播放器重置。');
          this.stopContinuousTask()
          this.nowPlayedTime = 0
          break;
        case 'initialized':
          console.info('播放器初始化。');
          this.lyricsIndex = 0
          avPlayer.prepare();
          break;
        case 'prepared':
          console.info('播放器就绪。');
          if (this.session === undefined) {
            this.session = await AVSessionManager.createAVSession(context, 'AUDIO_PLAY', 'audio');
            await this.setSessionCallback()
            await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_INITIAL)
          }
          await this.session!.activate()
          this.session!.setExtras({
            requireAbilityList: ['url-cast'],
          });
          await this.setSessionInfo()
          await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PREPARE)
          if (this.audioNormalization === true && this.nowPlayingSong!.replayGain?.trackGain !== undefined) {
            this.avPlayer!.setVolume((100 + this.nowPlayingSong!.replayGain!.trackGain) / 100)
          }
          if (this.isPlaying === true) {
            if (this.fadeVolume === true) {
              this.fadeIn()
            } else {
              this.avPlayer!.play()
            }
          } else {
            if (this.fadeVolume === true) {
              this.fadeOut()
            } else {
              this.avPlayer!.pause()
            }
          }
          break;
        case 'playing':
          console.info('播放器开始播放。');
          await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
          this.startContinuousTask()
          break;
        case 'paused':
          console.info('播放器暂停。');
          await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
          this.stopContinuousTask()
          break;
        case 'completed':
          console.info('播放完毕。');
          if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_SINGLE) {
            await avPlayer.reset();
            this.avPlayer!.url =
              this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong!.id}&format=raw`;
          } else {
            await avPlayer.reset();
            if (this.nowPlayingIndex === this.nowPlayingList.length - 1) {
              this.nowPlayingIndex = 0
            } else {
              this.nowPlayingIndex += 1
            }
            this.nowPlayingSong = this.nowPlayingList[this.nowPlayingIndex]
            this.nowPlayingLyrics = await getLyrics(this.baseURL, this.username, this.password, this.nowPlayingSong.id)
            if (this.nowPlayingLyrics !== undefined) {
              this.groupLyrics()
            }
            this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
          }
          break;
        case 'stopped':
          console.info('播放器停止。');
          this.sleepTime = 0
          this.nowPlayedTime = 0
          await this.session!.destroy()
          this.session = undefined
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
            if (this.fadeVolume === true) {
              this.fadeOut()
            } else {
              this.avPlayer!.pause()
            }
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            this.isPlaying = false
            if (this.fadeVolume === true) {
              this.fadeOut()
            } else {
              this.avPlayer!.pause()
            }
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            this.isPlaying = true
            if (this.fadeVolume === true) {
              this.fadeIn()
            } else {
              this.avPlayer!.play()
            }
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
        Image(this.themeIcon)
          .width(deviceTypeInfo === '2in1' ? 18 : 24)
          .aspectRatio(1)
      }
      .margin({ right: deviceTypeInfo === '2in1' ? 156 : 0 })
      .width(deviceTypeInfo === '2in1' ? 40 : 48)
      .aspectRatio(1)
      .borderRadius(deviceTypeInfo === '2in1' ? 3 : 8)
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
  bindMenuBuilder() {
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
        this.showMenu = false
        this.info.open()
      })

      Button({ type: ButtonType.Normal }) {
        Text("下一首播放")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMenu = false
        if (this.nowPlayingList.length !== 0) {
          this.nowPlayingListOriginal.splice(this.nowPlayingIndex + 1, 0, this.longPressSong!)
          this.nowPlayingList.splice(this.nowPlayingIndex + 1, 0, this.longPressSong!)
          promptAction.showToast({
            message: '添加成功！',
            duration: 500
          });
        } else {
          promptAction.showToast({
            message: '播放队列不存在！',
            duration: 500
          });
        }
      })

      Button({ type: ButtonType.Normal }) {
        Text("加入播放队列")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMenu = false
        if (this.nowPlayingList.length !== 0) {
          this.nowPlayingListOriginal.push(this.longPressSong!)
          this.nowPlayingList.push(this.longPressSong!)
          promptAction.showToast({
            message: '添加成功！',
            duration: 500
          });
        } else {
          promptAction.showToast({
            message: '播放队列不存在！',
            duration: 500
          });
        }
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
      .backgroundColor($r('app.color.bar_background'))
      .visibility(this.addOrDelete === true ? Visibility.Visible : Visibility.None)
      .onClick(async () => {
        this.showMenu = false
        this.selectPlaylist.open()
        this.playlists = (await getPlaylists(this.baseURL, this.username, this.password)).sort((a, b) => {
          return Date.parse(b.changed) - Date.parse(a.changed);
        })
      })

      Button({ type: ButtonType.Normal }) {
        Text("从歌单中删除")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .backgroundColor($r('app.color.bar_background'))
      .visibility(this.addOrDelete === false ? Visibility.Visible : Visibility.None)
      .onClick(async () => {
        this.showMenu = false
        let success =
          await updatePlaylist(this.baseURL, this.username, this.password, this.playlist!.id, undefined, undefined,
            undefined, this.longPressIndex)
        if (success === true) {
          promptAction.showToast({
            message: '删除成功！',
            duration: 500
          });
          this.playlist = await getPlaylist(this.baseURL, this.username, this.password, this.playlist!.id)
          this.playlists = (await getPlaylists(this.baseURL, this.username, this.password)).sort((a, b) => {
            return Date.parse(b.changed) - Date.parse(a.changed);
          })
        } else {
          promptAction.showToast({
            message: '删除失败，请检查网络！',
            duration: 500
          });
        }
      })

      Button({ type: ButtonType.Normal }) {
        Text(this.longPressSong?.starred !== undefined ? "取消收藏" : "添加到收藏")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(18)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .borderRadius(10)
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.showMenu = false
        if (this.longPressSong?.starred !== undefined) {
          let starStatus = await unstar(this.baseURL, this.username, this.password, this.longPressSong!.id)
          if (starStatus === true) {
            promptAction.showToast({
              message: '取消收藏成功！',
              duration: 500
            });
            this.longPressSong.starred = undefined
            if (this.startPlaying === true && this.longPressSong!.id === this.nowPlayingSong!.id) {
              if (this.isPlaying === true) {
                await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
              } else {
                await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
              }
            }
          }
        } else {
          let starStatus = await star(this.baseURL, this.username, this.password, this.longPressSong!.id)
          if (starStatus === true) {
            promptAction.showToast({
              message: '收藏成功！',
              duration: 500
            });
            let tmp_song: Song | undefined =
              await getSong(this.baseURL, this.username, this.password, this.longPressSong!.id)
            if (tmp_song !== undefined && tmp_song.starred !== undefined) {
              this.longPressSong!.starred = tmp_song.starred
            }
            if (this.startPlaying === true && this.longPressSong!.id === this.nowPlayingSong!.id) {
              if (this.isPlaying === true) {
                await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
              } else {
                await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
              }
            }
          }
        }
      })
    }
    .width('90%')
    .height('auto')
    .borderRadius(10)
    .margin({ top: 20, bottom: 25 })
    .clip(true)
    .backgroundColor($r('app.color.bar_background'))
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
    .padding({ left: this.sidebarType === SideBarContainerType.Embed ? 20 : 72, top: 1 })
  }

  onDidBuild() {
    if (this.firstStart !== false || this.baseURL === '') {
      AlertDialog.show(
        {
          title: '首次启动',
          message: '请先到设置页面配置服务器连接。',
          autoCancel: false,
          height: 200,
          confirm: {
            value: '确认',
            fontColor: $r('app.color.font'),
            action: () => {
              this.firstStart = false
            }
          }
        }
      )
    }
  }

  async aboutToAppear() {
    context.getApplicationContext().setColorMode(this.theme)
    this.mainWindow = await window.getLastWindow(getContext(this))
    this.displayWidth = px2vp(this.mainWindow.getWindowProperties().windowRect.width)
    this.displayHeight = px2vp(this.mainWindow.getWindowProperties().windowRect.height)
    if (this.displayHeight < 700) {
      this.showCover = false
    } else {
      this.showCover = true
    }
    if (this.displayWidth > 1400) {
      this.sideBarWidth = 300
    } else {
      this.sideBarWidth = 240
    }
    if (this.displayWidth / this.displayHeight > 2 / 3 && this.displayHeight > 700) {
      this.sidebarType = SideBarContainerType.Embed
    } else {
      this.sidebarType = SideBarContainerType.Overlay
    }
    this.mainWindow.on('windowSizeChange', (size) => {
      this.displayWidth = px2vp(size.width)
      this.displayHeight = px2vp(size.height)
      if (this.displayHeight < 700) {
        this.showCover = false
      } else {
        this.showCover = true
      }
      if (this.displayWidth > 1400) {
        this.sideBarWidth = 300
      } else {
        this.sideBarWidth = 240
      }
      if (this.displayWidth / this.displayHeight > 2 / 3 && this.displayHeight > 700) {
        this.sidebarType = SideBarContainerType.Embed
      } else {
        this.sidebarType = SideBarContainerType.Overlay
      }
    })
    this.changeStatusBar()
    applicationContext.on('environment', this.environmentCallback);
    this.getStatusBarHeight()
    this.registerInterception()
    if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_SINGLE) {
      this.playModeIcon = $r('app.media.single')
    } else if (this.playMode === AVSessionManager.LoopMode.LOOP_MODE_LIST) {
      this.playModeIcon = $r('app.media.loop')
    } else {
      this.playModeIcon = $r('app.media.shuffle')
    }
    if (this.downloadDir === '') {
      this.createDir()
    }
    this.avPlayer = await media.createAVPlayer();
    this.setAVPlayerCallback(this.avPlayer!);
  }

  registerInterception() {
    this.pageStack.setInterception({
      willShow: (from: NavDestinationContext | "navBar", to: NavDestinationContext | "navBar",
        operation: NavigationOperation, animated: boolean) => {
        if (this.sidebarType === SideBarContainerType.Overlay) {
          if (typeof to === "string") {
            this.showControlButton = true
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.controlButtonWidth = 48
            })
          } else {
            animateTo({
              duration: 300,
              curve: Curve.EaseOut,
            }, () => {
              this.controlButtonWidth = 0
            })
            this.showControlButton = false
          }
        }
      }
    })
  }

  build() {
    Stack() {
      SideBarContainer(this.sidebarType) {
        Column() {
          Text("Harmonic")
            .width('100%')
            .height('auto')
            .textAlign(TextAlign.Center)
            .fontSize(36)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .visibility(this.sidebarType === SideBarContainerType.Embed ? Visibility.Visible : Visibility.None)

          Column() {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Image("")
                Text("首页")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
            }
            .width('100%')
            .height(60)
            .borderRadius(20)
            .backgroundColor($r('app.color.bar_background'))
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 0
              this.title = '首页'
            })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Image("")
                Text("搜索")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
            }
            .width('100%')
            .height(60)
            .borderRadius(20)
            .backgroundColor($r('app.color.bar_background'))
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 1
              this.title = '搜索'
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
            .borderRadius(20)
            .backgroundColor($r('app.color.bar_background'))
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 2
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
            .borderRadius(20)
            .backgroundColor($r('app.color.bar_background'))
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 3
              this.title = '艺术家'
            })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Image("")
                Text("歌单")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
            }
            .width('100%')
            .height(60)
            .borderRadius(20)
            .backgroundColor($r('app.color.bar_background'))
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 4
              this.title = '歌单'
            })
          }
          .width('90%')
          .height('auto')
          .borderRadius(20)
          .clip(true)
          .backgroundColor($r('app.color.bar_background'))

          Blank()

          Column() {
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
            .borderRadius(20)
            .backgroundColor($r('app.color.bar_background'))
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 5
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
            .borderRadius(20)
            .backgroundColor($r('app.color.bar_background'))
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 6
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
        .padding({
          top: this.sidebarType === SideBarContainerType.Embed ? this.statusBarHeight + 12 : this.statusBarHeight + 57,
          bottom: this.sidebarType === SideBarContainerType.Embed ? 12 : 27
        })
        .shadow({
          radius: this.shadowRadius,
          color: $r('app.color.sidebarShadow'),
          offsetX: 0,
          offsetY: 0
        })

        Stack() {
          Navigation(this.pageStack) {
            Stack() {
              Column() {
                if (this.nowPage === 0) {
                  Column() {
                    Home()
                  }
                  .height('100%')
                  .width('100%')
                }

                if (this.nowPage === 1) {
                  Column() {
                    Search_()
                  }
                  .height('100%')
                  .width('100%')
                }

                if (this.nowPage === 2) {
                  Column() {
                    Albums()
                  }
                  .height('100%')
                  .width('100%')
                }

                if (this.nowPage === 3) {
                  Column() {
                    Artists()
                  }
                  .height('100%')
                  .width('100%')
                }

                if (this.nowPage === 4) {
                  Column() {
                    Playlists()
                  }
                  .height('100%')
                  .width('100%')
                }

                if (this.nowPage === 5) {
                  Column() {
                    Setting()
                  }
                  .height('100%')
                  .width('100%')
                }

                if (this.nowPage === 6) {
                  Column() {
                    About()
                  }
                  .height('100%')
                  .width('100%')
                }
              }
              .height('100%')
              .width('100%')

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
              .visibility(this.showProgress === true && this.nowPage <= 4 ? Visibility.Visible : Visibility.None)
            }
          }
          .mode(NavigationMode.Stack)
          .title(this.titlebar())
          .titleMode(NavigationTitleMode.Mini)
          .hideBackButton(true)
          .padding({ top: this.statusBarHeight })
          .menus(this.menuBuilder())
          .bindSheet($$this.showMenu, this.bindMenuBuilder, {
            showClose: false,
            height: SheetSize.FIT_CONTENT,
            width: this.sidebarType === SideBarContainerType.Embed ? 600 : '100%',
            preferType: SheetType.BOTTOM,
            backgroundColor: $r('app.color.content_background'),
          })
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
                .objectFit(ImageFit.Contain)
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
                this.nowPlayingLyrics =
                  await getLyrics(this.baseURL, this.username, this.password, this.nowPlayingSong.id)
                if (this.nowPlayingLyrics !== undefined) {
                  this.groupLyrics()
                }
                this.avPlayer!.url =
                  this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
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
                this.nowPlayingLyrics =
                  await getLyrics(this.baseURL, this.username, this.password, this.nowPlayingSong.id)
                if (this.nowPlayingLyrics !== undefined) {
                  this.groupLyrics()
                }
                this.avPlayer!.url =
                  this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong.id}&format=raw`;
              })
            }
            .width(125)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .height(85)
          .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
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
      .sideBarWidth(this.sideBarWidth)
      .showSideBar(this.sidebarType === SideBarContainerType.Embed ? true : this.showSidebar)
      .showControlButton(false)
      .autoHide(this.sidebarType === SideBarContainerType.Embed ? false : true)
      .sideBarPosition(SideBarPosition.Start)
      .onChange((show: boolean) => {
        if (show === true && this.sidebarType === SideBarContainerType.Overlay) {
          this.shadowRadius = 100
          this.showSidebar = true
        } else {
          setTimeout(() => {
            this.shadowRadius = 0
            this.showSidebar = false
          }, 300)
        }
      })

      Button({ type: ButtonType.Normal }) {
        Image($r('app.media.sidebar'))
          .width(24)
          .aspectRatio(1)
      }
      .position({
        x: 10,
        y: this.statusBarHeight + 4
      })
      .width(this.controlButtonWidth)
      .height(48)
      .borderRadius(8)
      .backgroundColor('#00000000')
      .onClick(async () => {
        animateTo({
          duration: 300,
          curve: Curve.EaseOut,
        }, () => {
          this.showSidebar = !this.showSidebar
        })
      })
      .visibility(this.sidebarType === SideBarContainerType.Overlay && this.showControlButton === true ?
      Visibility.Visible : Visibility.Hidden)
    }
    .width("100%")
    .height('100%')
  }
}