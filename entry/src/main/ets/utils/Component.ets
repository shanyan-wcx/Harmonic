import { CircleShape } from "@kit.ArkUI"
import { deviceInfo } from "@kit.BasicServicesKit";

let deviceTypeInfo: string = deviceInfo.deviceType;

@Component
export struct coverImage {
  @Prop url: string = ''
  @Prop radius: number = 0
  @State shadowRadius: number = 6
  @State aspect: number = 1

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.glass_panel'))
        .borderRadius(this.radius)

      Image(this.url)
        .alt($rawfile('nocover.png'))
        .objectFit(ImageFit.Contain)
        .width('100%')
        .height('100%')
        .onComplete((e) => {
          if (e?.width && e?.height) {
            this.aspect = e.width / e.height
          }
        })
        .onAreaChange((oldArea, newArea) => {
          if (newArea.width > 60 || newArea.height > 60) {
            this.shadowRadius = 6
          } else {
            this.shadowRadius = 3
          }
        })
        .borderRadius(this.radius)
        .draggable(false)
    }
    .backgroundImage(this.url)
    .backgroundImageSize(ImageSize.Cover)
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .backgroundBrightness({ rate: 0.55, lightUpDegree: 0.2 })
    .width(this.aspect >= 1 ? '100%' : 'auto')
    .height(this.aspect < 1 ? '100%' : 'auto')
    .layoutWeight(1)
    .aspectRatio(this.aspect)
    .borderRadius(this.radius)
    .border({
      width: deviceTypeInfo === '2in1' ? 1 : 0,
      radius: this.radius,
      color: $r('app.color.glass_border')
    })
    .shadow({
      radius: 8,
      offsetY: 4,
      color: $r('app.color.glass_shadow')
    })
  }
}

@Component
export struct artistImage {
  @Prop url: string = ''
  @State shadowRadius: number = 6

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.glass_panel'))
        .clipShape(new CircleShape({ width: '100%', height: '100%' }))

      Image(this.url)
        .alt($rawfile('noprofile.jpg'))
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('100%')
        .onAreaChange((oldArea, newArea) => {
          if (newArea.width > 60 || newArea.height > 60) {
            this.shadowRadius = 6
          } else {
            this.shadowRadius = 3
          }
        })
        .draggable(false)
        .clipShape(new CircleShape({ width: '100%', height: '100%' }))
    }
    .backgroundImage(this.url)
    .backgroundImageSize(ImageSize.Cover)
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .backgroundBrightness({ rate: 0.55, lightUpDegree: 0.2 })
    .width('100%')
    .height('100%')
    .aspectRatio(1)
    .border({
      width: deviceTypeInfo === '2in1' ? 1 : 0,
      radius: 999999999999999,
      color: $r('app.color.glass_border')
    })
    .shadow({
      radius: 8,
      offsetY: 4,
      color: $r('app.color.glass_shadow')
    })
  }
}
