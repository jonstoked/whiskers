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
        
        CCMenu *twitterButton = [self menuAtPosition:ccp(504,-113) imageName:@"twitterButton.png" target:self selector:@selector(twitterButtonTouched)];
        [scrollableLayer addChild:twitterButton];
        
        CCMenu *backButton = [self menuAtPosition:ccp(92,730) imageName:@"backButton3.png" target:self selector:@selector(backButtonTouched)];
        [scrollableLayer addChild:backButton];

            
	}	
	return self;
}

-(CCMenu*) menuAtPosition:(CGPoint)pos imageName:(NSString*)imageName target:(id)t selector:(SEL)s {
    
    //create's a single button that will shrink a bit when touched
    float shrinkScale = 0.97f;
    
    CCMenuItemImage *button = [CCMenuItemImage itemFromNormalImage:imageName selectedImage:imageName target:t selector:s];
    button.selectedImage.scale = shrinkScale;
    button.selectedImage.position = ccp((button.normalImage.contentSize.width - button.normalImage.contentSize.width*shrinkScale)/2.0f, (button.normalImage.contentSize.height - button.normalImage.contentSize.height*shrinkScale)/2.0f);
    
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    menu.position = pos;
    
    return menu;
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
    //http://www.hightechdad.com/2011/05/18/how-to-pre-populate-twitter-status-updates-the-new-way-via-links-web-intents/
    
    if ([[FLTwitter defaultManager] isTwitterAvailable]) {
        
        UIViewController * viewController = (UIViewController *)[[AppDelegate get] viewController];
        [[FLTwitter defaultManager] sendTweetFromViewController:viewController withText:@"#whiskerspowerup The next powerup should be..."];


    } else {
    
        NSString *stringURL = @"http://twitter.com/intent/tweet?text=%23whiskerspowerup+-+The+next+powerup+should+be...";
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    
    }
}

- (void)onExit
{    
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}


@end
