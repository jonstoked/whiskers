//
//  PowerupsScene.mm
//  cake
//
//  Created by Jon Stokes on 2/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PowerupsScene.h"
#import "StartMenuScene.h"


@implementation PowerupsScene

+(id) scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [PowerupsScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
        
        [[GameManager sharedGameManager] logFlurryEvent:@"Displayed Powerups Menu"];
		      
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        scrollableLayer = [CCLayer node];
        [self addChild:scrollableLayer];
        
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255) width:1024 height:993]; 
        colorLayer.position = ccp(0,768-993);

		[self addChild:colorLayer z:-1];
        
        //add static spirtes
        NSArray *spriteNames = [[[NSArray alloc] initWithObjects:@"header", @"starPowerupDesc", @"lightningPowerupDesc",
                                 @"cateyesPowerupDesc", @"bombPowerupDesc", @"questionPowerupDesc",nil] autorelease];
        
        //cocos positions
        NSArray *spritePositions =  [[[NSArray alloc] initWithObjects:
                                      [NSValue valueWithCGPoint:ccp(512,628)],
                                      [NSValue valueWithCGPoint:ccp(506,501)],
                                      [NSValue valueWithCGPoint:ccp(411,381)],
                                      [NSValue valueWithCGPoint:ccp(424,261)],
                                      [NSValue valueWithCGPoint:ccp(427,141)],
                                      [NSValue valueWithCGPoint:ccp(508,9)],
                                      nil] autorelease];
        
        for(int i = 0; i < [spriteNames count]; ++i) {
            
            NSString *name = [spriteNames objectAtIndex:i];
            name = [name stringByAppendingString:@".png"];
            CGPoint pos = [[spritePositions objectAtIndex:i] CGPointValue];
            CCSprite *s = [CCSprite spriteWithFile:name];
            s.position = pos;
            [scrollableLayer addChild:s];
        }
        
        CCMenu *twitterButton = [[GameManager sharedGameManager] menuAtPosition:ccp(504,-113) imageName:@"twitterButton.png" target:self selector:@selector(twitterButtonTouched)];
        [scrollableLayer addChild:twitterButton];
        
        CCMenu *backButton = [[GameManager sharedGameManager] menuAtPosition:ccp(92,730) imageName:@"backButton3.png" target:self selector:@selector(backButtonTouched)];
        [scrollableLayer addChild:backButton];

            
	}	
	return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //CCLOG(@"touchBegan!");
    return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {       
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);    
    [self panForTranslation:translation];    
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGPoint retval = newPos;
    retval.y = MIN(retval.y, 993-768);
    retval.y = MAX(retval.y, 0);
    retval.x = scrollableLayer.position.x;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {    
    
    CGPoint newPos = ccpAdd(scrollableLayer.position, translation);
    scrollableLayer.position = [self boundLayerPos:newPos];      
}

-(void) backButtonTouched {
    [[CCDirector sharedDirector] replaceScene:[StartMenuScene scene]];

}

-(void) twitterButtonTouched{
    
    [[GameManager sharedGameManager] logFlurryEvent:@"Tapped Twitter Button"];
    
    //in the future, you should probably weave in native sharing: https://stackoverflow.com/questions/12503287/tutorial-for-slcomposeviewcontroller-sharing
    
    //http://www.hightechdad.com/2011/05/18/how-to-pre-populate-twitter-status-updates-the-new-way-via-links-web-intents/
    NSString *stringURL = @"http://twitter.com/intent/tweet?text=@JonStoked+-+The+next+Whiskers+powerup+should+be...";
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)onExit
{    
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}


@end
