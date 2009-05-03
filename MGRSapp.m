#import <math.h>
#import <string.h>
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
		uiviews[keyid] = [
			[ UIView alloc ]
			initWithFrame: CGRectMake(x, y, bheight, bwidth)
		];
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

	keys = NULL;

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
	disabled = [ KeyOverlay alloc ];
	[ disabled set_rows: rows ];
	[ disabled set_columns: columns ];
	[ disabled set_master: imagename ];
}

- (void)disable_key:(int)keyid
{
	[ self addSubview: [ disabled get_overlay: keyid ] ];
}

- (void)enable_key:(int)keyid
{
	[ [ disabled get_overlay: keyid ] removeFromSuperview ];
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

- (void)mouseDown:(struct __GSEvent *)event {
fprintf(stderr, "kv down x=%g y=%g\n", GSEventGetDeltaX(event), GSEventGetDeltaY(event));
fflush(stderr);
	[ super mouseDown: event ];
}

- (void)mouseUp:(struct __GSEvent *)event {
fprintf(stderr, "kv up x=%g y=%g\n", GSEventGetDeltaX(event), GSEventGetDeltaY(event));
fflush(stderr);
	[ super mouseDown: event ];
}

- (void)create_keys
{
int i, j;
KeyView *k;
CGRect r;
float bwidth, bheight;

	keys = malloc(sizeof(*keys) * rows * columns);

	bwidth = width / columns;
	bheight = height / rows;

	for (i = 0; i < rows; i++) {
		for (j = 0; j < columns; j++) {
			r = uiposrect(
				j * bwidth,
				(rows-i-1) * bheight,
				bwidth, bheight
			);
			k = [ [ KeyView alloc ] initWithFrame: r ];
			keys[i*columns + j] = k;
			[ k setkv: self ];
			[ k setid: i*columns + j ];
			[ self addSubview: k ];
		}
	}
}

- (void)setmainview:(id)newmv
{
	parent = newmv;
}

- (void)dealloc
{
int i;

	if (keys) {
		for (i = 0; i < (rows * columns); i++) {
			[ keys[i] dealloc ];
		}
		free(keys);
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
	[ self create_keys ];
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
	[ self create_keys ];

	for (i = 0; i < 18; i++) {
		[ keys[i] setText: [ NSString stringWithFormat:@"%c", alpha1_keys[i] ] ];
	}
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
	[ self create_keys ];

	for (i = 0; i < 6; i++) {
		[ keys[i] setText: [ NSString stringWithFormat:@"%c", alpha2_keys[i] ] ];
	}
}

- (void)keypress:(int)keyid
{
	[ parent letter_pressed: alpha1_keys[keyid] ];
}
@end

@implementation KeyView
- (void)setText:(NSString *)t {
	[ self setContentToHTMLString:
		[ [
			@"<center><big><big><big><big><big><big>"
			stringByAppendingString: t
		] stringByAppendingString: @"</big></big></big></big></big></big></center>" ]
	];
}
- (void)setkv:(id)newparent
{
	upper = newparent;
}
- (void)setid:(int)newkeyid
{
	keyid = newkeyid;
}
- (void)mouseDown:(struct __GSEvent *)event {
fprintf(stderr, "down %d\n", keyid);
	[ upper depress_key: keyid ];
	[ super mouseDown: event ];
}
- (void)mouseUp:(struct __GSEvent *)event {
fprintf(stderr, "up %d\n", keyid);
	[ upper unpress_key: keyid ];
	[ upper keypress: keyid ];
	[ super mouseDown: event ];
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

		mgrs1_textrect = uiposrect(20, 240, 200, 60);
		mgrs2_textrect = uiposrect(270, 240, 200, 60);
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
		[ kalpha1 setHidden: NO ];
		[ kalpha1 create ];
		[ kalpha1 setmainview: self ];

		kalpha2 = [ [ Alpha2KeyboardView alloc ] initWithFrame: CGRectMake(192, 240, 128, 240) ];
		[ kalpha2 setHidden: NO ];
		[ kalpha2 create ];
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
		frlat = (long)(rint(lat * 3600000.0));
		frlon = (long)(rint(lon * 3600000.0));
		
		[ latlon_textview setText:
			[ NSString
//				stringWithFormat:@"%d&#176; %d\' %g\'\' %c<br />%d&#176; %d\' %g\'\' %c",
				stringWithFormat:@
					"<table width=\"100%\" border=\"0\"><tr><td>%d&#176;</td>"
					"<td>%d\'</td><td>%g\'\'</td><td>%c</td></tr>"
					"<tr><td>%d&#176;</td><td>%d\'</td>"
					"<td>%g\'\'</td><td>%c</td></tr></table>",

				abs(frlat / 3600000),
				abs(frlat / 60000) % 60,
				((double)(abs(frlat) % 60000)) / 1000.0,
				(lat > 0) ? 'N' : 'S',

				abs(frlon / 3600000),
				abs(frlon / 60000) % 60,
				((double)(abs(frlon) % 60000)) / 1000.0,
				(lon > 0) ? 'E' : 'W'
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
			[ kalpha1 removeFromSuperview ];
			[ kalpha2 removeFromSuperview ];
		}
		if (input_mode != 'r') {
			[ self addSubview: knumeric ];
		}
		input_mode = 'l';
	}
}

- (void)invoke_right
{
	[ self set_eastnorth: "" ];

	if (input_mode != 'r') {
		if (input_mode == 'a') {
			[ kalpha1 removeFromSuperview ];
			[ kalpha2 removeFromSuperview ];
		}
		if (input_mode != 'l') {
			[ self addSubview: knumeric ];
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
			[ knumeric removeFromSuperview ];
			input_mode = 'a';
			[ self addSubview: kalpha1 ];
			[ self addSubview: kalpha2 ];
		}
	} else {
		sprintf(buf, "%s%d", eastnorth, digit);
		[ self set_eastnorth: buf ];

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
	[ knumeric removeFromSuperview ];
	[ self convert ];
}

- (void)dealloc
{
	[ self dealloc ];
	[ super dealloc ];
}

@end
