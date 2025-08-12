#include <UIKit/UIKit.h>

@interface NGViewController : NSObject
+ (UIViewController *)getTopViewController;
@end

@implementation NGViewController

+ (UIWindow *)topWindow
{
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wdeprecated-declarations"
  UIWindow *topWindow = [UIApplication sharedApplication].keyWindow;
  #pragma clang diagnostic pop
  if (topWindow == nil || topWindow.windowLevel < UIWindowLevelNormal) {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
      if (window.windowLevel >= topWindow.windowLevel && !window.isHidden) {
        topWindow = window;
      }
    }
  }

  if (topWindow != nil) {
    return topWindow;
  }

  // Find active key window from UIScene
  if (@available(iOS 13.0, *)) {
    NSSet *scenes = [[UIApplication sharedApplication] valueForKey:@"connectedScenes"];
    for (id scene in scenes) {
      id activationState = [scene valueForKeyPath:@"activationState"];
      BOOL isActive = activationState != nil && [activationState integerValue] == 0;
      if (isActive) {
        Class WindowScene = NSClassFromString(@"UIWindowScene");
        if ([scene isKindOfClass:WindowScene]) {
          NSArray<UIWindow *> *windows = [scene valueForKeyPath:@"windows"];
          for (UIWindow *window in windows) {
            if (window.isKeyWindow) {
              return window;
            } else if (window.windowLevel >= topWindow.windowLevel && !window.isHidden) {
              topWindow = window;
            }
          }
        }
      }
    }
  }
  return topWindow;
}

+ (UIViewController *)getTopViewController {
    UIViewController *topVC = [self topWindow].rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    while (topVC.isBeingDismissed) {
        topVC = topVC.presentingViewController;
    }
    return topVC;
}

@end

extern "C" UIViewController*    NGTopViewController()
{
    return [NGViewController getTopViewController];
}
