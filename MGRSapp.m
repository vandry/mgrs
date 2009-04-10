#import "math.h"
#import "MGRSapp.h"

int main(int argc, char **argv)
{
	NSAutoreleasePool *autoreleasePool = [
		[ NSAutoreleasePool alloc ] init
	];
	int returnCode = UIApplicationMain(argc, argv, @"MGRSapp", @"MGRSapp");
	[ autoreleasePool release ];
	return returnCode;
}

@implementation MGRSapp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
}

@end

@implementation MainView

- (id)initWithFrame:(CGRect)rect {
	NSString *result_s;
	char *sample_mgrs = "18TXQ5763184896";
	double lat, lon;
	long result = Convert_MGRS_To_Geodetic(sample_mgrs, &lat, &lon);
	if (result) {
		result_s = [ NSString stringWithFormat:@"result=%x", result ];
	} else {
		lat = lat / M_PI * 180.0;
		lon = lon / M_PI * 180.0;
		result_s = [ NSString stringWithFormat:@"lat=%g lon=%g", lat, lon ];
	}

	self = [ super initWithFrame: rect ];
	if (nil != self) {
		textView = [ [ UITextView alloc ] initWithFrame: rect ];
		[ textView setText: result_s ];
		[ self addSubview: textView ];
	}

	return self;
}

- (void)dealloc
{
	[ self dealloc ];
	[ super dealloc ];
}

@end
