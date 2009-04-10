#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <Celestial/AVController.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVQueue.h>

@interface MainView : UIView
{
	UITextView	*textView;
	AVController	*av;
	AVQueue		*avq;
}
- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
@end

@interface MGRSapp : UIApplication
{
	UIWindow *window;
	MainView *mainView;
	NSDate *waketime;
	int running;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
@end
