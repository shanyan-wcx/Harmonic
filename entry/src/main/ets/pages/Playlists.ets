import { Playlist } from '../utils/Interface'
import createPlaylistBuilder from './createPlaylist'

@Component
export default struct Playlists {
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume playlists: Playlist[]
  @Consume playlist: Playlist | null
  createPlaylist: CustomDialogController = new CustomDialogController({
    builder: createPlaylistBuilder(),
    width: 340,
    height: 310,
    backgroundColor: $r('app.color.content_background')
  })

  build() {
    Column() {
      Row() {
        Image("")
        Text("歌单")
          .fontSize(20)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(60)
      .backgroundColor($r('app.color.bar_background'))
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
            .width('100%')
            .height(50)
            .borderRadius(15)
            .backgroundColor('#00000000')
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              animateTo({
                duration: 300,
                curve: Curve.EaseOut,
              }, () => {
                this.showSidebar = false
              })
              this.playlist = playlist
              this.pageStack.pushPathByName('PlaylistDetail', null);
            })
          }
        })
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .visibility(this.playlists.length > 0 ? Visibility.Visible : Visibility.None)

      Column() {
        Text("没有歌单")
          .fontSize(19)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .visibility(this.playlists.length > 0 ? Visibility.None : Visibility.Visible)

      Divider()
        .width('90%')
        .height(1)
        .color($r('app.color.divider'))

      Row() {
        Button({type:ButtonType.Normal}) {
          Text("新建")
            .fontSize(20)
            .fontColor($r('app.color.font'))
        }
        .width('90%')
        .height(50)
        .borderRadius(15)
        .backgroundColor($r('app.color.content_background'))
        .onClick(() => {
          animateTo({
            duration: 300,
            curve: Curve.EaseOut,
          }, () => {
            this.showSidebar = false
          })
          this.createPlaylist.open()
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor($r('app.color.bar_background'))
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}