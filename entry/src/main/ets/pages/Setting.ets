@Component
export default struct Setting {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @StorageLink('audioNormalizatio') audioNormalization: boolean = false
  @StorageLink('fadeVolume') fadeVolume: boolean = false
  @StorageLink('collate') collate: boolean = false

  build() {
    Scroll() {
      Column() {
        Column() {
          Text("服务器设置")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 15 })
            .textAlign(TextAlign.Center)
          Row() {
            Text("服务器")
              .width(60)
              .fontSize(20)
              .fontColor($r('app.color.font'))
            TextInput({
              placeholder: 'https://my.navidrome.com',
              text: $$this.baseURL
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
              .type(InputType.URL)
              .enterKeyType(EnterKeyType.Next)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 20 })

          Row() {
            Text("账号")
              .width(60)
              .fontSize(20)
              .fontColor($r('app.color.font'))
            TextInput({
              placeholder: 'Username',
              text: $$this.username
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
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 15 })

          Row() {
            Text("密码")
              .width(60)
              .fontSize(20)
              .fontColor($r('app.color.font'))
            TextInput({
              placeholder: 'Password',
              text: $$this.password
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
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 15, bottom: 20 })
        }
        .width('100%')
        .backgroundColor($r('app.color.bar_background'))
        .borderRadius(10)
        .margin({ top: 10 })

        Column() {
          Text("播放设置")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 15 })
            .textAlign(TextAlign.Center)
          Row() {
            Text("回放增益")
              .fontColor($r('app.color.font'))
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Toggle({ type: ToggleType.Switch, isOn: $$this.audioNormalization })
              .selectedColor($r('app.color.radio'))
              .switchPointColor($r('app.color.font'))
          }
          .width('100%')
          .margin({ top: 20, bottom: 20 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text("淡入淡出")
              .fontColor($r('app.color.font'))
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Toggle({ type: ToggleType.Switch, isOn: $$this.fadeVolume })
              .selectedColor($r('app.color.radio'))
              .switchPointColor($r('app.color.font'))
          }
          .width('100%')
          .margin({ bottom: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .backgroundColor($r('app.color.bar_background'))
        .borderRadius(10)
        .padding({ left: 20, right: 20 })
        .margin({ top: 20 })

        Column() {
          Text("下载设置")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 15 })
            .textAlign(TextAlign.Center)
          Row() {
            Text("按【艺术家/专辑】下载")
              .fontColor($r('app.color.font'))
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Toggle({ type: ToggleType.Switch, isOn: $$this.collate })
              .selectedColor($r('app.color.radio'))
              .switchPointColor($r('app.color.font'))
          }
          .width('100%')
          .margin({ top: 20, bottom: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .backgroundColor($r('app.color.bar_background'))
        .borderRadius(10)
        .padding({ left: 20, right: 20 })
        .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
    .align(Alignment.Top)
  }
}