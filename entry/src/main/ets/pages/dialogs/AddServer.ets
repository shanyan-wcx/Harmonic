import { ping } from "../../utils/Api"
import { deviceInfo } from "@kit.BasicServicesKit";
import CryptoJS from "@ohos/crypto-js";

let deviceTypeInfo: string = deviceInfo.deviceType;

@CustomDialog
export default struct addServerBuilder {
  @StorageLink('servernames') servernames: string[] = []
  @StorageLink('baseurls') baseurls: string[] = []
  @StorageLink('usernames') usernames: string[] = []
  @StorageLink('passwords') passwords: string[] = []
  @StorageLink('usesalts') usesalts: boolean[] = []
  @State tmpServername: string = ""
  @State tmpBaseurl: string = ""
  @State tmpUrl: string = ""
  @State tmpUsername: string = ""
  @State tmpPassword: string = ""
  @State urlHead: string[] = ["http://", "https://"]
  @State urlHeadIdx: number = 0
  @State auth: string = ""
  @State useSalt: boolean = false
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  createAddServer: CustomDialogController = new CustomDialogController({
    builder: addServerBuilder({})
  })

  build() {
    Column() {
      Text("添加服务器")
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
          placeholder: '服务器名称'
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
            size: 20,
            weight: FontWeight.Normal
          })
          .fontColor($r('app.color.font'))
          .height(40)
          .borderRadius(10)
          .margin({ left: 15 })
          .optionWidth(80)
          .optionFontColor($r('app.color.font'))
          .selectedOptionFontColor($r('app.color.font'))
          .selectedOptionBgColor($r('app.color.button_selected'))
          .menuBackgroundColor($r('app.color.content_background'))
          .menuBackgroundBlurStyle(BlurStyle.NONE)
          .backgroundColor($r('app.color.textInput'))
        TextInput({
          placeholder: 'server-url'
        })
          .width("100%")
          .height(40)
          .offset({
            x: -20
          })
          .padding({ left: 22 })
          .margin({ right: -20 })
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
          placeholder: 'username'
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
          placeholder: 'password'
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
      .margin({ top: 20 })

      Row() {
        Text("使用密码+盐验证")
          .fontSize(20)
          .fontColor($r('app.color.font'))
        Radio({ value: this.useSalt.toString(), group: this.useSalt.toString(), indicatorType: RadioIndicatorType.TICK })
          .checked(this.useSalt)
          .margin({ left: 10 })
          .radioStyle({
            checkedBackgroundColor: $r('app.color.radio'),
            indicatorColor: $r('app.color.start_window_background')
          })
          .onClick(() => {
            this.useSalt = !this.useSalt
          })
      }
      .margin({ top: 15, bottom: 15 })
      .alignSelf(ItemAlign.Start)

      Button({ type: ButtonType.Normal }) {
        Text("保存")
          .fontSize(20)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(50)
      .borderRadius(10)
      .backgroundColor($r('app.color.button_selected'))
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
          if (this.useSalt) {
            this.auth = `?u=${this.tmpUsername}&t=${CryptoJS.MD5(this.tmpPassword + this.salt)}&s=${this.salt}&v=${this.version}&c=${this.client}&f=json`
          } else {
            this.auth = `?u=${this.tmpUsername}&p=${this.tmpPassword}&v=${this.version}&c=${this.client}&f=json`
          }
          let status = await ping(this.tmpBaseurl, this.auth)
          if(status === 'ok'){
            this.servernames.push(this.tmpServername)
            this.baseurls.push(this.tmpBaseurl)
            this.usernames.push( this.tmpUsername)
            this.passwords.push(this.tmpPassword)
            this.usesalts.push(this.useSalt)
            this.createAddServer.close()
            this.getUIContext().getPromptAction().showToast({
              message: '添加服务器成功！',
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .padding({ left: 20, right: 20 })
  }
}