//
//  AppDelegate.m
//  whiskers
//
//  Created by Jon Stokes on 3/19/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "StartMenuScene.h"
#import "Global.h"
#import "HelloWorldScene.h"
#import "Appirater.h"
#import "QTouchposeApplication.h"

@implementation AppDelegate

@synthesize window, viewController;

+(AppDelegate *) get {
    
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
	//	CC_ENABLE_DEFAULT_GL_STATES();
	//	CCDirector *director = [CCDirector sharedDirector];
	//	CGSize size = [director winSize];
	//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	//	sprite.position = ccp(size.width/2, size.height/2);
	//	sprite.rotation = -90;
	//	[sprite visit];
	//	[[director openGLView] swapBuffers];
	//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{

    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
//    if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
//        [CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
    
    NSLog(@"window bounds: %@", NSStringFromCGRect(window.bounds));
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
    
    [glView setMultipleTouchEnabled:YES]; // only when you need multi touch

	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	[director setAnimationInterval:1.0/60];
	
	[viewController.view addSubview:glView];
    [window setRootViewController:viewController];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	[self removeStartupFlicker];
    	
	// Run the intro Scene
    if(!AUTO_START)
        [[CCDirector sharedDirector] runWithScene: [StartMenuScene scene]];
    else 
        [[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [Appirater setAppId:@"605524604"];
    [Appirater appLaunched:YES];
//    [Appirater setDebug:YES]; //review prompt happens every time app is launched
    
    if(SHOW_TOUCHES) {
        QTouchposeApplication *touchposeApplication = (QTouchposeApplication *)application;
        touchposeApplication.alwaysShowTouches = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

void uncaughtExceptionHandler(NSException *exception) {
    
    CCLOG(@"CRASH: %@", exception);
    CCLOG(@"Stack Trace: %@", [exception callStackSymbols]);
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
    [[GameManager sharedGameManager] saveToDisk];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    
	[[CCDirector sharedDirector] stopAnimation];
    [[GameManager sharedGameManager] saveToDisk];
    
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
    [Appirater appEnteredForeground:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
    
    [[GameManager sharedGameManager] saveToDisk];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
