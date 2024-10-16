
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNTurboNetworksdkSpec.h"

@interface TurboNetworksdk : NSObject <NativeTurboNetworksdkSpec>
#else
#import <React/RCTBridgeModule.h>

@interface TurboNetworksdk : NSObject <RCTBridgeModule>
#endif

/// 对外暴露接口，初始化 `TurboNetworksdk` 模块
+ (void)setupNetworkSdk;

// 透出网络配置
+ (NSURLSessionConfiguration *)sessionConfiguration;

@end
