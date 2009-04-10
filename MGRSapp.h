#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIApplication.h>

@interface MainView : UIView
{
	UITextView *mgrs1_textview;
	UITextView *mgrs2_textview;
	UITextView *latlon_textview;
	UIImageView *background_view;
	UIImage *bgimage;
	char GZDSI[6];
	char eastnorth[12];
}
- (id)initWithFrame:(CGRect)frame;
- (void)set_GZD_SI:(char *)new_gzdsi;
- (void)set_eastnorth:(char *)new_eastnorth;
- (void)convert;
- (void)dealloc;
@end

@interface MGRSText : UITextView
{
}
- (id)initWithFrame:(CGRect)frame;
- (void)setText:(NSString *)t;
- (void)dealloc;
@end

@interface MGRSLeft : MGRSText
{
}
- (void)mouseDown:(struct __GSEvent *)event;
@end

@interface MGRSRight : MGRSText
{
}
- (void)mouseDown:(struct __GSEvent *)event;
@end

@interface MGRSapp : UIApplication
{
	UIWindow *window;
	MainView *mainView;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
@end
