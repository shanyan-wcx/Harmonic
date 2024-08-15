@Component
export default struct Setting {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''

  build() {
    Scroll() {
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
            text: this.baseURL.slice(0, -5)
          })
            .width("100%")
            .height(40)
            .layoutWeight(1)
            .margin({ left: 10 })
            .caretColor($r('app.color.font_secondary'))
            .fontColor($r('app.color.font'))
            .type(InputType.URL)
            .enterKeyType(EnterKeyType.Next)
            .onChange((value) => {
              this.baseURL = value + '/rest';
            })
        }
        .padding({ left: 20, right: 20 })
        .margin({ top: 15 })

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
            .margin({ left: 10 })
            .caretColor($r('app.color.font_secondary'))
            .fontColor($r('app.color.font'))
            .type(InputType.USER_NAME)
            .enterKeyType(EnterKeyType.Next)
        }
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
            .margin({ left: 10 })
            .caretColor($r('app.color.font_secondary'))
            .fontColor($r('app.color.font'))
            .type(InputType.Password)
            .enterKeyType(EnterKeyType.Next)
        }
        .padding({ left: 20, right: 20 })
        .margin({ top: 15, bottom: 20 })
      }
      .width('80%')
      .backgroundColor($r('app.color.bar_background'))
      .borderRadius(10)
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
  }
}