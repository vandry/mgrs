#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIApplication.h>

@interface MGRSText : UILabel
{
	NSObject *parent;
}
- (id)initWithFrame:(CGRect)frame;
- (void)setText:(NSString *)t;
- (void)setmainview:(id)newmv;
- (void)dealloc;
@end

@interface MGRSTextHtml : UITextView
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
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface MGRSRight : MGRSText
{
	
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface KeyOverlay : NSObject
{
	int rows;
	int columns;
	float width;
	float height;
	UIImage *master;
	UIImageView **images;
	UIImageView **views;
	UIView **uiviews;
}
- (void)set_rows:(int)rows;
- (void)set_columns:(int)columns;
- (void)set_master:(NSString *)imagename;
- (UIView *)get_overlay:(int)keyid;
@end

@interface KeyboardView : UIView
{
	float width;
	float height;
	int rows;
	int columns;
	int down_keyid;
	unsigned char *disabled_flags;
	KeyOverlay *disabled;
	KeyOverlay *pressed;
	NSObject *parent;
	UIImage *normal_master;
	UIImageView *imageview;
}
- (id)initWithFrame:(CGRect)frame;
- (void)setmainview:(id)newmv;
- (void)set_image:(NSString *)imagename;
- (void)set_disabled_image:(NSString *)imagename;
- (void)set_pressed_image:(NSString *)imagename;
- (void)disable_key:(int)keyid;
- (void)enable_key:(int)keyid;
- (void)depress_key:(int)keyid;
- (void)unpress_key:(int)keyid;
- (int)keyid_from_event:(NSSet *)touches;
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)disappear;
- (void)dealloc;
@end

@interface Alpha1KeyboardView: KeyboardView
{
}
- (void)create;
- (void)keypress:(int)keyid;
@end

@interface Alpha2KeyboardView: KeyboardView
{
}
- (void)create;
- (void)keypress:(int)keyid;
@end

@interface NumericKeyboardView: KeyboardView
{
}
- (void)create;
- (void)keypress:(int)keyid;
@end

@interface MainView : UIView
{
	MGRSText *mgrs1_textview;
	MGRSText *mgrs2_textview;
	MGRSText *latlon_textview;
	UIImageView *background_view;
	UIImage *bgimage;
	NumericKeyboardView *knumeric;
	Alpha1KeyboardView *kalpha1;
	Alpha2KeyboardView *kalpha2;
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
- (void)letter_pressed:(char)l;
- (void)ok_pressed;
- (void)bs_pressed;
- (void)dealloc;
@end

@interface MGRSapp : UIApplication
{
	UIWindow *window;
	MainView *mainView;
	UIWebView *webView;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
@end
