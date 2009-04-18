#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIApplication.h>

@interface MGRSText : UITextView
{
	NSObject *parent;
}
- (id)initWithFrame:(CGRect)frame;
- (void)setText:(NSString *)t;
- (void)setmainview:(id)newmv;
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

@interface KeyView : MGRSText
{
	int keyid;
	NSObject *upper;
}
- (void)setText:(NSString *)t;
- (void)setkv:(id)newparent;
- (void)setid:(int)newkeyid;
- (void)mouseDown:(struct __GSEvent *)event;
@end

@interface KeyboardView : UIView
{
	float width;
	float height;
	int rows;
	int columns;
	KeyView **keys;
}
- (id)initWithFrame:(CGRect)frame;
- (void)create_keys;
- (void)dealloc;
@end

@interface NumericKeyboardView: KeyboardView
{
	NSObject *parent;
}
- (void)create;
- (void)setmainview:(id)newmv;
- (void)keypress:(int)keyid;
@end

@interface MainView : UIView
{
	UITextView *mgrs1_textview;
	UITextView *mgrs2_textview;
	UITextView *latlon_textview;
	UIImageView *background_view;
	UIImage *bgimage;
	NumericKeyboardView *knumeric;
	char input_mode;
	char GZDSI[6];
	char eastnorth[12];
}
- (id)initWithFrame:(CGRect)frame;
- (void)set_GZD_SI:(char *)new_gzdsi;
- (void)set_eastnorth:(char *)new_eastnorth;
- (void)convert;
- (void)invoke_left;
- (void)invoke_right;
- (void)digit_pressed:(int)d;
- (void)ok_pressed;
- (void)bs_pressed;
- (void)dealloc;
@end

@interface MGRSapp : UIApplication
{
	UIWindow *window;
	MainView *mainView;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
@end
