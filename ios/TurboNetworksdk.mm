#import "TurboNetworksdk.h"
#import <React/RCTHTTPRequestHandler.h>
#import <Cronet/Cronet.h>

@implementation TurboNetworksdk
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(updateConfig:(BOOL)enableHTTPCache quicPreHintHost:(NSArray *)quicPreHintHost blackList:(NSArray *)blackList resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  @try {
    // 更新缓存设置
    [TurboNetworksdk setUD:@"enableHTTPCache" value:@(enableHTTPCache)];
    [TurboNetworksdk setUD:@"quicPreHintHost" value:quicPreHintHost];
    [TurboNetworksdk setUD:@"blackList" value:blackList];
    
    resolve(@(1));
  } @catch (NSException *exception) {
    auto error = [NSError errorWithDomain:exception.name code:0 userInfo:@{
      NSUnderlyingErrorKey: exception,
      NSDebugDescriptionErrorKey: exception.userInfo ?: @{ },
      NSLocalizedFailureReasonErrorKey: (exception.reason ?: @"???") }];
    reject(@"config_error", @"Failed to update configuration.", error);
  }
}

#pragma mark - Set and Get UserDefaults

// 设置 UserDefaults 数据
+ (void)setUD:(NSString *)key value:(id)value {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *newKey = [NSString stringWithFormat:@"rn_turbo_net_%@", key];
  [defaults setObject:value forKey:newKey];
  [defaults synchronize];  // 立即同步保存
}

// 获取 UserDefaults 数据
+ (id)getUD:(NSString *)key {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *newKey = [NSString stringWithFormat:@"rn_turbo_net_%@", key];
  return [defaults objectForKey:newKey];
}


+ (void)setupPreQuicHint:(NSArray *)hostList {
  auto hostSet = [[NSMutableSet alloc] init];
  // 设置预建连域名
  [hostList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (![obj isKindOfClass:NSString.class]) {
      return;
    }
    
    auto url = [NSURL URLWithString:obj];
    auto host = url.host;
    
    if (host) {
      [hostSet addObject:host];
    }
  }];
  
  [hostSet enumerateObjectsUsingBlock:^(NSString * host, BOOL * _Nonnull stop) {
    [Cronet addQuicHint:host port:443 altPort:443];
  }];
}

+ (NSURLSessionConfiguration *)sessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [Cronet installIntoSessionConfiguration:configuration];
    [configuration setHTTPShouldSetCookies:YES];
    [configuration setHTTPCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [configuration setHTTPCookieStorage:[NSHTTPCookieStorage sharedHTTPCookieStorage]];
    return configuration;
}

+ (void)setupNetworkSdk {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // 开启 http2
    [Cronet setHttp2Enabled:YES];
    // 设置支持 QUIC
    [Cronet setQuicEnabled:YES];
    // 设置支持 Br 压缩算法，并列的有 gzip 算法
    [Cronet setBrotliEnabled:YES];
    // 开启 metric 性能统计
    [Cronet setMetricsEnabled:YES];
    
    // 设置缓存，默认为 yes
    BOOL enableCache = YES;
    NSNumber *enableHTTPCacheNumber = [self getUD:@"enableHTTPCache"];
    if (enableHTTPCacheNumber) {
      enableCache = [enableHTTPCacheNumber boolValue];
    }
    
    if (enableCache) {
      [Cronet setHttpCacheType:CRNHttpCacheTypeDisk];
    } else {
      [Cronet setHttpCacheType:CRNHttpCacheTypeDisabled];
    }
    
    // 预先告诉 Cronet，支持 H3 的域名，以便尽快链接 H3 协议
    auto hostSet = [[NSMutableSet alloc] init];
    // 设置预建连域名
    NSArray *hostList = @[@"quic.ncuos.com", @"quic.nginx.org"];
    NSArray *cacheHosts = [self getUD:@"quicPreHintHost"];
    if ([cacheHosts isKindOfClass:NSArray.class] && cacheHosts.count > 0) {
      hostList = cacheHosts;
    }
    [self setupPreQuicHint:hostList];

    // 引擎初始化
    [Cronet start];
    
    // 拦截 NSURLConnection and shared NSURLSession.
    [Cronet registerHttpProtocolHandler];
    
    NSArray *blacklist = @[];
    NSArray *cacheBlackList = [self getUD:@"blackList"];
    if ([cacheBlackList isKindOfClass:NSArray.class] && cacheBlackList.count > 0) {
      blacklist = cacheBlackList;
    }
    // 黑名单能力
    [Cronet setRequestFilterBlock:^BOOL(NSURLRequest *request) {
        NSString *host = request.URL.host;
        if ([blacklist containsObject:host]) {
            return NO;
        }
        return YES;
    }];
    
    /// 设置 rn session 配置
    RCTSetCustomNSURLSessionConfigurationProvider(^NSURLSessionConfiguration *{
      return [self sessionConfiguration];
    });
  });
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeTurboNetworksdkSpecJSI>(params);
}
#endif

@end
