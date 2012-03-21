//
//  StartMenuScene.mm
//  cake
//
//  Created by Jon Stokes on 4/11/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "StartMenuScene.h"
#import "HelloWorldScene.h"
#import "MustacheScene.h"
#import "SimpleAudioEngine.h"
#import	"MustacheSelectNode.h"
#import "GameOverScene.h"
#import "GameConstants.h"
#import "PowerupsScene.h"



@implementation StartMenuScene

+(id) scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [StartMenuScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		kittyScale = 2.0f;
		int screenHeight = screenSize.height;
        
        if([[GameManager sharedGameManager] musicOn])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"HeliotropeBouquet2.mp3" loop:YES];
		
		CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)]; 
		[self addChild:colorLayer z:-10];
		
        if(!CRAZY_START_SCREEN) {
            
            //play button
            CCSprite *playButtonSprite = [CCSprite spriteWithFile:@"playButton.png"];
            CCSprite *playButtonDepressedSprite = [CCSprite spriteWithFile:@"playButtonDepressed.png"];
            CCMenuItemSprite *playButton = [CCMenuItemSprite itemFromNormalSprite:playButtonSprite selectedSprite:playButtonDepressedSprite 
                                                                   disabledSprite:nil target:self selector:@selector(playButtonTouched:)];
            
            //offset depressed sprite so it looks as if button drops directly onto the dropshadow
            playButtonDepressedSprite.anchorPoint = ccp(-4.0/playButtonDepressedSprite.contentSize.width,0);
            
            
            //optionsbutton
            CCSprite *optionsButtonSprite = [CCSprite spriteWithFile:@"optionsButton.png"];
            CCSprite *optionsButtonDepressedSprite = [CCSprite spriteWithFile:@"optionsButtonDepressed.png"];
            CCMenuItemSprite *optionsButton = [CCMenuItemSprite itemFromNormalSprite:optionsButtonSprite selectedSprite:optionsButtonDepressedSprite disabledSprite:nil target:self selector:@selector(optionsButtonTouched:)];
            
            //offset depressed sprite so it looks as if button drops directly onto the dropshadow
            optionsButtonDepressedSprite.anchorPoint = ccp(-4.0/optionsButtonDepressedSprite.contentSize.width,0);
            
            
            //powerups button
            CCSprite *powerupsButtonSprite = [CCSprite spriteWithFile:@"powerupsButton.png"];
            CCSprite *powerupsButtonDepressedSprite = [CCSprite spriteWithFile:@"powerupsButtonDepressed.png"];
            CCMenuItemSprite *powerupsButton = [CCMenuItemSprite itemFromNormalSprite:powerupsButtonSprite selectedSprite:powerupsButtonDepressedSprite disabledSprite:nil target:self selector:@selector(powerupsButtonTouched:)];
            
            //offset depressed sprite so it looks as if button drops directly onto the dropshadow
            powerupsButtonDepressedSprite.anchorPoint = ccp(-4.0/powerupsButtonDepressedSprite.contentSize.width,0);
            
            
            CCMenu* playMenu = [CCMenu menuWithItems:playButton, nil];
            CCMenu* optionsMenu = [CCMenu menuWithItems:optionsButton, nil];
            CCMenu* powerupsMenu = [CCMenu menuWithItems:powerupsButton, nil];
            
            //position values taken directly from AI file
            playMenu.position = CGPointMake(652, screenHeight-490);
            optionsMenu.position = CGPointMake(686, screenHeight-576);
            powerupsMenu.position = CGPointMake(729, screenHeight-662); 
            
            [self addChild:playMenu];
            [self addChild:optionsMenu];
            [self addChild:powerupsMenu];
            
            //add the logo
            CCSprite *logo = [CCSprite spriteWithFile:@"whiskersLogo.png"];
            logo.position = CGPointMake(512, screenHeight-232);
            [self addChild:logo];
            
        }
        
        else {
            
            //add the logo
            CCSprite *logo = [CCSprite spriteWithFile:@"whiskersLogo.png"];
            logo.position = ccp(screenSize.width/2.0f, screenSize.height/2.0f);
            [self addChild:logo];
            
            float t = 0.25f;
            id move = [CCMoveTo actionWithDuration:t position:ccp(571 + 413/2, screenHeight-177 - 177/2)];
            id shrink = [CCScaleTo actionWithDuration:t scale:0.557951482];
            [logo runAction:move];
            [logo runAction:shrink];
            [self showMenu];
        }
            
		
	}	
	return self;
}

-(void) showMenu {
    
    int screenHeight = [[CCDirector sharedDirector] winSize].height;
    float t = 1.0f;
    
    //play button
    CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:@"playButton2.png" selectedImage:@"playButton2.png" target:self selector:@selector(playButtonTouched:)];
    float shrinkScale = 0.97f;
    playButton.selectedImage.scale = shrinkScale;
    playButton.selectedImage.position = ccp((playButton.normalImage.contentSize.width - playButton.normalImage.contentSize.width*shrinkScale)/2.0f, (playButton.normalImage.contentSize.height - playButton.normalImage.contentSize.height*shrinkScale)/2.0f);
    
    //powerups button
    powerupsButton = [CCMenuItemImage itemFromNormalImage:@"powerupsButton2.png" selectedImage:@"powerupsButton2.png" target:self selector:@selector(powerupsButtonTouched:)];
    powerupsButton.selectedImage.scale = shrinkScale;
    powerupsButton.selectedImage.position = ccp((powerupsButton.normalImage.contentSize.width - powerupsButton.normalImage.contentSize.width*shrinkScale)/2.0f, (powerupsButton.normalImage.contentSize.height - powerupsButton.normalImage.contentSize.height*shrinkScale)/2.0f);
    powerupsButton.tag = 1;
    
    CCMenu* playMenu = [CCMenu menuWithItems:playButton, nil];
    CCMenu* powerupsMenu = [CCMenu menuWithItems:powerupsButton, nil];
    
    //position values taken directly from AI file
    playMenu.position = CGPointMake(300 - [[CCDirector sharedDirector] winSize].width, screenHeight-275);
    powerupsMenu.position = CGPointMake(512 - [[CCDirector sharedDirector] winSize].width, screenHeight-468); 
    
    [self addChild:playMenu];
    [self addChild:powerupsMenu];
    
    CCSprite *logo2 = [CCSprite spriteWithFile:@"byJonStokes.png"];
    logo2.position = CGPointMake(581 - [[CCDirector sharedDirector] winSize].width, screenHeight-561);
    logo2.anchorPoint = ccp(0,1.0f);
    [self addChild:logo2];
    logo2.tag = 2;
    
    float t2 = 0.1f;
    id movein = [CCMoveBy actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width, 0)];
    [playButton runAction:movein];
    [self schedule:@selector(moveInPowerupsButton) interval:t2];
    [self schedule:@selector(moveInLogo2) interval:t2*2];

    

}

-(void) moveInPowerupsButton {
    
    [self unschedule:@selector(moveInPowerupsButton)];
    id movein = [CCMoveBy actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width, 0)];
    [powerupsButton runAction:movein];
}

-(void) moveInLogo2 {
    [self unschedule:@selector(moveInLogo2)];
    id logo2 = [self getChildByTag:2];
    id movein = [CCMoveBy actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width, 0)];
    [logo2 runAction:movein];
}



-(void) playButtonTouched:(id)sender {
	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCDirector sharedDirector] replaceScene:[MustacheScene scene]];
	
	
}

-(void) optionsButtonTouched:(id)sender {
	
	CCLOG(@"Options Touched!");
	
	
}

-(void) powerupsButtonTouched:(id)sender {
	
	CCLOG(@"Options Touched!");
    [[CCDirector sharedDirector] replaceScene:[PowerupsScene scene]];

	
	
}

-(void) toggleMusic:(id)sender {
    
    CCLOG(@"musicOn: %i", [[GameManager sharedGameManager] musicOn]);
    
    if([[GameManager sharedGameManager] musicOn])
    {
        [[GameManager sharedGameManager] setMusicOn:NO];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
    else
    {
        [[GameManager sharedGameManager] setMusicOn:YES];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"HeliotropeBouquet2.mp3" loop:YES];
    }
}






/*
 //swipe code taken from http://www.sysapps.com/tutorials/2011/4/6/cocos2d-gestures-control.html
 -(BOOL)ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event{
 
 source = [self convertTouchToNodeSpace:touch];
 return YES;
 
 }*
 
 - (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
 {
 
 
 }
 
 
 -(void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
 {
 
 
 }*/




- (void)dealloc {
	//[_label release];
	//_label = nil;
	
	//[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super dealloc];
}

@end
