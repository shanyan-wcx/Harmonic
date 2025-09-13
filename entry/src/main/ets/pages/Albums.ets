import { Album, Song, MusicFolder} from '../utils/Interface';
import {getAlbumList} from '../utils/Api';
import { curves } from '@kit.ArkUI';
import { ImageKnifeComponent } from '@ohos/imageknife'

@Component
export default struct Albums {
  @StorageLink('baseURL') baseURL: string = ''
  @StorageLink('username') username: string = ''
  @StorageLink('password') password: string = ''
  @Consume salt: string
  @Consume version: string
  @Consume client: string
  @Consume auth: string
  @Consume getCoverUrl: string
  @Consume albums: Album[]
  @Consume album: Album | undefined
  @Consume pageStack: NavPathStack
  @Consume startPlaying: boolean
  @Consume showSidebar: boolean
  @Consume serverStatus: boolean
  @Consume discs: Song[][]
  @Consume displayWidth: number
  @Consume showProgress: boolean
  @Consume needUpdate: boolean
  @Consume showLibrary: boolean
  @State coverSize: number = 320
  @Consume libraryStates: Record<number, boolean>
  @Consume musicFolders: MusicFolder[]

  async aboutToAppear() {
    this.needUpdate = !this.needUpdate
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.albums, (album: Album, index) => {
          GridItem() {
            Button({ type: ButtonType.Normal }) {
              Column() {
                ImageKnifeComponent({
                  imageKnifeOption: {
                    loadSrc:this.baseURL + this.getCoverUrl + this.auth + `&id=${album.id}&size=${this.coverSize}`,
                    placeholderSrc: $rawfile('nocover.png'),
                    errorholderSrc:$rawfile('nocover.png') ,
                    objectFit: ImageFit.Contain
                  }
                })
                  .width('100%')
                  .aspectRatio(1)
                  .borderRadius(10)
                  .margin(10)
                Text(album.title)
              }
              .width('100%')
              .height('auto')
            }
            .width('100%')
            .height('auto')
            .margin({ bottom: this.startPlaying === true && index === this.albums.length - 1 ? 85 : 0 })
            .animation({ curve: curves.springMotion(0.6, 1) })
            .borderRadius(10)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.album = album
              this.pageStack.pushPathByName('AlbumDetail', undefined);
            })
          }
        })
      }
      .width('100%')
      .height('100%')
      .columnsTemplate(this.displayWidth > 1400 ? "1fr 1fr 1fr 1fr 1fr 1fr" :
        (this.displayWidth > 1000 ? "1fr 1fr 1fr 1fr 1fr" :
          (this.displayWidth > 800 ? "1fr 1fr 1fr 1fr" : (this.displayWidth > 400 ? "1fr 1fr 1fr" : "1fr 1fr"))))
      .columnsGap(0)
      .rowsGap(0)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade, {alwaysEnabled: false})
      .padding({ left: 10, right: 10, bottom: 10 })
      .visibility(this.albums.length > 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
      .onReachEnd(async ()=>{
        // get more data
        this.showProgress = true;
        let keys = Object.keys(this.libraryStates)
        for (const id of keys) {
          if (this.libraryStates[id] === true) {
            if (!this.musicFolders.some(item => item.id === Number(id))) {
              this.libraryStates[id] = false
              continue;
            }
            let offset = this.albums.length;
            let size = 50
            let albums = await getAlbumList(this.baseURL, this.username, this.password, offset, Number(id), size)
            if (albums === undefined || albums.length === 0) {
              console.log("==get albums failed")
              break;
            }
            this.albums.push(...albums)
            console.log(`old_size: ${offset}, new_size: ${this.albums.length}}`)
          }
        }
        this.showProgress = false;
      })

      Column() {
        Text("没有专辑")
          .fontSize(32)
          .fontColor($r('app.color.font'))
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 160 })
      .justifyContent(FlexAlign.Center)
      .visibility(this.albums.length === 0 && this.showProgress === false ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height('100%')
  }
}