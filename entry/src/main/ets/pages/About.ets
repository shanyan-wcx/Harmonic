import { common, Want } from '@kit.AbilityKit'
import { bundleManager } from '@kit.AbilityKit';

let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleFlags)

@Component
export default struct About {
  uiContext: UIContext | undefined = undefined
  context: common.UIAbilityContext | undefined = undefined

  aboutToAppear(): void {
    this.uiContext = this.getUIContext();
    if (!this.uiContext) {
      console.warn("no uiContext");
      return;
    }
    this.context = this.uiContext.getHostContext() as common.UIAbilityContext;
  }

  build() {
    Column() {
      Column() {
        Text("Harmonic")
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font'))
        Text("Navidrome的鸿蒙Next客户端")
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .margin({ top: 5 })
        Row() {
          Text("版本号")
            .fontSize(20)
            .fontColor($r('app.color.font'))
          Text('v' + bundleInfo.versionName)
            .fontSize(20)
            .fontColor($r('app.color.font'))
        }
        .width('100%')
        .margin({ top: 20 })
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text("项目地址")
            .fontSize(20)
            .fontColor($r('app.color.font'))
          Image($r('app.media.github'))
            .width(25)
            .height(25)
            .onClick(() => {
              let want: Want = {
                action: 'ohos.want.action.viewData',
                entities: ['entity.system.browsable'],
                uri: 'https://github.com/shanyan-wcx/Harmonic'
              };
              this.context!.startAbility(want)
            })
        }
        .width('100%')
        .margin({ top: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
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