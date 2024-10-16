import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-turbo-networksdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const TurboNetworksdkModule = isTurboModuleEnabled
  ? require('./NativeTurboNetworksdk').default
  : NativeModules.TurboNetworksdk;

const TurboNetworksdk = TurboNetworksdkModule
  ? TurboNetworksdkModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function updateTurboNetworksConfiguration(
  enableHTTPCache: boolean,
  quicPreHintHost?: string[],
  blackList?: string[]
): Promise<number> {
  return TurboNetworksdk.updateConfig(
    enableHTTPCache,
    quicPreHintHost,
    blackList
  );
}
