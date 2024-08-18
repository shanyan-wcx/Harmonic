@Component
export default struct Stats {
  build() {
    Column() {
      Column() {

      }
      .width('100%')
      .backgroundColor($r('app.color.bar_background'))
      .borderRadius(10)
      .margin({ top: 10 })
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }
}