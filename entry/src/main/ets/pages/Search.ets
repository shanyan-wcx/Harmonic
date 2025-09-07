import { Album, Artist, Line, MusicFolder, SearchResult, Song, StructuredLyric } from '../utils/Interface';
import { curves } from '@kit.ArkUI';
import { getLyrics, getSong, search } from '../utils/Api';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { PromptAction } from '@kit.ArkUI';

let deviceTypeInfo: string = deviceInfo.deviceType;

@Component
export default struct Search_ {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @Consume searchSongs: Song[]
  @Consume searchAlbums: Album[]
  @Consume searchArtists: Artist[]
  @Consume artist: Artist | undefined
  @Consume album: Album
  @Consume nowPlayingSong: Song | undefined
  @Consume nowPlayingLyrics: StructuredLyric | undefined
  @Consume nowPlayingLyricsByGroup: Line[][]
  @Consume nowPlayingList: Song[]
  @Consume nowPlayingListOriginal: Song[]
  @Consume nowPlayingIndex: number
  @Consume isPlaying: boolean
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume serverStatus: boolean
  @Consume showMenu: boolean
  @Consume longPressSong: Song | undefined
  @Consume sleepTime: number
  @Consume selectedIndex: number
  @Consume showProgress: boolean
  @Consume avPlayer: media.AVPlayer | undefined
  @Consume pageStack: NavPathStack
  @StorageLink('playMode') playMode: number = 0
  @Consume session: AVSessionManager.AVSession | undefined
  @State coverSize: number = 256
  @State profileSize: number = 256
  @Consume displayWidth: number
  @Consume sidebarType: number
  @Consume needUpdate: boolean
  @Consume showLibrary: boolean
  @Consume musicFolders: MusicFolder[]
  @Consume libraryStates: Record<number, boolean>
  private searchAlbumsScroller: Scroller = new Scroller
  private searchArtistsScroller: Scroller = new Scroller
  private  promptAction: PromptAction | null = null;
  @State searchContent: string = ""

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
    this.needUpdate = !this.needUpdate
    this.promptAction = this.getUIContext().getPromptAction();
  }

  build() {
    Column() {
      Row() {
        Search()
          .width("100%")
          .height(this.displayWidth > 1400 ? 50 : 40)
          .layoutWeight(1)
          .borderRadius(10)
          .margin({ left: 20, right: 20 })
          .searchIcon({
            size: 0
          })
          .searchButton("搜索", {
            fontSize: this.displayWidth > 1400 ? 20 : 18,
            fontColor: $r('app.color.font'),
            autoDisable: true
          })
          .placeholderColor($r('app.color.font_secondary'))
          .placeholderFont({
            size: this.displayWidth > 1400 ? 22 : 20
          })
          .fontColor($r('app.color.font'))
          .textFont({
            size: this.displayWidth > 1400 ? 22 : 20
          })
          .caretStyle({
            color: $r('app.color.font_secondary')
          })
          .enterKeyType(EnterKeyType.Search)
          .onSubmit(async (searchContent: string, event: SubmitEvent) => {
            if(searchContent !== "") {
              this.searchContent = searchContent;
              this.showProgress = true;
              this.searchSongs = [];
              this.searchAlbums = [];
              this.searchArtists = [];
              let keys = Object.keys(this.libraryStates)
              for (const id of keys) {
                if (this.libraryStates[id] === true) {
                  if (!this.musicFolders.some(item => item.id === Number(id))) {
                    this.libraryStates[id] = false
                    continue;
                  }
                  let searchResult: SearchResult | undefined =
                    await search(this.baseURL, this.username, this.password, searchContent, Number(id))
                  if (searchResult !== undefined) {
                    if (searchResult.song !== undefined) {
                      this.searchSongs.push(...searchResult.song);
                    }
                    if (searchResult.album !== undefined) {
                      this.searchAlbums.push(...searchResult.album);
                    }
                    if (searchResult.artist !== undefined) {
                      this.searchArtists.push(...searchResult.artist);
                    }
                  }
                }
              }
              this.showProgress = false;
            }
          })
      }
      .padding({bottom: 15})

      Scroll() {
        Column() {
          Column() {
            Text("歌曲")
              .width('100%')
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: 15, bottom: 5 })
              .padding({ left: 20 })
              .textAlign(TextAlign.Start)

            ForEach(this.searchSongs, (song: Song, index) => {
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
              .backgroundColor(Color.Transparent)
              .padding({ left: 20, right: 20 })
              .animation({ curve: curves.springMotion(0.6, 1) })
              .onClick(async () => {
                this.startPlaying = true
                await this.avPlayer!.reset()
                this.isPlaying = true
                this.nowPlayingSong = song
                this.nowPlayingLyrics = await getLyrics(this.baseURL, this.username, this.password, song.id)
                if (this.nowPlayingLyrics !== undefined) {
                  this.groupLyrics()
                }
                this.nowPlayingListOriginal = this.searchSongs.slice()
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
            Row(){
              Blank()
              Button("显示更多")
                .align(Alignment.End)
                .onClick(async ()=>{
                  if (this.searchContent.length === 0) {
                    return;
                  }
                  this.showProgress = true;
                  let keys = Object.keys(this.libraryStates)
                  for (const id of keys) {
                    if (this.libraryStates[id] === true) {
                      if (!this.musicFolders.some(item => item.id === Number(id))) {
                        this.libraryStates[id] = false
                        continue;
                      }
                      let searchResult: SearchResult | undefined = await search(
                        this.baseURL,
                        this.username,
                        this.password,
                        this.searchContent,
                        Number(id),
                        {songOffset: this.searchSongs.length, albumCount: 0, artistCount: 0}

                      )
                      // console.info(`search result: ${JSON.stringify(searchResult)}`)
                      let hasData = false;
                      if (searchResult !== undefined) {
                        if (searchResult.song !== undefined) {
                          if (searchResult.song.length > 0) {
                            hasData = true;
                            this.searchSongs.push(...searchResult.song);
                          }
                        }
                      }
                      if (!hasData) {
                        try {
                          this.promptAction?.showToast({message: "没有更多歌曲了"});
                        } catch (e) {
                          console.error(`showToast error: ${e}}`)
                        }
                      }
                    }
                  }
                  this.showProgress = false;
                })
            }.width("100%")
          }
          .width('100%')
          .padding({ bottom: this.searchAlbums.length > 0 ? 0 : 10 })
          .visibility(this.searchSongs.length > 0 ? Visibility.Visible : Visibility.None)

          Column() {
            Row() {
              Text("专辑")
                .fontSize(20)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 5 })
                .textAlign(TextAlign.Start)

              Row() {
                Button({ type: ButtonType.Normal }) {
                  SymbolGlyph($r('sys.symbol.chevron_left'))
                    .fontSize(28)
                    .fontColor([$r('app.color.font')])
                }
                .width(30)
                .height(30)
                .borderRadius(5)
                .backgroundColor(Color.Transparent)
                .margin({ right: 10 })
                .onClick(() => {
                  this.searchAlbumsScroller.scrollPage({
                    next: false,
                    animation: true
                  })
                })

                Button({ type: ButtonType.Normal }) {
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(28)
                    .fontColor([$r('app.color.font')])
                }
                .width(30)
                .height(30)
                .borderRadius(5)
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.searchAlbumsScroller.scrollPage({
                    next: true,
                    animation: true
                  })
                })
              }
              .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .margin({ top: 10 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Bottom)

            List({ scroller: this.searchAlbumsScroller }) {
              ForEach(this.searchAlbums, (album: Album, index) => {
                ListItem() {
                  Button({ type: ButtonType.Normal }) {
                    Column() {
                      Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`)
                        .alt($rawfile('nocover.png'))
                        .objectFit(ImageFit.Contain)
                        .height('100%')
                        .aspectRatio(1)
                        .borderRadius(10)
                        .margin(10)
                    }
                    .width('auto')
                    .height('100%')
                  }
                  .width('auto')
                  .height('100%')
                  .margin({ left: index === 0 ? 10 : 0, right: index === this.searchAlbums.length - 1 ? 10 : 0 })
                  .animation({ curve: curves.springMotion(0.6, 1) })
                  .borderRadius(10)
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.album = album
                    this.pageStack.pushPathByName('AlbumDetail', undefined);
                  })
                }
              })
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .onReachEnd(async()=>{
              if (this.searchContent.length === 0) {
                return;
              }
              this.showProgress = true;
              let keys = Object.keys(this.libraryStates)
              for (const id of keys) {
                if (this.libraryStates[id] === true) {
                  if (!this.musicFolders.some(item => item.id === Number(id))) {
                    this.libraryStates[id] = false
                    continue;
                  }
                  let searchResult: SearchResult | undefined = await search(
                    this.baseURL,
                    this.username,
                    this.password,
                    this.searchContent,
                    Number(id),
                    {albumOffset: this.searchAlbums.length, songCount: 0, artistCount: 0}
                  )
                  if (searchResult !== undefined) {
                    if (searchResult.album !== undefined) {
                      if (searchResult.album.length > 0) {
                        this.searchAlbums.push(...searchResult.album);
                      }
                    }
                  }
                }
              }
              this.showProgress = false;
            })
          }
          .width('100%')
          .height(this.displayWidth > 1400 ? 250 : 210)
          .padding({ bottom: this.searchArtists.length > 0 ? 0 : 10 })
          .visibility(this.searchAlbums.length > 0 ? Visibility.Visible : Visibility.None)

          Column() {
            Row() {
              Text("艺术家")
                .fontSize(20)
                .fontColor($r('app.color.font'))
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 5 })
                .textAlign(TextAlign.Start)

              Row() {
                Button({ type: ButtonType.Normal }) {
                  SymbolGlyph($r('sys.symbol.chevron_left'))
                    .fontSize(28)
                    .fontColor([$r('app.color.font')])
                }
                .width(30)
                .height(30)
                .borderRadius(5)
                .backgroundColor(Color.Transparent)
                .margin({ right: 10 })
                .onClick(() => {
                  this.searchArtistsScroller.scrollPage({
                    next: false,
                    animation: true
                  })
                })

                Button({ type: ButtonType.Normal }) {
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(28)
                    .fontColor([$r('app.color.font')])
                }
                .width(30)
                .height(30)
                .borderRadius(5)
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.searchArtistsScroller.scrollPage({
                    next: true,
                    animation: true
                  })
                })
              }
              .visibility(deviceTypeInfo === '2in1' ? Visibility.Visible : Visibility.None)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .margin({ top: 10 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Bottom)

            List({ scroller: this.searchArtistsScroller }) {
              ForEach(this.searchArtists, (artist: Artist, index) => {
                ListItem() {
                  Button({ type: ButtonType.Normal }) {
                    Column() {
                      Image(this.baseURL + this.getCoverUrl + this.auth + `&id=${artist.id}&size=${this.profileSize}`)
                        .alt($rawfile('noprofile.jpg'))
                        .objectFit(ImageFit.Cover)
                        .height('100%')
                        .layoutWeight(1)
                        .aspectRatio(1)
                        .borderRadius(100)
                        .margin(10)
                      Text(artist.name)
                        .width('100%')
                        .fontSize(16)
                        .fontColor($r('app.color.font'))
                        .margin({ bottom: 10, left: 10, right: 10 })
                        .maxLines(1)
                        .textAlign(TextAlign.Center)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('100%')
                    .height('100%')
                  }
                  .width(this.displayWidth > 1400 ? 160 : 124)
                  .height('100%')
                  .margin({ left: index === 0 ? 10 : 0, right: index === this.searchArtists.length - 1 ? 10 : 0 })
                  .animation({ curve: curves.springMotion(0.6, 1) })
                  .borderRadius(10)
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.artist = artist
                    this.pageStack.pushPathByName('ArtistDetail', undefined);
                  })
                }
              })
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .listDirection(Axis.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .onReachEnd(async ()=>{
              if (this.searchContent.length === 0) {
                return;
              }
              this.showProgress = true;
              let keys = Object.keys(this.libraryStates)
              for (const id of keys) {
                if (this.libraryStates[id] === true) {
                  if (!this.musicFolders.some(item => item.id === Number(id))) {
                    this.libraryStates[id] = false
                    continue;
                  }
                  let searchResult: SearchResult | undefined = await search(
                    this.baseURL,
                    this.username,
                    this.password,
                    this.searchContent,
                    Number(id),
                    {artistOffset: this.searchArtists.length, songCount: 0, albumCount: 0}
                  )
                  if (searchResult !== undefined) {
                    if (searchResult.artist !== undefined) {
                      if (searchResult.artist.length > 0) {
                        this.searchArtists.push(...searchResult.artist)
                      }
                    }
                  }
                }
              }
              this.showProgress = false;
            })
          }
          .width('100%')
          .height(this.displayWidth > 1400 ? 240 : 205)
          .padding({ bottom: 10 })
          .visibility(this.searchArtists.length > 0 ? Visibility.Visible : Visibility.None)

          Column() {
            Text("没有结果")
              .fontSize(32)
              .fontColor($r('app.color.font'))
          }
          .width('100%')
          .height('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .padding({ bottom: 160 })
          .visibility(this.searchSongs.length === 0 && this.searchAlbums.length === 0 && this.searchArtists.length === 0 &&
            this.showProgress === false ? Visibility.Visible : Visibility.None)
        }
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade, {alwaysEnabled: false})
      .align(Alignment.Top)
      .margin({bottom: this.startPlaying === true ? 85 : 0})
    }
    .width('100%')
    .height('100%')
  }
}