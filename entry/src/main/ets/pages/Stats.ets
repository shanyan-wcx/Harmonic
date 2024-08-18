import { Album, Artist, Song } from '../utils/Interface'

@Component
export default struct Stats {
  @Consume songs: Song[]
  @Consume albums: Album[]
  @Consume artists: Artist[]

  build() {
    Column() {
      Column() {
        Row() {
          Column() {
            Text(this.songs.length.toString())
              .fontSize(28)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Bold)
            Text("歌曲")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .margin({ top: 5 })
          }

          Column() {
            Text(this.albums.length.toString())
              .fontSize(28)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Bold)
            Text("专辑")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .margin({ top: 5 })
          }

          Column() {
            Text(this.artists.length.toString())
              .fontSize(28)
              .fontColor($r('app.color.font'))
              .fontWeight(FontWeight.Bold)
            Text("艺术家")
              .fontSize(20)
              .fontColor($r('app.color.font'))
              .margin({ top: 5 })
          }
        }
        .width('100%')
        .height('auto')
        .padding(20)
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