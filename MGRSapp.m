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
	[ window _setHidden: NO ];
	//[ mainView setHidden: NO ];

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

- (void)dealloc
{
	[ self dealloc ];
	[ super dealloc ];
}

@end

@implementation MGRSLeft
- (void)mouseDown:(struct __GSEvent *)event {
	[ self setText: @"left" ];
	[ super mouseDown: event ];
}
@end

@implementation MGRSRight
- (void)mouseDown:(struct __GSEvent *)event {
	[ self setText: @"right" ];
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

		mgrs2_textview = [ [ MGRSRight alloc ] initWithFrame: mgrs2_textrect ];
		[ mgrs2_textview setText: @"" ];

		latlon_textview = [ [ MGRSText alloc ] initWithFrame: latlon_rect ];
		[ latlon_textview setText: @"" ];

		[ self addSubview: latlon_textview ];
		[ self addSubview: mgrs1_textview ];
		[ self addSubview: mgrs2_textview ];
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

- (void)dealloc
{
	[ self dealloc ];
	[ super dealloc ];
}

@end
