import { window } from '@kit.ArkUI';
import { common, ConfigurationConstant, wantAgent, WantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { image } from '@kit.ImageKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { fileIo as fs, picker, ReadOptions } from '@kit.CoreFileKit';
import CryptoJS from '@ohos/crypto-js';
import {
  getAlbumList,
  getCover,
  getFrequentAlbums,
  getIndexes,
  getLyrics,
  getMusicFolders,
  getNewestAlbums,
  getPlaylist,
  getPlaylists,
  getRandomAlbums,
  getRecentAlbums,
  getSong,
  getStarredAlbums,
  getStarredArtists,
  getVerse,
  scrobble,
  star,
  unstar,
  updatePlaylist
} from '../utils/Api';
import { Album, Artist, Line, MusicFolder, Playlist, SaveState, Song, StructuredLyric,
  Verse } from '../utils/Interface';
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
import firstStartBuilder from './dialogs/FirstStart';
import { buffer } from '@kit.ArkTS';
import { KeyCode } from '@kit.InputKit';
import { i18n, intl } from '@kit.LocalizationKit';

let deviceTypeInfo: string = deviceInfo.deviceType;
let transliterator = i18n.Transliterator.getInstance('Any-Latn');
let options: intl.CollatorOptions = {
  localeMatcher: "lookup",
  usage: "sort",
  sensitivity: "variant",
  numeric: true
};
let locale = new intl.Locale();
let collator = new intl.Collator(locale.toString(), options);

@Entry
@Component
struct Index {
  @Provide mainWindow: window.Window | undefined = undefined
  @Provide pageStack: NavPathStack = new NavPathStack()
  @State statusBarHeight: number = 0;
  @State shadowRadius: number = 0;
  @Provide showSidebar: boolean = false;
  @Provide recentAlbums: Album[] = []
  @Provide newestAlbums: Album[] = []
  @Provide frequentAlbums: Album[] = []
  @Provide randomAlbums: Album[] = []
  @Provide starredAlbums: Album[] = []
  @Provide starredArtists: Artist[] = []
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
  @Provide sliderValue: number = 0
  @Provide sliderMoving: boolean = false
  @Provide musicFolders: MusicFolder[] = []
  @Provide searchSongs: Song[] = []
  @Provide searchAlbums: Album[] = []
  @Provide searchArtists: Artist[] = []
  @Provide showLibrary: boolean = false
  @Provide closePlay: boolean = false
  @Provide @Watch('updatePage') needUpdate: boolean = false
  @State coverSize: number = 64
  @State themeIcon: Resource = $r('app.media.auto')
  @State sideBarWidth: number = 240
  @State startPlayTime: number = 0
  @State verse: Verse | undefined = undefined
  @StorageLink('libraryStates') libraryStatesStr: string = '{}'
  @Provide libraryStates: Record<number, boolean> = JSON.parse(this.libraryStatesStr)
  @StorageLink('theme') theme: number = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  @StorageLink('playMode') playMode: number = AVSessionManager.LoopMode.LOOP_MODE_LIST
  @StorageLink('audioNormalizatio') audioNormalization: boolean = false
  @StorageLink('fadeVolume') fadeVolume: boolean = false
  @StorageLink('autoPlay') autoPlay: boolean = false
  @StorageLink('firstStart') firstStart: boolean = true
  @StorageLink('downloadDir') downloadDir: string = ''
  uiContext: UIContext | undefined = undefined
  context: common.UIAbilityContext | undefined = undefined
  selectPlaylist: CustomDialogController = new CustomDialogController({
    builder: selectPlaylistBuilder(),
    width: 350,
    height: 372,
    backgroundColor: $r('app.color.start_window_background')
  })
  info: CustomDialogController = new CustomDialogController({
    builder: infoBuilder(),
    width: 350,
    height: 380,
    backgroundColor: $r('app.color.start_window_background'),
  })
  firstStartTip: CustomDialogController = new CustomDialogController({
    builder: firstStartBuilder(),
    width: 350,
    height: 176,
    backgroundColor: $r('app.color.start_window_background'),
  })

  private getStatusBarHeight() {
    window.getLastWindow(this.context, (error, topWindow) => {
      if (topWindow) {
        let area = topWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.statusBarHeight = this.uiContext!.px2vp(area.topRect.height)
      }
    });
  }

  initThemeIcon() {
    if (this.theme === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.themeIcon = $r('app.media.light')
    } else if (this.theme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      this.themeIcon = $r('app.media.dark')
    } else {
      this.themeIcon = $r('app.media.auto')
    }
  }

  createDir() {
    const documentViewPicker = new picker.DocumentViewPicker(this.context!);
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
      backgroundTaskManager.startBackgroundRunning(this.context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
        console.info(`启动长时任务。`);
      }).catch((err: BusinessError) => {
        console.error(`启动长时任务出错，代码 ${err.code}，错误信息 ${err.message}`);
      });
    });
  }

  async stopContinuousTask() {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
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
    this.session!.on('seek', async (time: number) => {
      await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_BUFFERING)
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
          this.uiContext!.getPromptAction().showToast({
            message: '取消收藏成功！',
            duration: 500
          });
          this.nowPlayingSong.starred = undefined
          if (this.isPlaying === true) {
            await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
          } else {
            await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
          }
        } else {
          this.uiContext!.getPromptAction().showToast({
            message: '取消收藏失败，请检查网络！',
            duration: 500
          });
        }
      } else {
        let starStatus = await star(this.baseURL, this.username, this.password, this.nowPlayingSong!.id)
        if (starStatus === true) {
          this.uiContext!.getPromptAction().showToast({
            message: '收藏成功！',
            duration: 500
          });
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
        } else {
          this.uiContext!.getPromptAction().showToast({
            message: '收藏失败，请检查网络！',
            duration: 500
          });
        }
      }
    });
    this.session!.off('setSpeed');
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('timeUpdate', async (time: number) => {
      this.nowPlayedTime = time / 1000
      if (this.sliderMoving === false) {
        this.sliderValue = this.nowPlayedTime / this.nowPlayingSong?.duration! * 100
      }
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
      this.nowPlayedTime = seekDoneTime / 1000
      if (this.isPlaying === true) {
        await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PLAY)
      } else {
        await this.setPlaybackState(AVSessionManager.PlaybackState.PLAYBACK_STATE_PAUSE)
      }
      this.sliderMoving = false
    })
    avPlayer.on('volumeChange', (vol: number) => {
      console.info('设置播放音量' + vol)
    })
    avPlayer.on('error', async (err: BusinessError) => {
      await avPlayer.reset();
      console.error(`播放器出现错误，code is ${err.code}, message is ${err.message}`);
      if (err.code === 5400106) {
        this.uiContext!.getPromptAction().showToast({
          message: '播放失败，格式不支持或文件不存在！',
          duration: 500
        });
      } else if (err.code === 5400104) {
        this.uiContext!.getPromptAction().showToast({
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
          await scrobble(this.baseURL, this.username, this.password, this.nowPlayingSong!.id, true);
          break;
        case 'initialized':
          console.info('播放器初始化。');
          this.lyricsIndex = 0
          avPlayer.prepare();
          break;
        case 'prepared':
          console.info('播放器就绪。');
          if (this.session === undefined) {
            this.session = await AVSessionManager.createAVSession(this.context!, 'AUDIO_PLAY', 'audio');
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
          if (this.startPlayTime !== 0) {
            this.avPlayer!.seek(this.startPlayTime * 1000)
            this.startPlayTime = 0
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
          scrobble(this.baseURL, this.username, this.password, this.nowPlayingSong!.id, false);
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

  async updatePage() {
    this.showProgress = true
    if (this.musicFolders.length === 0) {
      this.musicFolders = await getMusicFolders(this.baseURL, this.username, this.password)
      if (this.musicFolders.length === 0) {
        this.uiContext!.getPromptAction().showToast({
          message: '获取音乐库失败，请检查网络连接！',
          duration: 500
        });
      } else {
        const keys = Object.keys(this.libraryStates)
        const allFalse = keys.length > 0 && keys.every(key => this.libraryStates[key] === false)
        if (keys.length === 0 || allFalse) {
          this.libraryStates['1'] = true
        }
      }
    }
    switch (this.nowPage) {
      case 0:
        this.recentAlbums = []
        this.newestAlbums = []
        this.frequentAlbums = []
        this.randomAlbums = []
        this.starredAlbums = []
        this.starredArtists = []
        break;
      case 1:
        this.searchSongs = []
        this.searchAlbums = []
        this.searchArtists = []
        break;
      case 2:
        this.albums = []
        break;
      case 3:
        this.artists = []
        break;
      default:
        break;
    }
    let keys = Object.keys(this.libraryStates)
    for (const id of keys) {
      if (this.libraryStates[id] === true) {
        if (!this.musicFolders.some(item => item.id === Number(id))) {
          this.libraryStates[id] = false
          continue;
        }
        switch (this.nowPage) {
          case 0:
            let recentAlbums = await getRecentAlbums(this.baseURL, this.username, this.password, Number(id))
            this.recentAlbums.unshift(...recentAlbums)
            let newestAlbums = await getNewestAlbums(this.baseURL, this.username, this.password, Number(id))
            this.newestAlbums.unshift(...newestAlbums)
            let frequentAlbums = await getFrequentAlbums(this.baseURL, this.username, this.password, Number(id))
            this.frequentAlbums.unshift(...frequentAlbums)
            let randomAlbums = await getRandomAlbums(this.baseURL, this.username, this.password, Number(id))
            this.randomAlbums.unshift(...randomAlbums)
            let starredAlbums = await getStarredAlbums(this.baseURL, this.username, this.password, Number(id))
            this.starredAlbums.unshift(...starredAlbums)
            let starredArtists = await getStarredArtists(this.baseURL, this.username, this.password, Number(id))
            this.starredArtists.unshift(...starredArtists)
            break;
          case 2:
            let offset = 0
            let size = 500
            while (true) {
              let albums = await getAlbumList(this.baseURL, this.username, this.password, offset, Number(id))
              if (albums === undefined || albums.length === 0) {
                break;
              }
              this.albums.unshift(...albums)
              if (albums.length < size) {
                break;
              }
              offset += size;
            }
            this.albums.sort((a, b) => {
              return collator.compare(transliterator.transform(a.name), transliterator.transform(b.name));
            })
            break;
          case 3:
            let artists = await getIndexes(this.baseURL, this.username, this.password, Number(id))
            this.artists.unshift(...artists)
            this.artists.sort((a, b) => {
              return collator.compare(transliterator.transform(a.name), transliterator.transform(b.name));
            })
            break;
          default:
            break;
        }
      }
    }
    this.showProgress = false
  }

  @Builder
  musicFolderMenu() {
    Column() {
      ForEach(this.musicFolders, (musicFolder: MusicFolder, index) => {
        Button({ type: ButtonType.Normal }) {
          Row() {
            Radio({ value: musicFolder.name, group: musicFolder.name, indicatorType: RadioIndicatorType.TICK })
              .width(this.displayWidth > 1400 ? 20 : 18)
              .margin({ left: deviceTypeInfo === '2in1' ? 10 : 7 })
              .checked(this.libraryStates[musicFolder.id])
              .radioStyle({
                checkedBackgroundColor: $r('app.color.radio'),
                indicatorColor: $r('app.color.start_window_background')
              })
            Text(musicFolder.name)
              .width('100%')
              .layoutWeight(1)
              .fontSize(this.displayWidth > 1400 ? 20 : 18)
              .fontWeight(FontWeight.Medium)
              .padding({ left: deviceTypeInfo === '2in1' ? 0 : 4, right: deviceTypeInfo === '2in1' ? 1 : 5 })
              .fontColor($r('app.color.font'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
        }
        .height(deviceTypeInfo === '2in1' ? (this.displayWidth > 1400 ? 40 : 35) : 30)
        .width('100%')
        .borderRadius(8)
        .backgroundColor(Color.Transparent)
        .hitTestBehavior(HitTestMode.Block)
        .onClick(() => {
          this.libraryStates[musicFolder.id] = !this.libraryStates[musicFolder.id]
          this.libraryStatesStr = JSON.stringify(this.libraryStates)
        })
      })
    }
    .width(deviceTypeInfo === '2in1' ? 200 : 128)
    .height(deviceTypeInfo === '2in1' ?
      (this.displayWidth > 1400 ? 40 * this.musicFolders.length : 35 * this.musicFolders.length) :
      30 * this.musicFolders.length)
    .alignItems(HorizontalAlign.Start)
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
      .backgroundColor(Color.Transparent)
      .onClick(() => {
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
        this.context?.getApplicationContext().setColorMode(this.theme)
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
          this.uiContext!.getPromptAction().showToast({
            message: '添加成功！',
            duration: 500
          });
        } else {
          this.uiContext!.getPromptAction().showToast({
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
          this.uiContext!.getPromptAction().showToast({
            message: '添加成功！',
            duration: 500
          });
        } else {
          this.uiContext!.getPromptAction().showToast({
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
          this.uiContext!.getPromptAction().showToast({
            message: '删除成功！',
            duration: 500
          });
          this.playlist = await getPlaylist(this.baseURL, this.username, this.password, this.playlist!.id)
          this.playlists = (await getPlaylists(this.baseURL, this.username, this.password)).sort((a, b) => {
            return Date.parse(b.changed) - Date.parse(a.changed);
          })
        } else {
          this.uiContext!.getPromptAction().showToast({
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
            this.uiContext!.getPromptAction().showToast({
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
          } else {
            this.uiContext!.getPromptAction().showToast({
              message: '取消收藏失败，请检查网络！',
              duration: 500
            });
          }
        } else {
          let starStatus = await star(this.baseURL, this.username, this.password, this.longPressSong!.id)
          if (starStatus === true) {
            this.uiContext!.getPromptAction().showToast({
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
          } else {
            this.uiContext!.getPromptAction().showToast({
              message: '收藏失败，请检查网络！',
              duration: 500
            });
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
  titlebar() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Image($r('app.media.sidebar'))
          .width(24)
          .aspectRatio(1)
      }
      .width(48)
      .height(48)
      .borderRadius(8)
      .backgroundColor(Color.Transparent)
      .onClick(async () => {
        getVerse().then((verse: Verse) => {
          this.verse = verse
        })
        this.uiContext?.animateTo({
          duration: 300,
          curve: Curve.EaseOut,
        }, () => {
          this.showSidebar = !this.showSidebar
        })
      })
      .visibility(this.sidebarType === SideBarContainerType.Overlay ? Visibility.Visible : Visibility.None)

      Button({ type: ButtonType.Normal }) {
        Row() {
          Text("音乐库")
            .fontSize(this.displayWidth > 1400 ? 20 : 18)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Medium)
          SymbolGlyph(this.showLibrary ? $r('sys.symbol.arrowtriangle_up_fill') :
          $r('sys.symbol.arrowtriangle_down_fill'))
            .margin({ left: this.displayWidth > 1400 ? 10 : 7 })
            .fontColor([$r('app.color.font')])
        }
      }
      .padding({
        left: this.displayWidth > 1400 ? 15 : 12,
        right: this.displayWidth > 1400 ? 15 : 12,
        top: 5,
        bottom: 5
      })
      .margin({ left: 10 })
      .borderRadius(8)
      .backgroundColor($r('app.color.button_selected'))
      .bindContextMenu(this.showLibrary, this.musicFolderMenu, {
        borderRadius: 10,
        backgroundBlurStyle: BlurStyle.COMPONENT_THICK,
        onDisappear: () => {
          const keys = Object.keys(this.libraryStates)
          const allFalse = keys.length > 0 && keys.every(key => this.libraryStates[key] === false)
          if (keys.length === 0 || allFalse) {
            this.libraryStates['1'] = true
            this.libraryStatesStr = JSON.stringify(this.libraryStates)
          }
          this.needUpdate = !this.needUpdate
          this.showLibrary = false;
        }
      })
      .onClick(async () => {
        this.musicFolders = []
        this.musicFolders = await getMusicFolders(this.baseURL, this.username, this.password)
        if (this.musicFolders.length === 0) {
          this.uiContext!.getPromptAction().showToast({
            message: '获取音乐库失败，请检查网络连接！',
            duration: 500
          });
        } else {
          this.showLibrary = true
        }
      })
    }
    .width("100%")
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: 10 })
  }

  onPageShow() {
    if (this.firstStart !== false || this.baseURL === '') {
      this.firstStartTip.open()
    }
  }

  onPageHide() {
    this.firstStartTip.close()
  }

  async aboutToDisappear() {
    let path = this.context!.filesDir + '/saveState.json';
    if (this.startPlaying === true) {
      let saveState: SaveState = {
        nowPlayingSong: this.nowPlayingSong,
        nowPlayingLyrics: this.nowPlayingLyrics,
        nowPlayingLyricsByGroup: this.nowPlayingLyricsByGroup,
        nowPlayingList: this.nowPlayingList,
        nowPlayingListOriginal: this.nowPlayingListOriginal,
        nowPlayingIndex: this.nowPlayingIndex,
        lyricsIndex: this.lyricsIndex,
        startPlaying: this.startPlaying,
        isPlaying: this.isPlaying,
        nowPlayedTime: this.nowPlayedTime,
      };
      try {
        let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.truncateSync(path);
        fs.writeSync(file.fd, JSON.stringify(saveState));
        fs.closeSync(file);
        console.info('写入成功');
      } catch (err) {
        console.error('写入失败:', JSON.stringify(err));
      }
    } else {
      if (fs.accessSync(path)) {
        try {
          fs.truncateSync(path);
          console.info('清空成功');
        } catch (err) {
          console.error('清空失败:', JSON.stringify(err));
        }
      }
    }
    await scrobble(this.baseURL, this.username, this.password, this.nowPlayingSong!.id, true);
  }

  async aboutToAppear() {
    getVerse().then((verse: Verse) => {
      this.verse = verse
    })
    this.uiContext = this.getUIContext();
    if (!this.uiContext) {
      console.warn("no uiContext");
      return;
    }
    this.context = this.uiContext.getHostContext() as common.UIAbilityContext;
    this.context.getApplicationContext().setColorMode(this.theme)
    this.mainWindow = await window.getLastWindow(this.context)
    this.displayWidth = this.uiContext!.px2vp(this.mainWindow.getWindowProperties().windowRect.width)
    this.displayHeight = this.uiContext!.px2vp(this.mainWindow.getWindowProperties().windowRect.height)
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
      this.displayWidth = this.uiContext!.px2vp(size.width)
      this.displayHeight = this.uiContext!.px2vp(size.height)
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
    this.initThemeIcon()
    this.getStatusBarHeight()
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
    let path = this.context!.filesDir + '/saveState.json';
    if (fs.accessSync(path)) {
      let stat = fs.statSync(path);
      let fileSize = stat.size;
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let arrayBuffer = new ArrayBuffer(fileSize);
      let readOptions: ReadOptions = {
        offset: 0,
        length: arrayBuffer.byteLength
      };
      try {
        let readLen = fs.readSync(file.fd, arrayBuffer, readOptions);
        if (readLen > 0) {
          let buf = buffer.from(arrayBuffer, 0, readLen);
          let saveState: SaveState = JSON.parse(buf.toString())
          this.nowPlayingSong = saveState.nowPlayingSong
          this.nowPlayingLyrics = saveState.nowPlayingLyrics
          this.nowPlayingLyricsByGroup = saveState.nowPlayingLyricsByGroup
          this.nowPlayingList = saveState.nowPlayingList
          this.nowPlayingListOriginal = saveState.nowPlayingListOriginal
          this.nowPlayingIndex = saveState.nowPlayingIndex
          this.lyricsIndex = saveState.lyricsIndex
          this.startPlaying = saveState.startPlaying
          this.startPlayTime = saveState.nowPlayedTime
          if (this.autoPlay === true) {
            this.isPlaying = true
          } else {
            this.isPlaying = false
          }
          console.info("读取成功");
          await this.avPlayer!.reset()
          this.avPlayer!.url = this.baseURL + '/rest/stream' + this.auth + `&id=${this.nowPlayingSong!.id}&format=raw`;
        }
      } catch (err) {
        console.error('读取失败:', JSON.stringify(err));
      }
      fs.closeSync(file);
    }
  }

  onBackPress() {
    if (this.showPlay) {
      this.closePlay = !this.closePlay
      return true
    }
    if (this.showSidebar) {
      this.uiContext?.animateTo({
        duration: 300,
        curve: Curve.EaseOut,
      }, () => {
        this.showSidebar = false
      })
      return true
    }
    return false
  }

  build() {
    Stack() {
      SideBarContainer(this.sidebarType) {
        Column() {
          Column(){
            Text(this.verse !== undefined ? "「" + this.verse.hitokoto.replace(/[。！？!?,，]$/, '') + "」" : "「" + "正在加载中..." + "」")
              .width('87%')
              .fontSize(this.displayWidth > 1400 ? 18 : 16)
              .fontColor($r('app.color.font_secondary'))
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)

            Text(this.verse !== undefined ? "—— " + this.verse.from_who : "")
              .width('87%')
              .fontSize(this.displayWidth > 1400 ? 18 : 16)
              .fontColor($r('app.color.font_secondary'))
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.End)
              .margin({ top: 5 })
              .visibility(this.verse !== undefined ? Visibility.Visible : Visibility.None)
          }
          .margin({ bottom: 20 })

          Column() {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Image($r('app.media.home'))
                  .width(24)
                  .aspectRatio(1)
                  .margin({ right: 10 })
                Text("首页")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
              .width('50%')
            }
            .width('100%')
            .height(50)
            .borderRadius(10)
            .backgroundColor(this.nowPage === 0 ? $r('app.color.button_selected') : $r('app.color.content_background'))
            .onClick(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 0
            })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Image($r('app.media.search'))
                  .width(24)
                  .aspectRatio(1)
                  .margin({ right: 10 })
                Text("搜索")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
              .width('50%')
            }
            .width('100%')
            .height(50)
            .borderRadius(10)
            .backgroundColor(this.nowPage === 1 ? $r('app.color.button_selected') : $r('app.color.content_background'))
            .onClick(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 1
            })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Image($r('app.media.album'))
                  .width(24)
                  .aspectRatio(1)
                  .margin({ right: 10 })
                Text("专辑")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
              .width('50%')
            }
            .width('100%')
            .height(50)
            .borderRadius(10)
            .backgroundColor(this.nowPage === 2 ? $r('app.color.button_selected') : $r('app.color.content_background'))
            .onClick(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 2
            })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Image($r('app.media.artist'))
                  .width(24)
                  .aspectRatio(1)
                  .margin({ right: 10 })
                Text("艺术家")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
              .width('50%')
            }
            .width('100%')
            .height(50)
            .borderRadius(10)
            .backgroundColor(this.nowPage === 3 ? $r('app.color.button_selected') : $r('app.color.content_background'))
            .onClick(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 3
            })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Image($r('app.media.playlist'))
                  .width(24)
                  .aspectRatio(1)
                  .margin({ right: 10 })
                Text("歌单")
                  .fontSize(20)
                  .fontColor($r('app.color.font'))
              }
              .width('50%')
            }
            .width('100%')
            .height(50)
            .borderRadius(10)
            .backgroundColor(this.nowPage === 4 ? $r('app.color.button_selected') : $r('app.color.content_background'))
            .onClick(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 4
            })
          }
          .width('90%')
          .height('auto')
          .borderRadius(10)
          .clip(true)
          .backgroundColor($r('app.color.content_background'))

          Blank()

          Row() {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Image($r('app.media.setting'))
                  .width(24)
                  .height(24)
              }
            }
            .width(50)
            .height(50)
            .borderRadius(10)
            .backgroundColor(this.nowPage === 5 ? $r('app.color.button_selected') : $r('app.color.content_background'))
            .onClick(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 5
            })

            Button({ type: ButtonType.Normal }) {
              Row() {
                Image($r('app.media.info'))
                  .width(26)
                  .height(26)
              }
            }
            .width(50)
            .height(50)
            .borderRadius(10)
            .backgroundColor(this.nowPage === 6 ? $r('app.color.button_selected') : $r('app.color.content_background'))
            .onClick(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.pageStack.clear()
              this.nowPage = 6
            })
          }
          .width('90%')
          .height('auto')
          .borderRadius(10)
          .clip(true)
          .backgroundColor($r('app.color.content_background'))
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.content_background'))
        .padding({
          top: this.sidebarType === SideBarContainerType.Embed ? this.statusBarHeight + 23 : this.statusBarHeight + 15,
          bottom: this.sidebarType === SideBarContainerType.Embed ? this.sideBarWidth * 0.05 : this.sideBarWidth * 0.05 + 5
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

          if (this.sidebarType === SideBarContainerType.Overlay) {
            Column()
              .width(this.displayWidth)
              .height(this.showPlay ? '100%' : 85)
              .justifyContent(FlexAlign.Center)
              .backgroundImage(this.baseURL + this.getCoverUrl + this.auth +
                `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
              .backgroundImageSize(ImageSize.FILL)
              .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
              .backgroundBrightness({
                rate: this.context!.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? 0.2 : 0.5,
                lightUpDegree: this.context!.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ?
                  0.1 :
                  0.5
              })
              .opacity(this.showPlay ? 1 : 0)
              .position({
                bottom: 0,
                right: 0
              })
              .visibility(this.startPlaying === true ? Visibility.Visible : Visibility.Hidden)
              .transition(TransitionEffect.translate({ y: 100 }).animation({ curve: Curve.Ease, duration: 600 }))

            Column() {
              if (this.showPlay === false) {
                Row() {
                  Row() {
                    Image(this.baseURL + this.getCoverUrl + this.auth +
                      `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
                      .alt($rawfile('nocover.png'))
                      .objectFit(ImageFit.Contain)
                      .width(60)
                      .aspectRatio(1)
                      .borderRadius(5)
                      .geometryTransition("cover_overlay")
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
                    .backgroundColor(Color.Transparent)
                    .onClick(async () => {
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
                      .backgroundColor(Color.Transparent)
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
                    }

                    Button({ type: ButtonType.Circle }) {
                      Image($r('app.media.next'))
                        .width(30)
                        .height(30)
                    }
                    .width(35)
                    .height(35)
                    .backgroundColor(Color.Transparent)
                    .onClick(async () => {
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
                .opacity(this.showPlay ? 0 : 1)
                .padding({ left: 15, right: 15, bottom: 5 })
                .onClick(() => {
                  if (this.showPlay === true) {
                    this.showPlay = false
                  }
                  this.getUIContext()?.animateTo({
                    duration: 600,
                    curve: Curve.Friction
                  }, () => {
                    this.showPlay = true
                  })
                })
              } else {
                Column() {
                  Play()
                    .onKeyEvent((event?: KeyEvent) => {
                      if (event && event.keyCode === KeyCode.KEYCODE_SPACE && event.type === KeyType.Up) {
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
                      }
                    })
                }
                .opacity(this.showPlay ? 1 : 0)
              }
            }
            .width(this.displayWidth)
            .height(this.showPlay ? '100%' : 85)
            .justifyContent(FlexAlign.Center)
            .backgroundBlurStyle(this.showPlay ? BlurStyle.NONE : BlurStyle.COMPONENT_THICK)
            .position({
              bottom: 0,
              right: 0
            })
            .visibility(this.startPlaying === true ? Visibility.Visible : Visibility.Hidden)
            .transition(TransitionEffect.translate({ y: 100 }).animation({ curve: Curve.Ease, duration: 600 }))
          }

          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Transparent)
            .visibility(this.sidebarType === SideBarContainerType.Overlay && this.showSidebar === true ?
            Visibility.Visible : Visibility.None)
            .onTouch(() => {
              this.uiContext?.animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
            })
        }
        .width("100%")
        .height('100%')
      }
      .width("100%")
      .height('100%')
      .backgroundColor($r('app.color.content_background'))
      .sideBarWidth(this.sideBarWidth)
      .minSideBarWidth(this.sideBarWidth)
      .maxSideBarWidth(this.sideBarWidth)
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

      if (this.sidebarType === SideBarContainerType.Embed) {
        Column()
          .width(this.showPlay ? this.displayWidth : this.displayWidth - this.sideBarWidth)
          .height(this.showPlay ? '100%' : 85)
          .justifyContent(FlexAlign.Center)
          .backgroundImage(this.baseURL + this.getCoverUrl + this.auth +
            `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
          .backgroundImageSize(ImageSize.FILL)
          .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
          .backgroundBrightness({
            rate: this.context!.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? 0.2 : 0.5,
            lightUpDegree: this.context!.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? 0.1 :
              0.5
          })
          .opacity(this.showPlay ? 1 : 0)
          .position({
            bottom: 0,
            right: 0
          })
          .visibility(this.startPlaying === true && this.sidebarType === SideBarContainerType.Embed ?
          Visibility.Visible : Visibility.Hidden)
          .transition(TransitionEffect.translate({ y: 100 }).animation({ curve: Curve.Ease, duration: 600 }))

        Column() {
          if (this.showPlay === false) {
            Row() {
              Row() {
                Image(this.baseURL + this.getCoverUrl + this.auth +
                  `&id=${this.nowPlayingSong?.id}&size=${this.coverSize}`)
                  .alt($rawfile('nocover.png'))
                  .objectFit(ImageFit.Contain)
                  .width(60)
                  .aspectRatio(1)
                  .borderRadius(5)
                  .geometryTransition("cover_embed")
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
                .backgroundColor(Color.Transparent)
                .onClick(async () => {
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
                  .backgroundColor(Color.Transparent)
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
                }

                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.next'))
                    .width(30)
                    .height(30)
                }
                .width(35)
                .height(35)
                .backgroundColor(Color.Transparent)
                .onClick(async () => {
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
            .padding({ left: 15, right: 15, bottom: 5 })
            .onClick(() => {
              if (this.showPlay === true) {
                this.showPlay = false
              }
              this.getUIContext()?.animateTo({
                duration: 600,
                curve: Curve.Friction
              }, () => {
                this.showPlay = true
              })
            })
          } else {
            Column() {
              Play()
                .onKeyEvent((event?: KeyEvent) => {
                  if (event && event.keyCode === KeyCode.KEYCODE_SPACE && event.type === KeyType.Up) {
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
                  }
                })
            }
          }
        }
        .width(this.showPlay ? this.displayWidth : this.displayWidth - this.sideBarWidth)
        .height(this.showPlay ? '100%' : 85)
        .justifyContent(FlexAlign.Center)
        .backgroundBlurStyle(this.showPlay ? BlurStyle.NONE : BlurStyle.COMPONENT_THICK)
        .position({
          bottom: 0,
          right: 0
        })
        .visibility(this.startPlaying === true && this.sidebarType === SideBarContainerType.Embed ? Visibility.Visible :
        Visibility.Hidden)
        .transition(TransitionEffect.translate({ y: 100 }).animation({ curve: Curve.Ease, duration: 600 }))
      }

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Transparent)
        .visibility(this.showLibrary === true ? Visibility.Visible : Visibility.None)
    }
    .width("100%")
    .height('100%')
    .onKeyEvent((event?: KeyEvent) => {
      if (event && event.keyCode === KeyCode.KEYCODE_SPACE && event.type === KeyType.Up) {
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
      }
    })
  }
}