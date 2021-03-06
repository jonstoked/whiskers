//
//  AppDelegate.h
//  whiskers
//
//  Created by Jon Stokes on 3/19/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) RootViewController * viewController;


+(AppDelegate *) get;


@end
