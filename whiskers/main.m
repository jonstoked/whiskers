//
//  main.m
//  whiskers
//
//  Created by Jon Stokes on 3/19/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTouchposeApplication.h"
#import "AppDelegate.h"
#import "Global.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal;
    if(!SHOW_TOUCHES) {
        retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    } else {
        retVal = UIApplicationMain(argc, argv,
                      NSStringFromClass([QTouchposeApplication class]),
                      NSStringFromClass([AppDelegate class]));
    }
    [pool release];
    return retVal;
}
