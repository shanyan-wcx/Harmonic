import { ping } from "../../utils/Api"
import { deviceInfo } from "@kit.BasicServicesKit";

let deviceTypeInfo: string = deviceInfo.deviceType;

@CustomDialog
export default struct editServerBuilder {
  @StorageLink('servernames') servernames: string[] = []
  @StorageLink('baseurls') baseurls: string[] = []
  @StorageLink('usernames') usernames: string[] = []
  @StorageLink('passwords') passwords: string[] = []
  @StorageLink('server') serverIdx: number = -1
  @State tmpServername: string = ""
  @State tmpBaseurl: string = ""
  @State tmpUrl: string = ""
  @State tmpUsername: string = ""
  @State tmpPassword: string = ""
  @State urlHead: string[] = ["http://", "https://"]
  @State urlHeadIdx: number = 0
  @Consume editServerIdx: number
  createEditServer: CustomDialogController = new CustomDialogController({
    builder: editServerBuilder({})
  })

  build() {
    Column() {
      Text("编辑服务器")
        .width('100%')
        .fontSize(20)
        .fontColor($r('app.color.font'))
        .fontWeight(FontWeight.Bold)
        .padding({ left: 20, right: 20 })
        .margin({ top: 20 })
        .textAlign(TextAlign.Center)
      Row() {
        Text("名称")
          .width(60)
          .fontSize(20)
          .fontColor($r('app.color.font'))
        TextInput({
          placeholder: '服务器名称',
          text: this.servernames.length > this.editServerIdx ? this.servernames[this.editServerIdx] : ""
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
          .type(InputType.Normal)
          .enterKeyType(EnterKeyType.Next)
          .onChange((value) => {
            this.tmpServername = value
          })
      }
      .width('100%')
      .margin({ top: 20 })

      Row() {
        Text("服务器")
          .width(60)
          .fontSize(20)
          .fontColor($r('app.color.font'))
        Select([{ value: this.urlHead[0] }, { value: this.urlHead[1] }])
          .value(this.urlHead[0])
          .selected(0)
          .zIndex(999)
          .onSelect((index) => {
            this.urlHeadIdx = index
          })
          .font({
            size: 20
          })
          .fontColor($r('app.color.font'))
          .height(40)
          .borderRadius(10)
          .margin({ left: 15 })
          .controlSize(ControlSize.SMALL)
          .optionWidth(80)
          .optionFontColor($r('app.color.font'))
          .selectedOptionFontColor($r('app.color.font'))
          .selectedOptionBgColor($r('app.color.button_selected'))
          .menuBackgroundColor($r('app.color.content_background'))
          .menuBackgroundBlurStyle(BlurStyle.NONE)
          .backgroundColor($r('app.color.textInput'))
        TextInput({
          placeholder: 'myserver.com',
          text: this.baseurls.length > this.editServerIdx && this.editServerIdx !== -1 ? this.baseurls[this.editServerIdx].replace(/^https?:\/\//, "") : ""
        })
          .width("100%")
          .height(40)
          .offset({
            x: -20
          })
          .padding({ left: 22 })
          .margin({ right: -15 })
          .layoutWeight(1)
          .borderRadius(10)
          .caretColor($r('app.color.font_secondary'))
          .fontColor($r('app.color.font'))
          .fontSize(20)
          .placeholderFont({
            size: 20
          })
          .backgroundColor($r('app.color.textInput'))
          .type(InputType.URL)
          .enterKeyType(EnterKeyType.Next)
          .onChange((value) => {
            this.tmpUrl = value
          })
      }
      .width('100%')
      .margin({ top: 20 })

      Row() {
        Text("账号")
          .width(60)
          .fontSize(20)
          .fontColor($r('app.color.font'))
        TextInput({
          placeholder: 'username',
          text: this.usernames.length > this.editServerIdx ? this.usernames[this.editServerIdx] : ""
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
          .type(InputType.USER_NAME)
          .enterKeyType(EnterKeyType.Next)
          .onChange((value) => {
            this.tmpUsername = value
          })
      }
      .width('100%')
      .margin({ top: 20 })

      Row() {
        Text("密码")
          .width(60)
          .fontSize(20)
          .fontColor($r('app.color.font'))
        TextInput({
          placeholder: 'password',
          text: this.passwords.length > this.editServerIdx ? this.passwords[this.editServerIdx] : ""
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
          .type(InputType.Password)
          .enterKeyType(EnterKeyType.Next)
          .onChange((value) => {
            this.tmpPassword = value
          })
      }
      .width('100%')
      .margin({ top: 20, bottom: 20 })

      Row() {
        Button({ type: ButtonType.Normal }) {
          Text("保存")
            .fontSize(20)
            .fontColor($r('app.color.font'))
        }
        .width('47%')
        .height(50)
        .borderRadius(10)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .border({
          width: deviceTypeInfo === '2in1' ? 1 : 0,
          radius: 10,
          color: $r('sys.color.ohos_id_shadow_default_lg_dark')
        })
        .shadow({
          radius: 6,
          color: $r('sys.color.ohos_id_shadow_default_lg_dark')
        })
        .onClick(async () => {
          if (this.tmpUrl === "") {
            this.getUIContext().getPromptAction().showToast({
              message: '服务器地址不能为空！',
              duration: 500
            });
          } else {
            this.tmpBaseurl = this.urlHead[this.urlHeadIdx] + this.tmpUrl
            let status = await ping(this.tmpBaseurl, this.tmpUsername, this.tmpPassword)
            if (status === 'ok') {
              this.servernames[this.editServerIdx] = this.tmpServername
              this.baseurls[this.editServerIdx] = this.tmpBaseurl
              this.usernames[this.editServerIdx] = this.tmpUsername
              this.passwords[this.editServerIdx] = this.tmpPassword
              this.createEditServer.close()
              this.getUIContext().getPromptAction().showToast({
                message: '编辑服务器成功！',
                duration: 500
              });
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: '连接服务器失败！',
                duration: 500
              });
            }
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
        .backgroundColor($r('sys.color.warning'))
        .border({
          width: deviceTypeInfo === '2in1' ? 1 : 0,
          radius: 10,
          color: $r('sys.color.ohos_id_shadow_default_lg_dark')
        })
        .shadow({
          radius: 6,
          color: $r('sys.color.ohos_id_shadow_default_lg_dark')
        })
        .onClick(async () => {
          if (this.editServerIdx === this.serverIdx) {
            this.getUIContext().getPromptAction().showToast({
              message: '无法删除选中的服务器！',
              duration: 500
            });
          } else {
            let index = this.editServerIdx
            this.editServerIdx = -1
            this.servernames.splice(index, 1)
            this.baseurls.splice(index, 1)
            this.usernames.splice(index, 1)
            this.passwords.splice(index, 1)
            if (index < this.serverIdx) {
              this.serverIdx--
            }
            this.createEditServer.close()
            this.getUIContext().getPromptAction().showToast({
              message: '删除服务器成功！',
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