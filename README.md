# react-native-turbo-networksdk

A modern network client arch for react-native，base on cronet. this library supports react-native new architecture.

## Installation

```sh
yarn add react-native-turbo-networksdk
```

## Usage

### iOS

```objectivec
#import <react-native-turbo-networksdk/TurboNetworksdk.h>

@implementation AppDelegate

You need to place the initialization tasks in the app didFinishLaunchingWithOptions method to perform the TurboNetwork initialization as early as possible.

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // must be called before the application is launched
    [TurboNetworksdk setupNetworkSdk];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
```

Through this method, you can proxy React Native's own fetch requests and resource requests.

However, if you need to proxy internal requests from a WebView, we also expose a unified NSURLSessionConfiguration to facilitate your integration.

```swift
// Example: 
// WebResourceRequestHandler is your application webview network request fetcher

class WebResourceRequestHandler: NSObject {
  static let shared = WebResourceRequestHandler()
  static let operationQueue = OperationQueue()
  private var delegates = ThreadSafeDictionary<URLSessionTask, ResourceRequestDelegate>()
  private lazy var session: URLSession = {
    let configuration = TurboNetworksdk.sessionConfiguration() ?? URLSessionConfiguration.default
    return URLSession(configuration: configuration,
                      delegate: self, delegateQueue: WebResourceRequestHandler.operationQueue)
  }()

```

if you need update some config for network, you can call updateNetworkConfig

```typescript
import { updateTurboNetworksConfiguration } from 'react-native-turbo-networksdk';

/// Async updateTurboNetworksConfiguration with network configuration
/// This configuration will be applied to the network settings when the application restarts.
updateTurboNetworksConfiguration(
  enableHTTPCache: true, // enable disk cache
  quicPreHintHost?: [],  // quic pre hint host list, quic pre hint will be applied to the network settings when the application restarts
  blackList?: []         // forbidden list of black lists not supported by the network settings
)

```

### Android

> TODO


## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
