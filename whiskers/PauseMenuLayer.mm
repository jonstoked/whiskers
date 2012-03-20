//
//  PauseMenuLayer.mm
//  cake
//
//  Created by Jon Stokes on 4/14/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "PauseMenuLayer.h"


@implementation PauseMenuLayer

-(id) init
{
	if( (self=[super init])) 
	{
	
		self.isTouchEnabled = YES;
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		/*
		CCColorLayer* colorLayer = [CCColorLayer layerWithColor:ccc4(150, 150, 150, 150) width:screenSize.width/4 height:screenSize.height/4]; 
		//self.anchorPoint = CGPointMake(0.5, 0.5);
		[self addChild:colorLayer z:0];
		colorLayer.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
*/
		
		
		// set CCMenuItemFont default properties
		[CCMenuItemFont setFontName:@"Courier"];
		[CCMenuItemFont setFontSize:46];
		
		
		// create a few labels with text and selector
		CCMenuItemFont* item1 = [CCMenuItemFont itemFromString:@"Restart" target:self selector:@selector(menuItem1Touched:)];
		CCMenuItemFont* item2 = [CCMenuItemFont itemFromString:@"Resume" target:self selector:@selector(menuItem1Touched:)];
        CCMenuItemFont* item3 = [CCMenuItemFont itemFromString:@"Music: Off" target:self selector:@selector(musicToggleTouched:)];


		
		// create the menu using the items
		CCMenu* menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
		menu.tag = 200;
        [menu setColor:ccWHITE];
		[self addChild:menu z:1];
		
		// calling one of the align methods is important, otherwise all labels will occupy the same location
		[menu alignItemsVerticallyWithPadding:40];
		
	}
	
	return self;
	
}

-(void) menuItem1Touched:(id)sender {
	
	//[[CCDirector sharedDirector] replaceScene:[StartMenuScene scene]];
		[HelloWorld resetGame];
	
}

-(void) menuItem2Touched:(id)sender {
	
	//[[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
	//[HelloWorld unpause];
	[HelloWorld unpause];
		
}

-(void) musicToggleTouched:(id)sender {
    CCLOG(@"musicOn: %i", [[GameManager sharedGameManager] musicOn]);
    
    if([[GameManager sharedGameManager] musicOn])
    {
        [[GameManager sharedGameManager] setMusicOn:NO];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
    else
    {
        [[GameManager sharedGameManager] setMusicOn:YES];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MapleLeafRag.mp3" loop:YES];
    }    
}

@end
