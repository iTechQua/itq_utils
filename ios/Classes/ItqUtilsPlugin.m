#import ItqUtilsPlugin.h
#if __has_include(<itq_utils/itq_utils-Swift.h>)
#import <itq_utils/itq_utils-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "itq_utils-Swift.h"
#endif

@implementation ItqUtilsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftItqUtilsPlugin registerWithRegistrar:registrar];
}
@end
