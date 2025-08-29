@CustomDialog
export default struct firstStartBuilder {
  @StorageLink('firstStart') firstStart: boolean = true
  createFirstStart: CustomDialogController = new CustomDialogController({
    builder: firstStartBuilder({})
  })

  build() {
    Column() {
      Text("首次启动")
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .fontColor($r('app.color.font'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      Text("请先到设置页面添加服务器。")
        .width('100%')
        .fontSize(20)
        .fontColor($r('app.color.font'))
        .margin({ bottom: 20 })

      Button({ type: ButtonType.Normal }) {
        Text("确认")
          .fontSize(20)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height(50)
      .borderRadius(10)
      .backgroundColor($r('app.color.bar_background'))
      .onClick(async () => {
        this.firstStart = false
        this.createFirstStart.close()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .padding({ left: 20, right: 20 })
  }
}