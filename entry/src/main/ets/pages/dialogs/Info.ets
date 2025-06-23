import { Song } from '../../utils/Interface'

function formatDuration(seconds: number): string {
  const roundedSeconds = Math.floor(seconds);
  const hours = Math.floor(roundedSeconds / 3600);
  const minutes = Math.floor((roundedSeconds % 3600) / 60);
  const secs = roundedSeconds % 60;
  const paddedMinutes = minutes.toString().padStart(2, '0');
  const paddedSeconds = secs.toString().padStart(2, '0');
  let formattedTime = `${paddedMinutes}:${paddedSeconds}`;
  if (hours > 0) {
    const paddedHours = hours.toString().padStart(2, '0');
    formattedTime = `${paddedHours}:${formattedTime}`;
  }
  return formattedTime;
}

function bytesToMB(bytes: number): number {
  const MB = 1024 * 1024; // 1MB 等于 1024 * 1024 字节
  return parseFloat((bytes / MB).toFixed(2));
}

@CustomDialog
export default struct infoBuilder {
  @Consume nowPlayingSong: Song | undefined
  @Consume showPlay: boolean
  @Consume longPressSong: Song | undefined
  info: CustomDialogController = new CustomDialogController({
    builder: infoBuilder({})
  })

  build() {
    Column() {
      Text("歌曲信息")
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .fontColor($r('app.color.font'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      Row() {
        Text("标题")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? this.nowPlayingSong!.title : this.longPressSong!.title)
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("专辑")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? this.nowPlayingSong!.album : this.longPressSong!.album)
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("艺术家")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? this.nowPlayingSong!.artist : this.longPressSong!.artist)
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("年份")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ?
          (this.nowPlayingSong!.year !== undefined ? this.nowPlayingSong!.year.toString() : '-') :
          (this.longPressSong!.year !== undefined ? this.longPressSong!.year.toString() : '-'))
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("时长")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? formatDuration(this.nowPlayingSong!.duration) :
        formatDuration(this.longPressSong!.duration))
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("大小")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? bytesToMB(this.nowPlayingSong!.size) + " MB" :
          bytesToMB(this.longPressSong!.size) + " MB")
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("格式")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? this.nowPlayingSong!.suffix.toUpperCase() :
        this.longPressSong!.suffix.toUpperCase())
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("比特率")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? this.nowPlayingSong!.bitRate + " kbps" : this.longPressSong!.bitRate + " kbps")
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text("声道")
          .fontSize(18)
          .fontColor($r('app.color.font'))
        Text(this.showPlay === true ? this.nowPlayingSong!.channelCount.toString() :
        this.longPressSong!.channelCount.toString())
          .fontSize(18)
          .fontColor($r('app.color.font_secondary'))
          .width('100%')
          .layoutWeight(1)
          .margin({ left: 15 })
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .padding({ left: 20, right: 20 })
  }
}