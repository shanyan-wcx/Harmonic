import { getPlaylist, getPlaylists, updatePlaylist } from '../../utils/Api'
import { Playlist, Song } from '../../utils/Interface'
import { promptAction } from '@kit.ArkUI'

@CustomDialog
export default struct selectPlaylistBuilder {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume playlists: Playlist[]
  @Consume nowPlayingSong: Song | null
  @Consume selectedPlaylists: boolean[]
  @Consume showPlay: boolean
  @Consume longPressSong: Song | null
  @Consume playlist: Playlist | null
  selectPlaylist: CustomDialogController = new CustomDialogController({
    builder: selectPlaylistBuilder({})
  })

  aboutToAppear() {
    this.selectedPlaylists = []
    for (let playlist of this.playlists) {
      this.selectedPlaylists.push(false)
    }
  }

  build() {
    Column() {
      Text("添加到歌单")
        .width('100%')
        .height(60)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontColor($r('app.color.font'))
        .fontWeight(FontWeight.Bold)

      Divider()
        .width('90%')
        .height(1)
        .color($r('app.color.divider'))

      List() {
        ForEach(this.playlists, (playlist: Playlist, index) => {
          ListItem() {
            Row() {
              Text(playlist.name)
                .width('100%')
                .layoutWeight(1)
                .fontSize(20)
                .margin({ right: 15 })
                .fontColor($r('app.color.font'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Radio({ value: playlist.id, group: playlist.id })
                .width(22)
                .checked(this.selectedPlaylists[index])
                .radioStyle({
                  checkedBackgroundColor: $r('app.color.radio')
                })
                .onClick(() => {
                  this.selectedPlaylists[index] = !this.selectedPlaylists[index]
                })
            }
            .width('100%')
            .height(50)
            .borderRadius(10)
            .padding({ left: 20, right: 15 })
            .justifyContent(FlexAlign.SpaceBetween)
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
        Button({ type: ButtonType.Normal }) {
          Text("确认")
            .fontSize(20)
            .fontColor($r('app.color.font'))
        }
        .width('90%')
        .height(50)
        .borderRadius(15)
        .backgroundColor($r('app.color.content_background'))
        .onClick(async () => {
          this.selectPlaylist.close()
          let success: boolean = true
          for (let index = 0; index < this.selectedPlaylists.length; index++) {
            if (this.selectedPlaylists[index] === true) {
              let tmp: boolean = await updatePlaylist(this.baseURL, this.username, this.password, this.playlists[index].id, undefined, undefined,
                this.showPlay === true ? this.nowPlayingSong!.id : this.longPressSong!.id)
              if (tmp === false) {
                success = false
              }
            }
          }
          if (success === true) {
            promptAction.showToast({
              message: '添加成功！',
              duration: 500
            });
          } else {
            promptAction.showToast({
              message: '部分添加失败，请检查网络！',
              duration: 500
            });
          }
          if (this.playlist !== null) {
            this.playlist = await getPlaylist(this.baseURL, this.username, this.password, this.playlist!.id)
          }
          this.playlists = (await getPlaylists(this.baseURL, this.username, this.password)).sort((a, b) => {
            return Date.parse(b.changed) - Date.parse(a.changed);
          })
        })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bar_background'))
  }
}