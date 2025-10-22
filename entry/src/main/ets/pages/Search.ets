import { Album, Artist, Line, MusicFolder, SearchResult, Song, StructuredLyric } from '../utils/Interface';
import { CircleShape } from '@kit.ArkUI';
import { getLyrics, getSong, search, searchAlbums, searchArtists, searchSongs } from '../utils/Api';
import { media } from '@kit.MediaKit';
import { avSession as AVSessionManager } from '@kit.AVSessionKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { ShadowArtistImage, ShadowCoverImage } from '../utils/Component';

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
  @Consume displayWidth: number
  @Consume sidebarType: number
  @Consume sideBarWidth: number
  @Consume needUpdate: boolean
  @Consume showLibrary: boolean
  @Consume searched: boolean
  @Consume musicFolders: MusicFolder[]
  @Consume libraryStates: Record<number, boolean>
  @Consume searchTabIndex: number
  @Consume searchSongsPage: number
  @Consume searchAlbumsPage: number
  @Consume searchArtistsPage: number
  @State searchQuery: string = ''
  @State coverSize: number = 256
  @State profileSize: number = 256
  private searchAlbumsScroller: Scroller = new Scroller
  private searchArtistsScroller: Scroller = new Scroller
  private allScroller: Scroller = new Scroller
  private allSongsScroller: Scroller = new Scroller
  private allAlbumsScroller: Scroller = new Scroller
  private allArtistsScroller: Scroller = new Scroller

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
    this.searchQuery = ''
  }

  @Builder
  tabBuilder(title: string, targetIndex: number) {
    Button({ type: ButtonType.Normal }) {
      Column() {
        Text(title)
          .margin({ top: 3 })
          .fontSize(16)
          .fontColor(this.searchTabIndex === targetIndex ? $r('app.color.font') : $r('app.color.font_secondary'))
          .fontWeight(this.searchTabIndex === targetIndex ? FontWeight.Medium : FontWeight.Normal)
        Divider()
          .color($r('app.color.font'))
          .strokeWidth(2)
          .width(title.length * 16)
          .lineCap(LineCapStyle.Round)
          .visibility(this.searchTabIndex === targetIndex ? Visibility.Visible : Visibility.Hidden)
      }
    }
    .width(this.sidebarType === SideBarContainerType.Overlay ? (this.displayWidth - 40) / 4 :
      (this.displayWidth - this.sideBarWidth - 41) / 4)
    .height(30)
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
    .margin({ bottom: 5 })
    .onClick(() => {
      this.searchTabIndex = targetIndex;
    })
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
          .shadow({
            radius: 6,
            color: $r('sys.color.ohos_id_shadow_default_lg_dark')
          })
          .border({
            width: deviceTypeInfo === '2in1' ? 1 : 0,
            radius: 10,
            color: $r('sys.color.ohos_id_shadow_default_lg_dark')
          })
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
            if (searchContent !== "") {
              this.showProgress = true
              this.searched = false
              this.searchTabIndex = 0
              this.allScroller.scrollEdge(Edge.Top, { velocity: 100000 })
              this.allSongsScroller.scrollEdge(Edge.Top)
              this.allAlbumsScroller.scrollEdge(Edge.Top)
              this.allArtistsScroller.scrollEdge(Edge.Top)
              this.searchAlbumsScroller.scrollToIndex(0, false)
              this.searchArtistsScroller.scrollToIndex(0, false)
              this.searchSongs = [];
              this.searchAlbums = [];
              this.searchArtists = [];
              this.searchQuery = searchContent
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
                    if (searchResult.song !== undefined && searchResult.song.length > 0) {
                      this.searchSongs.unshift(...searchResult.song);
                    }
                    if (searchResult.album !== undefined && searchResult.album.length > 0) {
                      this.searchAlbums.unshift(...searchResult.album);
                    }
                    if (searchResult.artist !== undefined && searchResult.artist.length > 0) {
                      this.searchArtists.unshift(...searchResult.artist);
                    }
                  }
                }
              }
              this.searchSongsPage = 1
              this.searchAlbumsPage = 1
              this.searchArtistsPage = 1
              this.searched = true
              this.showProgress = false
            }
          })
      }
      .padding({ top: 5, bottom: 5 })

      Stack() {
        Tabs({ barPosition: BarPosition.Start, index: $$this.searchTabIndex }) {
          TabContent() {
            Scroll(this.allScroller) {
              Column() {
                Column() {
                  Text("歌曲")
                    .fontSize(20)
                    .fontColor($r('app.color.font'))
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: 13, bottom: 5, left: 20 })
                    .alignSelf(ItemAlign.Start)

                  List() {
                    ForEach(this.searchSongs, (song: Song, index) => {
                      if (index < (this.displayWidth > 1400 ? 3 : (this.displayWidth > 1000 ? 2 : 1)) * 5) {
                        ListItem() {
                          Button({ type: ButtonType.Normal }) {
                            Row() {
                              Column(){
                                ShadowCoverImage({
                                  url: this.baseURL + this.getCoverUrl + this.auth + `&id=${song.id}&size=${this.coverSize}`,
                                  radius: 5
                                })
                              }
                              .width(60)
                              .aspectRatio(1)
                              .justifyContent(FlexAlign.Center)

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
                            this.avPlayer!.url =
                              this.baseURL + '/rest/stream' + this.auth + `&id=${song.id}&format=raw`;
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
                        }
                      }
                    })
                  }
                  .width('100%')
                  .height('auto')
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Vertical)
                  .lanes(this.displayWidth > 1400 ? 3 : (this.displayWidth > 1000 ? 2 : 1))
                  .edgeEffect(EdgeEffect.None)
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
                      if (index < 20) {
                        ListItem() {
                          Button({ type: ButtonType.Normal }) {
                            Column() {
                              Column(){
                                ShadowCoverImage({
                                  url: this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`,
                                  radius: 10
                                })
                              }
                              .height('100%')
                              .layoutWeight(1)
                              .aspectRatio(1)
                              .justifyContent(FlexAlign.Center)

                              Column() {
                                Text(album.title)
                                  .fontSize(17)
                                  .fontWeight(FontWeight.Medium)
                                  .fontColor($r('app.color.font'))
                                  .margin({ top: 5 })
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                                  .wordBreak(WordBreak.BREAK_ALL)
                                Text(album.artist)
                                  .fontSize(14)
                                  .fontColor($r('app.color.font_secondary'))
                                  .maxLines(1)
                                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                                  .wordBreak(WordBreak.BREAK_ALL)
                              }
                              .alignItems(HorizontalAlign.Start)
                              .width(this.displayWidth > 1400 ? 192 : (this.displayWidth > 1200 ? 172 : 152))
                            }
                            .width('auto')
                            .height('100%')
                            .alignItems(HorizontalAlign.Start)
                          }
                          .width('auto')
                          .height('100%')
                          .padding({ left: 10, right: 10, top: 10, bottom: 7 })
                          .margin({
                            left: index === 0 ? 10 : 0,
                            right: index === this.searchAlbums.length - 1 ? 10 : 0
                          })
                          .borderRadius(10)
                          .backgroundColor(Color.Transparent)
                          .onClick(() => {
                            this.album = album
                            this.pageStack.pushPathByName('AlbumDetail', undefined);
                          })
                        }
                      }
                    })
                  }
                  .width('100%')
                  .height('100%')
                  .layoutWeight(1)
                  .listDirection(Axis.Horizontal)
                  .scrollBar(BarState.Off)
                  .edgeEffect(EdgeEffect.Spring)
                }
                .width('100%')
                .height(this.displayWidth > 1400 ? 290 : (this.displayWidth > 1200 ? 270 : 250))
                .padding({ bottom: this.searchArtists.length > 0 ? 0 : 10 })
                .visibility(this.searchAlbums.length > 0 ? Visibility.Visible : Visibility.None)

                Column() {
                  Row() {
                    Text("艺术家")
                      .fontSize(20)
                      .fontColor($r('app.color.font'))
                      .fontWeight(FontWeight.Medium)
                      .margin({ bottom: 5 })

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
                      if (index < 20) {
                        ListItem() {
                          Button({ type: ButtonType.Normal }) {
                            Column() {
                              Column(){
                                ShadowArtistImage({
                                  url: this.baseURL + this.getCoverUrl + this.auth + `&id=${artist.id}&size=${this.profileSize}`
                                })
                              }
                                .width('100%')
                                .layoutWeight(1)
                                .aspectRatio(1)
                                .justifyContent(FlexAlign.Center)
                              Text(artist.name)
                                .width('100%')
                                .fontSize(16)
                                .fontColor($r('app.color.font'))
                                .margin({ top: 10 })
                                .maxLines(1)
                                .textAlign(TextAlign.Center)
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .wordBreak(WordBreak.BREAK_ALL)
                            }
                            .padding(10)
                            .width('100%')
                            .height('auto')
                          }
                          .width(this.displayWidth > 1400 ? 160 : 125)
                          .height('auto')
                          .margin({
                            left: index === 0 ? 10 : 0,
                            right: index === this.searchArtists.length - 1 ? 10 : 0
                          })
                          .borderRadius(10)
                          .backgroundColor(Color.Transparent)
                          .onClick(() => {
                            this.artist = artist
                            this.pageStack.pushPathByName('ArtistDetail', undefined);
                          })
                        }
                      }
                    })
                  }
                  .width('100%')
                  .height('100%')
                  .layoutWeight(1)
                  .listDirection(Axis.Horizontal)
                  .scrollBar(BarState.Off)
                  .edgeEffect(EdgeEffect.Spring)
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
                .visibility(this.searchSongs.length === 0 && this.searchAlbums.length === 0 &&
                  this.searchArtists.length === 0 &&
                  this.showProgress === false ? Visibility.Visible : Visibility.None)
              }
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
            .align(Alignment.Top)
            .padding({ bottom: this.startPlaying === true ? 85 : 0 })
            .visibility(this.searched === true ? Visibility.Visible : Visibility.None)
          }
          .tabBar(this.tabBuilder('综合', 0))

          TabContent() {
            List({ scroller: this.allSongsScroller }) {
              ForEach(this.searchSongs, (song: Song, index) => {
                ListItem() {
                  Button({ type: ButtonType.Normal }) {
                    Row() {
                      Column(){
                        ShadowCoverImage({ url: this.baseURL + this.getCoverUrl + this.auth + `&id=${song.id}&size=${this.coverSize}`,
                          radius: 5
                        })
                      }
                      .width(60)
                      .aspectRatio(1)
                      .justifyContent(FlexAlign.Center)

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
                  .margin({
                    bottom: this.startPlaying
                      ? (index === this.searchSongs.length - 1 ? 95 : 0)
                      : (index === this.searchSongs.length - 1 ? 10 : 0)
                  })
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
                }
              })

              ListItem() {
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
                .visibility(this.searchSongs.length === 0 ? Visibility.Visible : Visibility.None)
              }
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .lanes(this.displayWidth > 1400 ? 3 : (this.displayWidth > 1000 ? 2 : 1))
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
            .visibility(this.searched === true ? Visibility.Visible : Visibility.None)
            .onReachEnd(async () => {
              let size = 500
              let keys = Object.keys(this.libraryStates)
              for (const id of keys) {
                if (this.libraryStates[id] === true) {
                  if (!this.musicFolders.some(item => item.id === Number(id))) {
                    this.libraryStates[id] = false
                    continue;
                  }
                  let pageSongs = await searchSongs(this.baseURL, this.username, this.password, this.searchQuery,
                    this.searchSongsPage * size, Number(id))
                  if (pageSongs === undefined || pageSongs.length === 0) {
                    continue;
                  }
                  this.searchSongs.push(...pageSongs)
                }
              }
              this.searchSongsPage++
            })
          }
          .tabBar(this.tabBuilder('歌曲', 1))

          TabContent() {
            Column() {
              Grid(this.allAlbumsScroller) {
                ForEach(this.searchAlbums, (album: Album, index) => {
                  GridItem() {
                    Button({ type: ButtonType.Normal }) {
                      Column() {
                        Column(){
                          ShadowCoverImage({
                            url: this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`,
                            radius: 10
                          })
                        }
                        .width('100%')
                        .height('auto')
                        .layoutWeight(1)
                        .aspectRatio(1)
                        .justifyContent(FlexAlign.Center)

                        Text(album.title)
                          .fontSize(17)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.font'))
                          .margin({ top: 5 })
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .wordBreak(WordBreak.BREAK_ALL)
                        Text(album.artist)
                          .fontSize(14)
                          .fontColor($r('app.color.font_secondary'))
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .wordBreak(WordBreak.BREAK_ALL)
                      }
                      .width('100%')
                      .height('auto')
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .height('auto')
                    .borderRadius(10)
                    .clip(true)
                    .padding({ left: 10, right: 10, top: 10, bottom: 7 })
                    .margin({ bottom: this.startPlaying === true && index === this.searchAlbums.length - 1 ? 85 : 0 })
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
              .columnsTemplate(this.displayWidth > 1400 ? "1fr 1fr 1fr 1fr 1fr 1fr" :
                (this.displayWidth > 1000 ? "1fr 1fr 1fr 1fr 1fr" :
                  (this.displayWidth > 800 ? "1fr 1fr 1fr 1fr" : (this.displayWidth > 400 ? "1fr 1fr 1fr" : "1fr 1fr"))))
              .columnsGap(0)
              .rowsGap(0)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
              .padding({ left: 10, right: 10, bottom: 10 })
              .onReachEnd(async () => {
                let size = 500
                let keys = Object.keys(this.libraryStates)
                for (const id of keys) {
                  if (this.libraryStates[id] === true) {
                    if (!this.musicFolders.some(item => item.id === Number(id))) {
                      this.libraryStates[id] = false
                      continue;
                    }
                    let pageAlbums =
                      await searchAlbums(this.baseURL, this.username, this.password, this.searchQuery, this.searchAlbumsPage * size, Number(id))
                    if (pageAlbums === undefined || pageAlbums.length === 0) {
                      continue;
                    }
                    this.searchAlbums.push(...pageAlbums)
                  }
                }
                this.searchAlbumsPage++
              })
              .visibility(this.searchAlbums.length > 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)

              Column() {
                Text("没有结果")
                  .fontSize(32)
                  .fontColor($r('app.color.font'))
              }
              .width('100%')
              .height('100%')
              .padding({ bottom: 160 })
              .justifyContent(FlexAlign.Center)
              .visibility(this.searchAlbums.length === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.tabBuilder('专辑', 2))

          TabContent() {
            Column() {
              Grid(this.allArtistsScroller) {
                ForEach(this.searchArtists, (artist: Artist, index) => {
                  GridItem() {
                    Button({ type: ButtonType.Normal }) {
                      Column() {
                        Column(){
                          ShadowArtistImage({
                            url: this.baseURL + this.getCoverUrl + this.auth + `&id=${artist.id}&size=${this.profileSize}`
                          })
                        }
                          .width('100%')
                          .aspectRatio(1)
                          .justifyContent(FlexAlign.Center)
                        Text(artist.name)
                          .width('100%')
                          .fontSize(16)
                          .fontColor($r('app.color.font'))
                          .margin({ top: 10 })
                          .maxLines(1)
                          .textAlign(TextAlign.Center)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .wordBreak(WordBreak.BREAK_ALL)
                      }
                      .padding(10)
                      .width('100%')
                      .height('auto')
                    }
                    .width('100%')
                    .height('auto')
                    .margin({ bottom: this.startPlaying === true && index === this.searchArtists.length - 1 ? 85 : 0 })
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
              .columnsTemplate(this.displayWidth > 1400 ? "1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr" :
                (this.displayWidth > 1200 ? "1fr 1fr 1fr 1fr 1fr 1fr 1fr" :
                  (this.displayWidth > 1000 ? "1fr 1fr 1fr 1fr 1fr 1fr" : (this.displayWidth > 800 ? "1fr 1fr 1fr 1fr 1fr" :
                    (this.displayWidth > 400 ? "1fr 1fr 1fr 1fr" : "1fr 1fr 1fr")))))
              .columnsGap(0)
              .rowsGap(0)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Fade, { alwaysEnabled: false })
              .padding({ left: 10, right: 10, bottom: 10 })
              .onReachEnd(async () => {
                let size = 500
                let keys = Object.keys(this.libraryStates)
                for (const id of keys) {
                  if (this.libraryStates[id] === true) {
                    if (!this.musicFolders.some(item => item.id === Number(id))) {
                      this.libraryStates[id] = false
                      continue;
                    }
                    let pageArtists =
                      await searchArtists(this.baseURL, this.username, this.password, this.searchQuery, this.searchArtistsPage * size, Number(id))
                    if (pageArtists === undefined || pageArtists.length === 0) {
                      continue;
                    }
                    this.searchArtists.push(...pageArtists)
                  }
                }
                this.searchArtistsPage++
              })
              .visibility(this.searchArtists.length > 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)

              Column() {
                Text("没有结果")
                  .fontSize(32)
                  .fontColor($r('app.color.font'))
              }
              .width('100%')
              .height('100%')
              .padding({ bottom: 160 })
              .justifyContent(FlexAlign.Center)
              .visibility(this.searchArtists.length === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.tabBuilder('艺术家', 3))
        }
        .height('100%')
        .scrollable(false)
        .animationMode(AnimationMode.NO_ANIMATION)
        .barHeight(35)
        .barMode(BarMode.Scrollable, {
          margin: 20,
          nonScrollableLayoutStyle: LayoutStyle.ALWAYS_AVERAGE_SPLIT
        })
        .visibility(this.searched === true ? Visibility.Visible : Visibility.Hidden)

        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.totop'))
            .width(20)
            .aspectRatio(1)
            .draggable(false)
        }
        .position({
          right: 15,
          bottom: this.startPlaying ? 100 : 15
        })
        .animation({ duration: 510, curve: Curve.EaseInOut })
        .width(36)
        .height(36)
        .borderRadius(6)
        .backgroundColor(Color.Transparent)
        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
        .shadow({
          radius: 12,
          color: $r('sys.color.ohos_id_shadow_default_lg_dark'),
        })
        .onClick(async () => {
          switch (this.searchTabIndex) {
            case 0:
              this.allScroller.scrollEdge(Edge.Top, { velocity: 100000 })
              break
            case 1:
              this.allSongsScroller.scrollEdge(Edge.Top)
              break
            case 2:
              this.allAlbumsScroller.scrollEdge(Edge.Top)
              break
            case 3:
              this.allArtistsScroller.scrollEdge(Edge.Top)
              break
            default:
              break
          }
        })
        .visibility(this.searched === true ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}