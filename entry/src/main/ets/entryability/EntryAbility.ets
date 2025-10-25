import { AbilityConstant, UIAbility, Want, Configuration, ConfigurationConstant, appRecovery, errorManager } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import app from '@system.app';

let callback: errorManager.ErrorObserver = {
  onUnhandledException(errMsg) {
    console.log(errMsg);
    appRecovery.saveAppState();
    appRecovery.restartApp();
  }
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    app.setImageFileCacheSize(256 * 1024 * 1024);
    appRecovery.enableAppRecovery(appRecovery.RestartFlag.ALWAYS_RESTART,
      appRecovery.SaveOccasionFlag.SAVE_WHEN_ERROR | appRecovery.SaveOccasionFlag.SAVE_WHEN_BACKGROUND,
      appRecovery.SaveModeFlag.SAVE_WITH_FILE);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    errorManager.on('error', callback);

    windowStage.setWindowRectAutoSave(true, true);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      PersistentStorage.persistProp('showStepper', true);
      PersistentStorage.persistProp('downloadDir', '');
      PersistentStorage.persistProp('theme', ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      PersistentStorage.persistProp('playMode', 1);
      PersistentStorage.persistProp('audioNormalizatio', false);
      PersistentStorage.persistProp('fadeVolume', false);
      PersistentStorage.persistProp('autoPlay', false);
      PersistentStorage.persistProp('collate', false);
      PersistentStorage.persistProp('baseURL', '');
      PersistentStorage.persistProp('username', '');
      PersistentStorage.persistProp('password', '');
      PersistentStorage.persistProp('useSalt', true);
      PersistentStorage.persistProp('libraryStates', '{}');
      PersistentStorage.persistProp('server', -1);
      PersistentStorage.persistProp('servernames', []);
      PersistentStorage.persistProp('baseurls', []);
      PersistentStorage.persistProp('usernames', []);
      PersistentStorage.persistProp('passwords', []);
      PersistentStorage.persistProp('usesalts', []);
    });

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

  async onConfigurationUpdated(newConfig: Configuration) {
    let systemTheme: number | undefined = newConfig.colorMode
    let mainWindow = await window.getLastWindow(this.context)
    if (systemTheme === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      mainWindow.setWindowSystemBarProperties({
        statusBarContentColor: '#FFFFFF',
      })
    } else {
      mainWindow.setWindowSystemBarProperties({
        statusBarContentColor: '#000000',
      })
    }
  }
}
