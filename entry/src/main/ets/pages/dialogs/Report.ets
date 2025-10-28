import { deviceInfo } from '@kit.BasicServicesKit';

let deviceTypeInfo: string = deviceInfo.deviceType;

@CustomDialog
export default struct reportBuilder {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  // 被举报的对象信息
  @State targetId: string | undefined = undefined
  @State targetType: string | undefined  = undefined
  // 用户输入状态
  @State reason: string = ''
  @State description: string = ''
  @State showProgress: boolean = false
  reportDialog: CustomDialogController = new CustomDialogController({
    builder: reportBuilder({})
  })

  build() {
    Stack() {
      Column() {
        Text("举报内容")
          .width('100%')
          .height(60)
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontColor($r('app.color.font'))
          .fontWeight(FontWeight.Bold)

        Row() {
          Text("举报原因")
            .fontSize(20)
            .fontColor($r('app.color.font'))
          TextInput({
            placeholder: '请输入举报原因（如违规内容）',
            text: $$this.reason
          })
            .width("100%")
            .height(40)
            .layoutWeight(1)
            .borderRadius(10)
            .margin({ left: 15 })
            .caretColor($r('app.color.font_secondary'))
            .fontColor($r('app.color.font'))
            .fontSize(18)
            .placeholderFont({ size: 18 })
            .enterKeyType(EnterKeyType.Next)
        }
        .width('100%')
        .margin({ bottom: 20 })

        Row() {
          Text("详细描述")
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .margin({ top: 5 })
          TextArea({
            placeholder: '请描述具体情况（可选）',
            text: $$this.description
          })
            .width("100%")
            .height(120)
            .layoutWeight(1)
            .borderRadius(10)
            .margin({ left: 15 })
            .caretColor($r('app.color.font_secondary'))
            .fontColor($r('app.color.font'))
            .fontSize(18)
            .placeholderFont({ size: 18 })
            .enterKeyType(EnterKeyType.Next)
        }
        .width('100%')
        .margin({ bottom: 20 })
        .alignItems(VerticalAlign.Top)

        Row() {
          Button({ type: ButtonType.Normal }) {
            Text("提交")
              .fontSize(20)
              .fontColor($r('app.color.font'))
          }
          .width('47%')
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
            if (!this.reason.trim()) {
              this.getUIContext().getPromptAction().showToast({
                message: '请填写举报原因！',
                duration: 800
              })
              return
            }

            this.showProgress = true
            let success = true
            this.showProgress = false

            if (success === true) {
              this.reportDialog.close()
              this.getUIContext().getPromptAction().showToast({
                message: '举报已提交，感谢反馈！',
                duration: 1000
              });
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: '提交失败，请检查网络！',
                duration: 1000
              });
            }
          })

          Button({ type: ButtonType.Normal }) {
            Text("取消")
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
          .onClick(() => {
            this.reportDialog.close()
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.start_window_background'))
      .padding({ left: 20, right: 20 })

      // 加载状态
      Column() {
        LoadingProgress()
          .width("100%")
          .height(72)
          .color($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .visibility(this.showProgress ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}
