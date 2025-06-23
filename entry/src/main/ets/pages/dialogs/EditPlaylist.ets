import { deletePlaylist, getPlaylist, getPlaylists, updatePlaylist } from '../../utils/Api'
import { Playlist } from '../../utils/Interface'
import { promptAction } from '@kit.ArkUI'

@CustomDialog
export default struct editPlaylistBuilder {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume playlist: Playlist | undefined
  @Consume playlists: Playlist[]
  @Consume pageStack: NavPathStack
  @State name: string = this.playlist!.name
  @State comment: string = this.playlist!.comment
  editPlaylist: CustomDialogController = new CustomDialogController({
    builder: editPlaylistBuilder({})
  })

  build() {
    Column() {
      Text("编辑歌单")
        .width('100%')
        .height(60)
        .textAlign(TextAlign.Center)
        .fontSize(20)
        .fontColor($r('app.color.font'))
        .fontWeight(FontWeight.Bold)

      Row() {
        Text("名称")
          .fontSize(20)
          .fontColor($r('app.color.font'))
        TextInput({
          placeholder: '歌单名称',
          text: $$this.name
        })
          .width("100%")
          .height(40)
          .layoutWeight(1)
          .borderRadius(10)
          .margin({ left: 15 })
          .caretColor($r('app.color.font_secondary'))
          .fontColor($r('app.color.font'))
          .fontSize(20)
          .placeholderFont({
            size: 20
          })
          .enterKeyType(EnterKeyType.Next)
      }
      .width('100%')
      .margin({ bottom: 20 })

      Row() {
        Text("注释")
          .fontSize(20)
          .fontColor($r('app.color.font'))
          .margin({ top: 5 })
        TextArea({
          placeholder: '歌单注释',
          text: $$this.comment
        })
          .width("100%")
          .height(100)
          .layoutWeight(1)
          .borderRadius(10)
          .margin({ left: 15 })
          .caretColor($r('app.color.font_secondary'))
          .fontColor($r('app.color.font'))
          .fontSize(20)
          .placeholderFont({
            size: 20
          })
          .enterKeyType(EnterKeyType.Next)
      }
      .width('100%')
      .margin({ bottom: 20 })
      .alignItems(VerticalAlign.Top)

      Row() {
        Button({ type: ButtonType.Normal }) {
          Text("确认")
            .fontSize(20)
            .fontColor($r('app.color.font'))
        }
        .width('47%')
        .height(50)
        .borderRadius(10)
        .backgroundColor($r('app.color.bar_background'))
        .onClick(async () => {
          this.editPlaylist.close()
          let success = await updatePlaylist(this.baseURL, this.username, this.password, this.playlist!.id, this.name, this.comment)
          if (success === true) {
            promptAction.showToast({
              message: '修改成功！',
              duration: 500
            });
            this.playlist = await getPlaylist(this.baseURL, this.username, this.password, this.playlist!.id)
            this.playlists = (await getPlaylists(this.baseURL, this.username, this.password)).sort((a, b) => {
              return Date.parse(b.changed) - Date.parse(a.changed);
            })
          } else {
            promptAction.showToast({
              message: '修改失败，请检查网络！',
              duration: 500
            });
          }
        })

        Button({ type: ButtonType.Normal }) {
          Text("删除")
            .fontSize(20)
            .fontColor($r('app.color.font'))
        }
        .width('47%')
        .height(50)
        .borderRadius(10)
        .backgroundColor(Color.Red)
        .onClick(async () => {
          this.editPlaylist.close()
          let success = await deletePlaylist(this.baseURL, this.username, this.password, this.playlist!.id)
          if (success === true) {
            promptAction.showToast({
              message: '删除成功！',
              duration: 500
            });
            this.playlists = (await getPlaylists(this.baseURL, this.username, this.password)).sort((a, b) => {
              return Date.parse(b.changed) - Date.parse(a.changed);
            })
            this.pageStack.pop()
          } else {
            promptAction.showToast({
              message: '删除失败，请检查网络！',
              duration: 500
            });
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .padding({ left: 20, right: 20 })
  }
}