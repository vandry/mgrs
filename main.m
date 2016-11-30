#import <math.h>
#import <string.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UIWebView.h>
//#import <GraphicsServices/GraphicsServices.h>
#import "MGRSapp.h"

/* Copyright (C) 2009-2016 Aero Teknic Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of version 2 of the GNU General Public License as
   published by the Free Software Foundation.
*/

int
main(int argc, char **argv)
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

	//[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UIViewController *vc = [[UIViewController alloc] init];
	
	window = [ [ UIWindow alloc ] initWithContentRect:
			  [[UIScreen mainScreen] applicationFrame]
			  ];
    /*/http://stackoverflow.com/questions/7520971/applications-are-expected-to-have-a-root-view-controller-at-the-end-of-applicati
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in windows) {
        if(window.rootViewController == nil){
            UIViewController* vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
            window.rootViewController = vc;
        }
    }*/
	
	
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	rect.origin.x = rect.origin.y = 0.0f;

	webView = [ [ UIWebView alloc] initWithFrame: rect ];
	webView.delegate = self;
	NSString *path = [ [ NSBundle mainBundle ]
		 pathForResource:@"mgrs.embedded.html" ofType:nil
	];
	NSURL *fileURL = [ [ NSURL alloc ] initFileURLWithPath:path ];
	NSURLRequest *req = [ NSURLRequest requestWithURL:fileURL ];
	[ webView loadRequest:req ];
	//[ window setContentView: webView ];
        [vc.view addSubview:webView];
	[ window orderFront: self ];
	[ window makeKey: self ];
    
    window.rootViewController = vc;

}

@end
