import { getPlaylists } from '../utils/Api'
import { Playlist } from '../utils/Interface'
import createPlaylistBuilder from './dialogs/CreatePlaylist'
import { deviceInfo } from '@kit.BasicServicesKit';

let deviceTypeInfo: string = deviceInfo.deviceType;

@Component
export default struct Playlists {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume playlists: Playlist[]
  @Consume playlist: Playlist | undefined
  @Consume showProgress: boolean
  @Consume showLibrary: boolean
  createPlaylist: CustomDialogController = new CustomDialogController({
    builder: createPlaylistBuilder(),
    width: 350,
    height: 310,
    backgroundColor: $r('app.color.start_window_background')
  })

  async aboutToAppear() {
    this.showProgress = true
    this.playlists = (await getPlaylists(this.baseURL, this.username, this.password)).sort((a, b) => {
      return Date.parse(b.changed) - Date.parse(a.changed);
    })
    this.showProgress = false
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text("新建歌单")
            .fontSize(20)
            .fontColor($r('app.color.font'))
        }
        .width('90%')
        .height(50)
        .borderRadius(10)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .shadow({
          radius: 6,
          color: $r('sys.color.ohos_id_shadow_default_lg_dark')
        })
        .border({
          width: deviceTypeInfo === '2in1' ? 1 : 0,
          radius: 10,
          color: $r('sys.color.ohos_id_shadow_default_lg_dark')
        })
        .onClick(() => {
          this.createPlaylist.open()
        })
      }
      .width('100%')
      .height(60)
      .margin({ bottom: 10 })
      .justifyContent(FlexAlign.Center)

      Divider()
        .width('90%')
        .height(1)
        .color($r('app.color.divider'))

      List() {
        ForEach(this.playlists, (playlist: Playlist, index) => {
          ListItem() {
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text(playlist.name)
                  .fontSize(19)
                  .fontColor($r('app.color.font'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .height('100%')
              .padding({ left: 20, right: 20 })
            }
            .width('90%')
            .height(60)
            .borderRadius(10)
            .backgroundColor(Color.Transparent)
            .padding({ left: 20, right: 20 })
            .margin({
              bottom: this.startPlaying
                ? (index === this.playlists.length - 1 ? 95 : 0)
                : (index === this.playlists.length - 1 ? 10 : 0)
            })
            .onClick(() => {
              this.playlist = playlist
              this.pageStack.pushPathByName('PlaylistDetail', undefined);
            })
          }
        })
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade, {alwaysEnabled: false})
      .visibility(this.playlists.length > 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)

      Column() {
        Text("没有歌单")
          .fontSize(32)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 140 })
      .justifyContent(FlexAlign.Center)
      .visibility(this.playlists.length === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}