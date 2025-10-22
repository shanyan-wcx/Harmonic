import { CircleShape } from "@kit.ArkUI"
import { deviceInfo } from "@kit.BasicServicesKit";

let deviceTypeInfo: string = deviceInfo.deviceType;

@Component
export struct ShadowCoverImage {
  @Prop url: string = ''
  @Prop radius: number = 0
  @State aspect: number = 1
  @State shadowRadius: number = 12

  build() {
    Image(this.url)
      .alt($rawfile('nocover.png'))
      .objectFit(ImageFit.Contain)
      .width(this.aspect >= 1 ? '100%' : 'auto')
      .height(this.aspect < 1 ? '100%' : 'auto')
      .layoutWeight(1)
      .onComplete((e) => {
        if (e?.width && e?.height) {
          this.aspect = e.width / e.height
        }
      })
      .onAreaChange((oldArea, newArea) => {
        if (newArea.width > 60 || newArea.height > 60) {
          this.shadowRadius = 12
        } else {
          this.shadowRadius = 6
        }
      })
      .aspectRatio(this.aspect)
      .borderRadius(this.radius)
      .alignSelf(ItemAlign.Center)
      .draggable(false)
      .border({
        width: deviceTypeInfo === '2in1' ? 1 : 0,
        radius: this.radius,
        color: $r('sys.color.ohos_id_shadow_default_lg_dark')
      })
      .shadow({
        radius: this.shadowRadius,
        color: $r('sys.color.ohos_id_shadow_default_lg_dark')
      })
  }
}

@Component
export struct ShadowArtistImage {
  @Prop url: string = ''
  @State shadowRadius: number = 12

  build() {
    Image(this.url)
      .alt($rawfile('noprofile.jpg'))
      .objectFit(ImageFit.Cover)
      .height('100%')
      .aspectRatio(1)
      .onAreaChange((oldArea, newArea) => {
        if (newArea.width > 60 || newArea.height > 60) {
          this.shadowRadius = 12
        } else {
          this.shadowRadius = 6
        }
      })
      .draggable(false)
      .clipShape(new CircleShape({ width: '100%', height: '100%' }))
      .border({
        width: deviceTypeInfo === '2in1' ? 1 : 0,
        radius: this.shadowRadius,
        color: $r('sys.color.ohos_id_shadow_default_lg_dark')
      })
      .shadow({
        radius: this.shadowRadius,
        color: $r('sys.color.ohos_id_shadow_default_lg_dark')
      })
  }
}