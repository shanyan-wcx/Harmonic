import { ping } from '../utils/Api'
import addServerBuilder from './dialogs/AddServer'
import editServerBuilder from './dialogs/EditServer'

@Component
export default struct Setting {
  @StorageLink('baseURL') baseURL: string = ""
  @StorageLink('username') username: string = ""
  @StorageLink('password') password: string = ""
  @StorageLink('audioNormalizatio') audioNormalization: boolean = false
  @StorageLink('fadeVolume') fadeVolume: boolean = false
  @StorageLink('autoPlay') autoPlay: boolean = false
  @StorageLink('collate') collate: boolean = false
  @StorageLink('server') serverIdx: number = -1
  @StorageLink('baseurls') baseurls: string[] = []
  @StorageLink('usernames') usernames: string[] = []
  @StorageLink('passwords') passwords: string[] = []
  @Provide editServerIdx: number = -1
  @Consume startPlaying: boolean
  addServer: CustomDialogController = new CustomDialogController({
    builder: addServerBuilder(),
    width: 350,
    height: 314,
    backgroundColor: $r('app.color.start_window_background')
  })
  editServer: CustomDialogController = new CustomDialogController({
    builder: editServerBuilder(),
    width: 350,
    height: 314,
    backgroundColor: $r('app.color.start_window_background')
  })

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
            .margin({ top: 20, bottom: 5 })
            .textAlign(TextAlign.Center)

          ForEach(this.baseurls, (url: string, index) => {
            Row() {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  Radio({ value: url, group: 'url', indicatorType: RadioIndicatorType.TICK })
                    .width(20)
                    .checked(this.serverIdx === index)
                    .radioStyle({
                      checkedBackgroundColor: $r('app.color.radio'),
                      indicatorColor: $r('app.color.start_window_background')
                    })
                  Text(url)
                    .width('100%')
                    .layoutWeight(1)
                    .fontSize(20)
                    .fontColor($r('app.color.font'))
                    .fontWeight(FontWeight.Medium)
                    .margin({ left: 5 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
              }
              .height(40)
              .width('100%')
              .layoutWeight(1)
              .borderRadius(10)
              .padding({ left: 10, right: 10 })
              .backgroundColor(Color.Transparent)
              .hitTestBehavior(HitTestMode.Block)
              .onClick(async () => {
                if (index === this. serverIdx){
                  this.serverIdx = -1
                  this.baseURL = ""
                  this.username = ""
                  this.password = ""
                } else {
                  let status = await ping(this.baseurls[index], this.usernames[index], this.passwords[index])
                  if (status === 'ok') {
                    this.serverIdx = index
                    this.baseURL = this.baseurls[index]
                    this.username = this.usernames[index]
                    this.password = this.passwords[index]
                  } else {
                    this.getUIContext().getPromptAction().showToast({
                      message: '连接服务器失败！',
                      duration: 500
                    });
                  }
                }
              })

              Button({ type: ButtonType.Normal }) {
                Image($r('app.media.edit'))
                  .width(20)
                  .height(20)
              }
              .height(40)
              .width(40)
              .margin({ left: 10 })
              .borderRadius(10)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.editServerIdx = index
                this.editServer.open()
              })
            }
            .width('100%')
          })

          Button({ type: ButtonType.Normal }) {
            Text("添加")
              .fontSize(20)
              .fontColor($r('app.color.font'))
          }
          .width('100%')
          .height(50)
          .borderRadius(10)
          .backgroundColor($r('app.color.content_background'))
          .margin({ top: 10, bottom: 20 })
          .onClick(async () => {
            this.addServer.open()
          })
        }
        .width('100%')
        .backgroundColor($r('app.color.bar_background'))
        .borderRadius(10)
        .margin({ top: 10 })
        .padding({ left: 20, right: 20 })

        Column() {
          Text("播放设置")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 20, bottom: 15 })
            .textAlign(TextAlign.Center)
          Row() {
            Text("继续上次播放")
              .fontColor($r('app.color.font'))
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Toggle({ type: ToggleType.Switch, isOn: $$this.autoPlay })
              .selectedColor($r('app.color.radio'))
              .switchPointColor($r('app.color.bar_background'))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text("回放增益")
              .fontColor($r('app.color.font'))
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Toggle({ type: ToggleType.Switch, isOn: $$this.audioNormalization })
              .selectedColor($r('app.color.radio'))
              .switchPointColor($r('app.color.bar_background'))
          }
          .width('100%')
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text("淡入淡出")
              .fontColor($r('app.color.font'))
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Toggle({ type: ToggleType.Switch, isOn: $$this.fadeVolume })
              .selectedColor($r('app.color.radio'))
              .switchPointColor($r('app.color.bar_background'))
          }
          .width('100%')
          .margin({ top: 10 })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .backgroundColor($r('app.color.bar_background'))
        .borderRadius(10)
        .padding({ left: 20, right: 20, bottom: 20 })
        .margin({ top: 20 })

        Column() {
          Text("下载设置")
            .width('100%')
            .fontSize(20)
            .fontColor($r('app.color.font'))
            .fontWeight(FontWeight.Bold)
            .padding({ left: 20, right: 20 })
            .margin({ top: 20, bottom: 15 })
            .textAlign(TextAlign.Center)
          Row() {
            Text("按【艺术家/专辑】下载")
              .fontColor($r('app.color.font'))
              .fontSize(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Toggle({ type: ToggleType.Switch, isOn: $$this.collate })
              .selectedColor($r('app.color.radio'))
              .switchPointColor($r('app.color.bar_background'))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .backgroundColor($r('app.color.bar_background'))
        .borderRadius(10)
        .padding({ left: 20, right: 20, bottom: 20 })
        .margin({ top: 20 })
      }
      .padding({ bottom: this.startPlaying === true ? 105 : 20 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .padding({ left: 20, right: 20 })
    .align(Alignment.Top)
  }
}