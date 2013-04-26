//  GameManager.mm
//  cake
//
//  Created by Jon Stokes on 7/6/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//
// adapted from Ray Wenderlich and Rod Strougo's code on p174 of "Learning Cocos2d"

#import "GameManager.h"


@implementation GameManager
static GameManager* _sharedGameManager = nil;                      

@synthesize isPlayerActiveArray, selectedMustacheArray, finalKittyScales, musicOn, sfxOn, kitties, helloWorldScene, debugRects, debugPoints, playCount, mustachesUnlocked, hasShownNewStacheMessage, matchCount, analogMode, analogMatchCount, digitalMatchCount;


+(GameManager*)sharedGameManager 
{
    @synchronized([GameManager class])                             
    {
        if(!_sharedGameManager)                                    
            [[self alloc] init]; 
		
        return _sharedGameManager;                                
    }
    return nil; 
}


+(id)alloc 
{
    @synchronized ([GameManager class])                          
    {
        NSAssert(_sharedGameManager == nil, @"Attempted to allocated a second instance of the Game Manager singleton");                                          // 6
        _sharedGameManager = [super alloc];
        return _sharedGameManager;                                
    }
    return nil;  
}


-(id)init {                                                      
    self = [super init];
    if (self != nil) {
        // Game Manager initialized
        CCLOG(@"Game Manager Singleton, init");
		
		isPlayerActiveArray = [[NSMutableArray alloc] init];
		for (int i=0; i<=3; ++i)
			[isPlayerActiveArray addObject:[NSNumber numberWithBool:NO]];
		
		selectedMustacheArray = [[NSMutableArray alloc] init];
		for (int i=0; i<=3; ++i)
			[selectedMustacheArray addObject:[NSNumber numberWithInt:0]];
		
		finalKittyScales = [[NSMutableArray alloc] init];
		for (int i=0; i<=3; ++i)
			[finalKittyScales addObject:[NSNumber numberWithFloat:0.0f]];
        
        kitties = [[NSMutableArray alloc] init];
        debugRects = [[NSMutableArray alloc] init];
        debugPoints = [[NSMutableArray alloc] init];
        
        gameDict = [[NSMutableDictionary alloc] init];
        
        [self loadFromDisk];
        
        //first launch
        if(playCount == 0) {
            sfxOn = YES;
            musicOn = YES;
            mustachesUnlocked = 5;
            [Appirater setUsesUntilPrompt:4];
            [Appirater setDaysUntilPrompt:2];
            
        }
        ++playCount;
        
        if(SOUND_OFF == 1) {
            sfxOn = NO;
        }
        
        if(MUSIC_OFF) {
            musicOn = NO;
        }

        meowNames = [[NSMutableArray alloc] init];
        [self loadSFX];
        
        if(FORCE_ANALOG)
            analogMode = YES;

    }
    return self;
}

-(void) loadFromDisk {
    
    sfxOn = [[NSUserDefaults standardUserDefaults] boolForKey: @"sfxOn"];
    musicOn = [[NSUserDefaults standardUserDefaults] boolForKey: @"musicOn"];
    hasShownNewStacheMessage = [[NSUserDefaults standardUserDefaults] boolForKey: @"hasShownNewStacheMessage"];
    
    playCount = [[NSUserDefaults standardUserDefaults] integerForKey: @"playCount"];
    mustachesUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey: @"mustachesUnlocked"];
    matchCount = [[NSUserDefaults standardUserDefaults] integerForKey: @"matchCount"];
    digitalMatchCount = [[NSUserDefaults standardUserDefaults] integerForKey: @"digitalMatchCount"];
    analogMatchCount = [[NSUserDefaults standardUserDefaults] integerForKey: @"analogMatchCount"];


    
}

-(void) saveToDisk {
    
    [[NSUserDefaults standardUserDefaults] setBool:sfxOn forKey:@"sfxOn"];
    [[NSUserDefaults standardUserDefaults] setBool:musicOn forKey:@"musicOn"];
    [[NSUserDefaults standardUserDefaults] setBool:hasShownNewStacheMessage forKey:@"hasShownNewStacheMessage"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:playCount forKey:@"playCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:mustachesUnlocked forKey:@"mustachesUnlocked"];
    [[NSUserDefaults standardUserDefaults] setInteger:matchCount forKey:@"matchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:digitalMatchCount forKey:@"digitalMatchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:analogMatchCount forKey:@"analogMatchCount"];


    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) incrementMatchCount {
    
    ++matchCount;
    
    if(analogMode) {
        ++analogMatchCount;
    } else {
        ++digitalMatchCount;
    }
    
    //heck, lets give a new mustache every round
    if(mustachesUnlocked < 51) {
        ++mustachesUnlocked;
        hasShownNewStacheMessage = NO;
    }
    
    
}

-(ccColor3B) randomWhiskersColor {
    
    int rand = arc4random() % 4;
    ccColor3B c;
    
    switch (rand) {
        case 0:
            c = whiskersGreen;
            break;
        case 1:
            c = whiskersYellow;
            break;
        case 2:
            c = whiskersBlue;
            break;
        case 3:
            c = whiskersPink;
            break;
            
        default:
            c = ccWHITE;
            break;
    }
    
    return c;
}

-(CGPoint) cocosPosFromAdobePos:(CGPoint)pos forSprite:(CCSprite*)sprite {
    
    return ccpAdd(pos, ccp(sprite.contentSize.width/2.0f, -sprite.contentSize.height/2.0f));
    
}

-(CCMenu*) menuAtPosition:(CGPoint)pos imageName:(NSString*)imageName target:(id)t selector:(SEL)s {
    
    //create's a single button that will shrink a bit when touched
    float shrinkScale = 0.97f;
    
    CCMenuItemJS *button = [CCMenuItemJS itemFromNormalImage:imageName selectedImage:imageName target:t selector:s];
    button.selectedImage.scale = shrinkScale;
    button.selectedImage.position = ccp((button.normalImage.contentSize.width - button.normalImage.contentSize.width*shrinkScale)/2.0f, (button.normalImage.contentSize.height - button.normalImage.contentSize.height*shrinkScale)/2.0f);
    
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    menu.position = pos;
    
    return menu;
}

-(CCMenu*) toggleMenuAtPosition:(CGPoint)pos imageNameOn:(NSString*)imageNameOn imageNameOff:(NSString*)imageNameOff
                                target:(id)t selector:(SEL)s {
    
    CCMenuItemJS* on = [[CCMenuItemJS itemFromNormalImage:imageNameOn
                                                  selectedImage:imageNameOff target:nil selector:nil] retain];
    //cause we want this one to have sound
    CCMenuItemJS* off = [[CCMenuItemJS itemFromNormalImage:imageNameOff
                                                   selectedImage:imageNameOn target:nil selector:nil] retain];
    CCMenuItemToggle *toggle = [CCMenuItemToggle itemWithTarget:t
                                                       selector:s items:on, off, nil];
    CCMenu *menu = [CCMenu menuWithItems:toggle, nil];
    menu.position = pos;
    
    return menu;
    
}

-(void) swapIndecesForArray:(NSMutableArray*)array index1:(int)index1 index2:(int)index2 {
    
    NSObject *placeHolder = [array objectAtIndex:index1];
    [array replaceObjectAtIndex:index1 withObject:[array objectAtIndex:index2]];
    [array replaceObjectAtIndex:index2 withObject:placeHolder];
    
}

-(void) logFlurryEvent:(NSString*)eventName {

    CCLOG(@"logging flurry event: %@", eventName);
    if (DEBUG != 1) {
        [Flurry logEvent:eventName];
    }
    
}

-(void) logFlurryEvent: (NSString*) eventName withParameters:(NSDictionary*)eventDict {
    
    CCLOG(@"logging flurry event: %@ with parameters: %@", eventName, [eventDict description]);
    
    if (DEBUG != 1) {
        [Flurry logEvent:eventName withParameters:eventDict];
    }
    
}

-(void) loadSFX {
    
    for(int i = 1; i <=10; ++i) {
        
        NSString *filename;
        
        if(i<10) {
            filename = [NSString stringWithFormat:@"meow-0%i.wav", i];
        } else {
            filename = [NSString stringWithFormat:@"meow-%i.wav", i];
        }
        [meowNames addObject:filename];
        [[SimpleAudioEngine sharedEngine] preloadEffect:filename];
    }

}

-(void) playRandomMeow {
    if(sfxOn) {
        int r = arc4random()%[meowNames count];
        [[SimpleAudioEngine sharedEngine] playEffect:[meowNames objectAtIndex:r] pitch:1.0f pan:0 gain:0.70f];
    }
}

-(void) playEffect:(NSString*) filePath pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain
{
    if(sfxOn) {
        [[SimpleAudioEngine sharedEngine] playEffect:filePath pitch:pitch pan:pan gain:gain];
    }
}

//not working
//-(void) pulseSprite: (CCSprite*) sprite cycle:(float)cycle scale:(float)scale {  //cycle is in seconds, same as wavelength
//    
//	CCAction* scaleDown = [CCScaleBy actionWithDuration:cycle/2.0f scale:scale];
//	CCAction* scaleUp = [CCScaleBy actionWithDuration:cycle/2.0f scale:1/scale];
//	CCSequence *pulseSequence = [CCSequence actions:scaleDown, scaleUp, nil];
//	CCRepeatForever *repeatPulse = [CCRepeatForever actionWithAction:pulseSequence];
//	[sprite runAction:repeatPulse];
//    
//}


@end
