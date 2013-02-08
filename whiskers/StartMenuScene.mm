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
        
        if([[GameManager sharedGameManager] musicOn])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"HeliotropeBouquet2.mp3" loop:YES];
		
		CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)]; 
		[self addChild:colorLayer z:-10];
            
        //add the logo
        CCSprite *logo = [CCSprite spriteWithFile:@"whiskersLogo.png"];
        logo.position = ccp(screenSize.width/2.0f, screenSize.height/2.0f);
        [self addChild:logo];
        
        float t = 0.25f;
        id move = [CCMoveTo actionWithDuration:t position:ccp(780,504)];
        id shrink = [CCScaleTo actionWithDuration:t scale:0.53];
        [logo runAction:move];
        [logo runAction:shrink];
        [self showMenu];
        
		
	}	
	return self;
}

-(void) showMenu {
        
    CCMenu *playMenu = [[GameManager sharedGameManager] menuAtPosition:CGPointMake(311 - [[CCDirector sharedDirector] winSize].width,489) imageName:@"playButton.png" target:self selector:@selector(playButtonTouched:)];
    
    powerupsMenu = [[GameManager sharedGameManager] menuAtPosition:CGPointMake(511 - [[CCDirector sharedDirector] winSize].width,300) imageName:@"powerupsButton.png" target:self selector:@selector(powerupsButtonTouched:)];
    
    [self addChild:playMenu];
    [self addChild:powerupsMenu];
    
    CCSprite *logo2 = [CCSprite spriteWithFile:@"byJonStokes.png"];
    logo2.position = CGPointMake(770 - [[CCDirector sharedDirector] winSize].width, 156);
    [self addChild:logo2];
    logo2.tag = 2;
    
    float t2 = 0.1f;
    id movein = [CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width, 0)]];
    [playMenu runAction:movein];
    [self schedule:@selector(moveInPowerupsButton) interval:t2];
    [self schedule:@selector(moveInLogo2) interval:t2*2];

    

}

-(void) moveInPowerupsButton {
    
    [self unschedule:@selector(moveInPowerupsButton)];
    id movein = [CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width, 0)]];
    [powerupsMenu runAction:movein];
}

-(void) moveInLogo2 {
    [self unschedule:@selector(moveInLogo2)];
    id logo2 = [self getChildByTag:2];
    id movein = [CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.25f position:ccp([[CCDirector sharedDirector] winSize].width, 0)]];
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





- (void)dealloc {
	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super dealloc];
    
}

@end
