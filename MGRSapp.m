#import <math.h>
#import <string.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <GraphicsServices/GraphicsServices.h>
#import "MGRSapp.h"
#include "mgrslib/mgrs.h"

int
main(int argc, char **argv)
{
FILE *fp = fopen("/tmp/washere", "w");
dup2(fileno(fp), 2);
	NSAutoreleasePool *autoreleasePool = [
		[ NSAutoreleasePool alloc ] init
	];
	UIApplicationUseLegacyEvents(YES);
	int returnCode = UIApplicationMain(argc, argv, @"MGRSapp", @"MGRSapp");
	[ autoreleasePool release ];
	return returnCode;
}

static CGRect
uiposrect(float x, float y, float width, float height)
{
	/* pass the lower left corner of the coordinates of this rectangle
	   in the superview */
	return CGRectMake(
		floor(y + height/2 - width/2),
		floor(x + width/2 - height/2),
		width, height
	);
}

@implementation MGRSapp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[ UIHardware _setStatusBarHeight: 0.0 ];
	//[ self setStatusBarHidden: YES ];
	[ [ UIApplication sharedApplication ] setStatusBarHidden:YES ];

	window = [ [ UIWindow alloc ] initWithContentRect:
		[ UIHardware fullScreenApplicationContentRect ]
	];

	CGRect rect = [ UIHardware fullScreenApplicationContentRect ];
	rect.origin.x = rect.origin.y = 0.0f;

	mainView = [ [ MainView alloc ] initWithFrame: rect ];

	[ window setContentView: mainView ];
	[ window orderFront: self ];
	[ window makeKey: self ];

	[ mainView setHidden: NO ];
	[ mainView set_GZD_SI: "18TXQ" ];
	[ mainView set_eastnorth: "5763184896" ];
	[ mainView convert ];
}

@end

@implementation MGRSText
- (id)initWithFrame:(CGRect)rect {
	self = [ super initWithFrame: rect ];
	[ self setRotationBy: 90 ];
	[ self setEditable: NO ];
	UIColor *background = [ UIColor clearColor ];
	self.backgroundColor = background;

	return self;
}

- (void)setText:(NSString *)t {
	[ self setContentToHTMLString:
		[ [
			@"<center><big><big><big><big>" stringByAppendingString: t
		] stringByAppendingString: @"</big></big></big></big></center>" ]
	];
}

- (void)setmainview:(id)newmv
{
	parent = newmv;
}

- (void)dealloc
{
	[ self dealloc ];
	[ super dealloc ];
}
@end

@implementation MGRSLeft
- (void)mouseDown:(struct __GSEvent *)event {
	[ parent invoke_left ];
	[ super mouseDown: event ];
}
@end

@implementation MGRSRight
- (void)mouseDown:(struct __GSEvent *)event {
	[ parent invoke_right ];
	[ super mouseDown: event ];
}
@end

@implementation KeyOverlay
- (void)set_rows:(int)newrows
{
	rows = newrows;
}

- (void)set_columns:(int)newcols
{
	columns = newcols;
}

- (void)set_master:(NSString *)imagename
{
int nkeys = rows * columns;
int i;

	master = [ UIImage applicationImageNamed: imagename ];

	height = master.size.width;
	width = master.size.height;

	images = malloc(sizeof(*images) * nkeys);
	views = malloc(sizeof(*views) * nkeys);
	uiviews = malloc(sizeof(*uiviews) * nkeys);
	for (i = 0; i < nkeys; i++) {
		images[i] = NULL;
	}
}

- (UIView *)get_overlay:(int)keyid
{
int row, col;
float bwidth, bheight;

	bwidth = width / columns;
	bheight = height / rows;

	row = keyid / columns;
	col = keyid % columns;

	if (!(images[keyid])) {
		/* first reference, create the image */
		float x = (rows - row - 1) * bheight;
		float y = col * bwidth;

		CGImageRef newcgim = CGImageCreateWithImageInRect(
			[ master imageRef ],
			CGRectMake(x, y, bheight, bwidth)
		);
		images[keyid] = [ UIImage imageWithCGImage:newcgim ];
		views[keyid] = [ [ UIImageView alloc ] initWithImage:
			images[keyid]
		];
		uiviews[keyid] = [ [
			[ UIView alloc ]
			initWithFrame: CGRectMake(x, y, bheight, bwidth)
		] retain ];
		[ uiviews[keyid] addSubview: views[keyid] ];
	}

	return uiviews[keyid];
}
@end

@implementation KeyboardView
- (id)initWithFrame:(CGRect)rect
{
	height = rect.size.width;
	width = rect.size.height;

	self = [ super initWithFrame: rect ];

	down_keyid = -1;

	return self;
}

- (void)set_image:(NSString *)imagename
{
	normal_master = [ UIImage applicationImageNamed: imagename ];
	imageview = [ [ UIImageView alloc ] initWithImage: normal_master ];
	[ self addSubview: imageview ];
}

- (void)set_disabled_image:(NSString *)imagename
{
int nkeys = rows * columns;
int i;

	disabled = [ KeyOverlay alloc ];
	disabled_flags = malloc(nkeys * sizeof(*disabled_flags));
	[ disabled set_rows: rows ];
	[ disabled set_columns: columns ];
	[ disabled set_master: imagename ];
	for (i = 0; i < nkeys; i++) disabled_flags[i] = 0;
}

- (void)disable_key:(int)keyid
{
	if (!(disabled_flags[keyid])) {
		[ self addSubview: [ disabled get_overlay: keyid ] ];
		disabled_flags[keyid] = 1;
	}
}

- (void)enable_key:(int)keyid
{
	if (disabled_flags[keyid]) {
		[ [ disabled get_overlay: keyid ] removeFromSuperview ];
		disabled_flags[keyid] = 0;
	}
}

- (void)set_pressed_image:(NSString *)imagename
{
	pressed = [ KeyOverlay alloc ];
	[ pressed set_rows: rows ];
	[ pressed set_columns: columns ];
	[ pressed set_master: imagename ];
}

- (void)depress_key:(int)keyid
{
	[ self addSubview: [ pressed get_overlay: keyid ] ];
}

- (void)unpress_key:(int)keyid
{
	[ [ pressed get_overlay: keyid ] removeFromSuperview ];
}

- (int)keyid_from_event:(struct __GSEvent *)event {
CGPoint loc;
float bwidth, bheight;
int row, column;

	bwidth = width / columns;
	bheight = height / rows;

	loc = [ self convertPoint:GSEventGetLocationInWindow(event) fromView:nil ];

	column = loc.y / bwidth;
	row = rows - ((int)(loc.x / bheight)) - 1;

	if (row < 0) { row = 0; column = 0; }

	return row * columns + column;
}

- (void)mouseDown:(struct __GSEvent *)event
{
int keyid;

	keyid = [ self keyid_from_event: event ];
	if (
		(!disabled) ||	/* if either disabling is not active */
		(!(disabled_flags[keyid]))	/* or this key is not disabled */
	) {
		/* then proceed */
		if (down_keyid >= 0) {
			[ self unpress_key: down_keyid ];
		}
		down_keyid = keyid;
		[ self depress_key: down_keyid ];
	}
	[ super mouseDown: event ];
}

- (void)mouseUp:(struct __GSEvent *)event
{
int keyid;

	keyid = [ self keyid_from_event: event ];
	if (down_keyid >= 0) {
		[ self unpress_key: down_keyid ];
		if (down_keyid == keyid) {
			/* only react if we "up" on the same key as we "down"ed */
			[ self keypress: keyid ];
		}
		down_keyid = -1;
	}
	[ super mouseDown: event ];
}

- (void)setmainview:(id)newmv
{
	parent = newmv;
}

- (void)disappear
{
int nkeys = rows * columns;
int i;

	if (disabled) {
		for (i = 0; i < nkeys; i++) {
			if (disabled_flags[i]) {
				[ self enable_key: i ];
			}
		}
	}
	if (down_keyid >= 0) {
		[ self unpress_key: down_keyid ];
		down_keyid = -1;
	}
	[ self removeFromSuperview ];
}

- (void)dealloc
{
int i;

	if (disabled) {
		free(disabled_flags);
		[ disabled dealloc ];
	}
	if (pressed) {
		[ pressed dealloc ];
	}
	[ self dealloc ];
	[ super dealloc ];
}
@end

@implementation NumericKeyboardView
- (void)create
{
	rows = 2;
	columns = 6;
}

- (void)keypress:(int)keyid
{
	if (keyid < 5) {
		[ parent digit_pressed: keyid ];
	} else if (keyid == 5) {
		[ parent bs_pressed ];
	} else if (keyid < 11) {
		[ parent digit_pressed: keyid-1 ];
	} else {
		[ parent ok_pressed ];
	}
}
@end

@implementation Alpha1KeyboardView
const char *alpha1_keys = "GHJKLMNPQRSTUVWXYZ";
- (void)create
{
int i;

	rows = 3;
	columns = 6;
}

- (void)keypress:(int)keyid
{
	[ parent letter_pressed: alpha1_keys[keyid] ];
}
@end

@implementation Alpha2KeyboardView
const char *alpha2_keys = "ABCDEF";
- (void)create
{
int i;

	rows = 2;
	columns = 3;
}

- (void)keypress:(int)keyid
{
	[ parent letter_pressed: alpha2_keys[keyid] ];
}
@end

@implementation MainView

- (id)initWithFrame:(CGRect)rect {
	CGRect mgrs1_textrect, mgrs2_textrect, latlon_rect;

	input_mode = 0;

	self = [ super initWithFrame: rect ];
	if (nil != self) {
		GZDSI[0] = 0;
		eastnorth[0] = 0;

		bgimage = [ UIImage applicationImageNamed:@"bg_normal.png" ];
		background_view = [ [ UIImageView alloc ] initWithImage: bgimage ];
		[ self addSubview: background_view ];

		mgrs1_textrect = uiposrect(20, 220, 200, 60);
		mgrs2_textrect = uiposrect(270, 220, 200, 60);
		latlon_rect = uiposrect(70, 70, 350, 90);

		mgrs1_textview = [ [ MGRSLeft alloc ] initWithFrame: mgrs1_textrect ];
		[ mgrs1_textview setText: @"" ];
		[ mgrs1_textview setmainview: self ];

		mgrs2_textview = [ [ MGRSRight alloc ] initWithFrame: mgrs2_textrect ];
		[ mgrs2_textview setText: @"" ];
		[ mgrs2_textview setmainview: self ];

		latlon_textview = [ [ MGRSText alloc ] initWithFrame: latlon_rect ];
		[ latlon_textview setText: @"" ];

		[ self addSubview: latlon_textview ];
		[ self addSubview: mgrs1_textview ];
		[ self addSubview: mgrs2_textview ];

		knumeric = [ [ NumericKeyboardView alloc ] initWithFrame: CGRectMake(0, 0, 160, 480) ];
		[ knumeric set_image: @"numeric_keyboard_normal.png" ];
		[ knumeric setHidden: NO ];
		[ knumeric create ];
		[ knumeric set_disabled_image: @"numeric_keyboard_disabled.png" ];
		[ knumeric set_pressed_image: @"numeric_keyboard_pressed.png" ];
		[ knumeric setmainview: self ];

		kalpha1 = [ [ Alpha1KeyboardView alloc ] initWithFrame: CGRectMake(0, 0, 192, 480) ];
		[ kalpha1 set_image: @"alpha1_keyboard_normal.png" ];
		[ kalpha1 setHidden: NO ];
		[ kalpha1 create ];
		[ kalpha1 set_disabled_image: @"alpha1_keyboard_disabled.png" ];
		[ kalpha1 set_pressed_image: @"alpha1_keyboard_pressed.png" ];
		[ kalpha1 setmainview: self ];

		kalpha2 = [ [ Alpha2KeyboardView alloc ] initWithFrame: CGRectMake(192, 240, 128, 240) ];
		[ kalpha2 set_image: @"alpha2_keyboard_normal.png" ];
		[ kalpha2 setHidden: NO ];
		[ kalpha2 create ];
		[ kalpha2 set_disabled_image: @"alpha2_keyboard_disabled.png" ];
		[ kalpha2 set_pressed_image: @"alpha2_keyboard_pressed.png" ];
		[ kalpha2 setmainview: self ];
	}

	return self;
}

- (void)set_GZD_SI:(char *)new_gzdsi {
	strcpy(GZDSI, new_gzdsi);
	[ mgrs1_textview setText: [ NSString stringWithFormat:@"%s", new_gzdsi ] ];
}

- (void)set_eastnorth:(char *)new_eastnorth {
	strcpy(eastnorth, new_eastnorth);
	[ mgrs2_textview setText: [ NSString stringWithFormat:@"%s", new_eastnorth ] ];
}

- (void)convert {
char buf[20];
NSString *degree;
char *sample_mgrs = "18TXQ5763184896";
double lat, lon;
long frlat, frlon;

	if (
		(strlen(GZDSI) != 5) ||
		(!((GZDSI[0] >= '0') && (GZDSI[0] <= '9'))) ||
		(!((GZDSI[1] >= '0') && (GZDSI[1] <= '9'))) ||
		(!((GZDSI[2] >= 'C') && (GZDSI[2] <= 'X'))) ||
		(!((GZDSI[3] >= 'A') && (GZDSI[3] <= 'Z'))) ||
		(!((GZDSI[4] >= 'A') && (GZDSI[4] <= 'Z'))) ||
		(GZDSI[2] == 'I') || (GZDSI[2] == 'O') ||
		(GZDSI[3] == 'I') || (GZDSI[3] == 'O') ||
		(GZDSI[4] == 'I') || (GZDSI[4] == 'O') ||
		(strlen(eastnorth) & 1) ||
		(strlen(eastnorth) < 2) ||
		(strlen(eastnorth) > 10)
	) {
		[ latlon_textview setText: @"Syntax error in MGRS" ];
		return;
	}

	sprintf(buf, "%s%s", GZDSI, eastnorth);

	long result = Convert_MGRS_To_Geodetic(buf, &lat, &lon);

	if (result) {
		if (result & MGRS_LAT_ERROR) {
			[ latlon_textview setText: @"Latitude outside of valid range" ];
		} else if (result & MGRS_LON_ERROR) {
			[ latlon_textview setText: @"Longitude outside of valid range" ];
		} else if (result & MGRS_STRING_ERROR) {
			[ latlon_textview setText: @"MGRS string format error" ];
		} else if (result & MGRS_PRECISION_ERROR) {
			[ latlon_textview setText: @"MGRS precision error" ];
		} else if (result & MGRS_A_ERROR) {
			[ latlon_textview setText: @"Semi-major axis <= 0" ];
		} else if (result & MGRS_INV_F_ERROR) {
			[ latlon_textview setText: @"Inverse flattening outside range" ];
		} else if (result & MGRS_EASTING_ERROR) {
			[ latlon_textview setText: @"Easting outside range" ];
		} else if (result & MGRS_NORTHING_ERROR) {
			[ latlon_textview setText: @"Northing outside range" ];
		} else if (result & MGRS_ZONE_ERROR) {
			[ latlon_textview setText: @"Zone outside range" ];
		} else if (result & MGRS_HEMISPHERE_ERROR) {
			[ latlon_textview setText: @"Invalid hemisphere" ];
		} else {
			[ latlon_textview setText: @"Unknown MGRS conversion error" ];
		}
	} else {
		lat = lat / M_PI * 180.0;
		lon = lon / M_PI * 180.0;
#ifdef STUPIDLY_PRECISE
		frlat = (long)(rint(lat * 3600000.0));
		frlon = (long)(rint(lon * 3600000.0));
#else
		frlat = (long)(rint(lat * 6000.0));
		frlon = (long)(rint(lon * 6000.0));
#endif
		
		[ latlon_textview setText:
			[ NSString
#ifdef STUPIDLY_PRECISE
				stringWithFormat:@
					"<font face=\"Courier\">"
					"<table cellspacing=\"5\" border=\"0\">"
					"<tr><td align=\"right\">%d&#176;</td>"
					"<td align=\"right\">%d\'</td>"
					"<td align=\"right\">%g\'\'</td><td>%c</td></tr>"
					"<tr><td align=\"right\">%d&#176;</td>"
					"<td align=\"right\">%d\'</td>"
					"<td align=\"right\">%g\'\'</td><td>%c</td></tr></table>"
					"</font>",

				abs(frlat / 3600000),
				abs(frlat / 60000) % 60,
				((double)(abs(frlat) % 60000)) / 1000.0,
				(lat > 0) ? 'N' : 'S',

				abs(frlon / 3600000),
				abs(frlon / 60000) % 60,
				((double)(abs(frlon) % 60000)) / 1000.0,
				(lon > 0) ? 'E' : 'W'
#else
				stringWithFormat:@
					"<font face=\"Courier\"><b>"
					"<table cellspacing=\"5\" border=\"0\">"
					"<tr><td align=\"right\">%d&#176;</td>"
					"<td align=\"right\">%.2f\'</td><td>%c</td></tr>"
					"<tr><td align=\"right\">%d&#176;</td>"
					"<td align=\"right\">%.2f\'</td><td>%c</td></tr></table>"
					"</b></font>",

				abs(frlat / 6000),
				((double)(abs(frlat) % 6000)) / 100.0,
				(lat > 0) ? 'N' : 'S',

				abs(frlon / 6000),
				((double)(abs(frlon) % 6000)) / 100.0,
				(lon > 0) ? 'E' : 'W'
#endif
			]
		];
	}
}

- (void)invoke_left
{
	[ self set_eastnorth: "" ];
	[ self set_GZD_SI: "" ];

	if (input_mode != 'l') {
		if (input_mode == 'a') {
			[ kalpha1 disappear ];
			[ kalpha2 disappear ];
		}
		if (input_mode != 'r') {
			[ self addSubview: knumeric ];
			[ knumeric disable_key: 11 ];	/* OK key */
		}
		input_mode = 'l';
	}
}

- (void)invoke_right
{
	[ self set_eastnorth: "" ];

	if (input_mode != 'r') {
		if (input_mode == 'a') {
			[ kalpha1 disappear ];
			[ kalpha2 disappear ];
		}
		if (input_mode != 'l') {
			[ self addSubview: knumeric ];
			[ knumeric disable_key: 11 ];	/* OK key */
		}
		input_mode = 'r';
	}
}

- (void)digit_pressed:(int)digit
{
char buf[20];

	if (input_mode == 'l') {
		sprintf(buf, "%s%d", GZDSI, digit);
		[ self set_GZD_SI: buf ];

		if (strlen(buf) == 2) {
			[ knumeric disappear ];
			input_mode = 'a';
			[ self addSubview: kalpha1 ];
			[ self addSubview: kalpha2 ];
			/* only C..X valid as grid zone designation latitude bands */
			[ kalpha2 disable_key: 0 ];	/* A */
			[ kalpha2 disable_key: 1 ];	/* B */
			[ kalpha1 disable_key: 16 ];	/* Y */
			[ kalpha1 disable_key: 17 ];	/* Z */
		}
	} else {
		sprintf(buf, "%s%d", eastnorth, digit);
		[ self set_eastnorth: buf ];

		if ((strlen(buf) & 1) == 0) {
			/* even number of digits */
			[ knumeric enable_key: 11 ];	/* OK key */
		} else {
			[ knumeric disable_key: 11 ];	/* OK key */
		}

		if (strlen(buf) == 10) {
			[ self ok_pressed ];
		}
	}
}

- (void)letter_pressed:(char)l
{
char buf[20];

	sprintf(buf, "%s%c", GZDSI, l);
	[ self set_GZD_SI: buf ];

	if (strlen(buf) == 5) {
		[ self invoke_right ];
	} else if (strlen(buf) == 3) {
		/* 100 000 square ID starts here. All letters valid */
		[ kalpha2 enable_key: 0 ];	/* A */
		[ kalpha2 enable_key: 1 ];	/* B */
		[ kalpha1 enable_key: 16 ];	/* Y */
		[ kalpha1 enable_key: 17 ];	/* Z */
	} else if (strlen(buf) == 4) {
		/* second letter of 100 000 square ID. Only A..V valid */
		[ kalpha1 disable_key: 14 ];	/* W */
		[ kalpha1 disable_key: 15 ];	/* X */
		[ kalpha1 disable_key: 16 ];	/* Y */
		[ kalpha1 disable_key: 17 ];	/* Z */
	}
}

- (void)bs_pressed
{
char buf[20];

	if (input_mode == 'l') {
		strcpy(buf, GZDSI);
	} else {
		strcpy(buf, eastnorth);
	}
	if (buf[0]) {
		buf[strlen(buf)-1] = 0;
		if (input_mode == 'l') {
			[ self set_GZD_SI: buf ];
		} else {
			[ self set_eastnorth: buf ];
		}
	}
}

- (void)ok_pressed
{
	input_mode = 0;
	[ knumeric disappear ];
	[ self convert ];
}

- (void)dealloc
{
	[ self dealloc ];
	[ super dealloc ];
}

@end
