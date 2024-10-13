
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTurboNetworksdkSpec.h"

@interface TurboNetworksdk : NSObject <NativeTurboNetworksdkSpec>
#else
#import <React/RCTBridgeModule.h>

@interface TurboNetworksdk : NSObject <RCTBridgeModule>
#endif

@end
