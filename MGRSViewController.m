#import "MGRSViewController.h"

/* Copyright (C) 2009-2016 Aero Teknic Inc.
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of version 2 of the GNU General Public License as
 published by the Free Software Foundation.
 */

@interface MGRSViewController ()

@end

@implementation MGRSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [ [ NSBundle mainBundle ]
                      pathForResource:@"mgrs.embedded.html" ofType:nil
                      ];
    NSURL *fileURL = [ [ NSURL alloc ] initFileURLWithPath:path ];
    NSURLRequest *req = [ NSURLRequest requestWithURL:fileURL ];
    
    [ webPage loadRequest:req ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
