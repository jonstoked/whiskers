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

@synthesize isPlayerActiveArray, selectedMustacheArray, finalKittyScales, musicOn, sfxOn, kitties, helloWorldScene, debugRects, debugPoints, playCount, mustachesUnlocked, hasShownNewStacheMessage;


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
        if(playCount == 0) {
            sfxOn = YES;
            musicOn = YES;
            mustachesUnlocked = 5;
        }
        ++playCount;



    }
    return self;
}

-(void) loadFromDisk {
    
    sfxOn = [[NSUserDefaults standardUserDefaults] boolForKey: @"sfxOn"];
    musicOn = [[NSUserDefaults standardUserDefaults] boolForKey: @"musicOn"];
    hasShownNewStacheMessage = [[NSUserDefaults standardUserDefaults] boolForKey: @"hasShownNewStacheMessage"];
    
    playCount = [[NSUserDefaults standardUserDefaults] integerForKey: @"playCount"];
    mustachesUnlocked = [[NSUserDefaults standardUserDefaults] integerForKey: @"mustachesUnlocked"];
    
}

-(void) saveToDisk {
    
    [[NSUserDefaults standardUserDefaults] setBool:sfxOn forKey:@"sfxOn"];
    [[NSUserDefaults standardUserDefaults] setBool:musicOn forKey:@"musicOn"];
    [[NSUserDefaults standardUserDefaults] setBool:hasShownNewStacheMessage forKey:@"hasShownNewStacheMessage"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:playCount forKey:@"playCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:mustachesUnlocked forKey:@"mustachesUnlocked"];


    [[NSUserDefaults standardUserDefaults] synchronize];
    
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


@end
