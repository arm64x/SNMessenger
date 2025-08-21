#import <UIKit/UIKit.h>

@interface FBAnalytics : NSObject
+ (instancetype)sharedAnalytics;
- (NSString *)userFBID;
@end
