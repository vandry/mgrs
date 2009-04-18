#import <math.h>
#import <string.h>
#import "MGRSapp.h"

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
fprintf(stderr, "x=%g y=%g width=%g height=%g\n", x, y, width, height);
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

	return self;
}

- (void)setText:(NSString *)t {
	[ self setContentToHTMLString:
		[ [
			@"<big><big><big><big>" stringByAppendingString: t
		] stringByAppendingString: @"</big></big></big></big>" ]
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

@implementation KeyboardView
- (id)initWithFrame:(CGRect)rect
{
	height = rect.size.width;
	width = rect.size.height;

	self = [ super initWithFrame: rect ];

	keys = NULL;

	return self;
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

	[ keys[0] setText: @"0" ];
	[ keys[1] setText: @"1" ];
	[ keys[2] setText: @"2" ];
	[ keys[3] setText: @"3" ];
	[ keys[4] setText: @"4" ];
	[ keys[5] setText: @"BS" ];
	[ keys[6] setText: @"5" ];
	[ keys[7] setText: @"6" ];
	[ keys[8] setText: @"7" ];
	[ keys[9] setText: @"8" ];
	[ keys[10] setText: @"9" ];
	[ keys[11] setText: @"OK" ];
}

- (void)setmainview:(id)newmv
{
	parent = newmv;
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

@implementation KeyView
- (void)setText:(NSString *)t {
	[ self setContentToHTMLString:
		[ [
			@"<big><big><big><big><big><big>" stringByAppendingString: t
		] stringByAppendingString: @"</big></big></big></big></big></big>" ]
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
	[ upper keypress: keyid ];
	[ super mouseDown: event ];
}
@end

@implementation MainView

- (id)initWithFrame:(CGRect)rect {
	CGRect mgrs1_textrect, mgrs2_textrect, latlon_rect;

	self = [ super initWithFrame: rect ];
	if (nil != self) {
		GZDSI[0] = 0;
		eastnorth[0] = 0;

		bgimage = [ UIImage applicationImageNamed:@"bg_normal.png" ];
		background_view = [ [ UIImageView alloc ] initWithImage: bgimage ];
		[ self addSubview: background_view ];

		mgrs1_textrect = uiposrect(20, 220, 200, 60);
		mgrs2_textrect = uiposrect(270, 220, 200, 60);
		latlon_rect = uiposrect(50, 70, 400, 60);

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
		[ knumeric setHidden: NO ];
		[ knumeric create ];
		[ knumeric setmainview: self ];
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
	char *sample_mgrs = "18TXQ5763184896";
	double lat, lon;

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
		[ latlon_textview setText: @"MGRS conversion error" ];
	} else {
		lat = lat / M_PI * 180.0;
		lon = lon / M_PI * 180.0;
		[ latlon_textview setText:
			[ NSString stringWithFormat:@"lat=%g lon=%g", lat, lon ]
		];
	}
}

- (void)invoke_right
{
	input_mode = 'r';
	[ self set_eastnorth: "" ];

	[ self addSubview: knumeric ];
}

- (void)digit_pressed:(int)digit
{
char buf[20];

	if (input_mode == 'l') {
		sprintf(buf, "%s%d", GZDSI, digit);
		[ self set_GZD_SI: buf ];
	} else {
		sprintf(buf, "%s%d", eastnorth, digit);
		[ self set_eastnorth: buf ];

		if (strlen(buf) == 10) {
			[ self ok_pressed ];
		}
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
	[ knumeric removeFromSuperview ];
	[ self convert ];
}

- (void)invoke_left
{
}

- (void)dealloc
{
	[ self dealloc ];
	[ super dealloc ];
}

@end
