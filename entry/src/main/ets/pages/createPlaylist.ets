import { createPlaylist, deletePlaylist, getPlaylist, getPlaylists, updatePlaylist } from '../utils/Api'
import { Playlist } from '../utils/Interface'
import { promptAction } from '@kit.ArkUI'

@CustomDialog
export default struct createPlaylistBuilder {
  @Consume playlists: Playlist[]
  @State name: string = ''
  @State comment: string = ''
  createPlaylist: CustomDialogController = new CustomDialogController({
    builder: createPlaylistBuilder({})
  })

  build() {
    Column() {
      Text("新建歌单")
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
          .borderRadius(15)
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
          .borderRadius(15)
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

      Button({ type: ButtonType.Normal }) {
        Text("确认")
          .fontSize(20)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(50)
      .borderRadius(15)
      .backgroundColor($r('app.color.content_background'))
      .onClick(async () => {
        if(this.name!==''){
          this.createPlaylist.close()
          let success = await createPlaylist(this.name, this.comment)
          if (success === true) {
            promptAction.showToast({
              message: '新建成功！',
              duration: 500
            });
            this.playlists = (await getPlaylists()).sort((a, b) => {
              return Date.parse(b.changed) - Date.parse(a.changed);
            })
          } else {
            promptAction.showToast({
              message: '新建失败，请检查网络！',
              duration: 500
            });
          }
        }else{
          promptAction.showToast({
            message: '歌单名称不能为空！',
            duration: 500
          });
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bar_background'))
    .padding({ left: 20, right: 20 })
  }
}