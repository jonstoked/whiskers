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
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        scrollableLayer = [CCLayer node];
        [self addChild:scrollableLayer];
        
        //CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)]; 
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255) width:1024 height:993]; 
        colorLayer.position = ccp(0,768-993);

		[self addChild:colorLayer z:-1];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"powerupsSceneLayout" ofType:@"plist"];        
        NSDictionary * layoutDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        for(NSString *key in layoutDict){
            
            CCLOG(@"%@", key);
            
            NSString *posString = [layoutDict objectForKey:key];
            NSArray *components = [posString componentsSeparatedByString:@":"];
            int x = [[components objectAtIndex:0] intValue];
            int y = [[components objectAtIndex:1] intValue];
            
            //just a sprite
            if ([key rangeOfString:@"Button"].location == NSNotFound) {
                CCSprite *sprite = [CCSprite spriteWithFile:key];
                sprite.position = ccp(x,y);
                [scrollableLayer addChild:sprite];
            }
            
            //a button
            else {
                CCMenuItemImage *button;
                if ([key isEqualToString:@"backButtonPowerups.png"])  {
                    button = [CCMenuItemImage itemFromNormalImage:key selectedImage:key target:self selector:@selector(backButtonTouched:)];
                    CCLOG(@"made it");
                }
                else if ([key isEqualToString:@"twitterButton.png"]) {
                    button = [CCMenuItemImage itemFromNormalImage:key selectedImage:key target:self selector:@selector(twitterButtonTouched:)];
                    CCLOG(@"made it");

                }
                else if ([key isEqualToString:@"facebookButton.png"]) {
                    button = [CCMenuItemImage itemFromNormalImage:key selectedImage:key target:self selector:@selector(facebookButtonTouched:)];
                    CCLOG(@"made it");
                }
                    
                float shrinkScale = 0.97f;
                button.selectedImage.scale = shrinkScale;
                button.selectedImage.position = ccp((button.normalImage.contentSize.width - button.normalImage.contentSize.width*shrinkScale)/2.0f, (button.normalImage.contentSize.height - button.normalImage.contentSize.height*shrinkScale)/2.0f);
                
                CCMenu* menu = [CCMenu menuWithItems:button, nil];
                menu.position = ccp(x,y);
                
                if([key isEqualToString:@"backButtonPowerups.png"])
                    [self addChild:menu];
                else 
                    [scrollableLayer addChild:menu];
                

            }
            
        }

            
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

-(void) backButtonTouched:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[StartMenuScene scene]];

}

-(void) facebookButtonTouched:(id)sender {
    //http://www.facebook.com/pages/Whiskers/275473359190039
    
    NSString *stringURL = @"http://www.facebook.com/pages/Whiskers/275473359190039";
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

-(void) twitterButtonTouched:(id)sender {
    //http://www.hightechdad.com/2011/05/18/how-to-pre-populate-twitter-status-updates-the-new-way-via-links-web-intents/
    
    NSString *stringURL = @"http://twitter.com/intent/tweet?text=%23whiskersPowerup+-+The+next+powerup+should+be...";
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)onExit
{    
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}


@end
