import { AbilityConstant, UIAbility, Want, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      PersistentStorage.persistProp('firstStart', true);
      PersistentStorage.persistProp('downloadDir', '');
      PersistentStorage.persistProp('theme', ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      PersistentStorage.persistProp('playMode', 1);
      PersistentStorage.persistProp('audioNormalizatio', false);
      PersistentStorage.persistProp('fadeVolume', false);
      PersistentStorage.persistProp('collate', false);
      PersistentStorage.persistProp('baseURL', '');
      PersistentStorage.persistProp('username', '');
      PersistentStorage.persistProp('password', '');
    });
    // let mainWindow = windowStage.getMainWindowSync();
    // mainWindow.setWindowSystemBarEnable(["status"]);
    // mainWindow.setWindowSystemBarProperties({
    //   statusBarColor: "#00000000"
    // })
    // mainWindow.setWindowLayoutFullScreen(true)

    windowStage.getMainWindow().then((data: window.Window) => {
      let deviceTypeInfo: string = deviceInfo.deviceType;
      if (deviceTypeInfo === '2in1') {
        data.setWindowDecorVisible(false);
        data.setWindowDecorHeight(55);
        data.setDecorButtonStyle({
          buttonBackgroundSize: 40,
          spacingBetweenButtons: 12,
          closeButtonRightMargin: 10
        });
      }
      data.setWindowSystemBarEnable(["status"]);
      data.setWindowSystemBarProperties({
        statusBarColor: "#00000000"
      })
      data.setWindowLayoutFullScreen(true)
    })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
