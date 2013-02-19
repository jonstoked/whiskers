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

@synthesize isPlayerActiveArray, selectedMustacheArray, finalKittyScales, musicOn, sfxOn, kitties, helloWorldScene, debugRects, debugPoints, playCount, mustachesUnlocked, hasShownNewStacheMessage, matchCount;


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
    matchCount = [[NSUserDefaults standardUserDefaults] integerForKey: @"matchCount"];

    
}

-(void) saveToDisk {
    
    [[NSUserDefaults standardUserDefaults] setBool:sfxOn forKey:@"sfxOn"];
    [[NSUserDefaults standardUserDefaults] setBool:musicOn forKey:@"musicOn"];
    [[NSUserDefaults standardUserDefaults] setBool:hasShownNewStacheMessage forKey:@"hasShownNewStacheMessage"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:playCount forKey:@"playCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:mustachesUnlocked forKey:@"mustachesUnlocked"];
    [[NSUserDefaults standardUserDefaults] setInteger:matchCount forKey:@"matchCount"];
    

    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) incrementMatchCount {
    
    ++matchCount;
        
    if(matchCount == 1 || matchCount % 3 == 0) {
        
        //give a new stache
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
    
    CCMenuItemImage *button = [CCMenuItemImage itemFromNormalImage:imageName selectedImage:imageName target:t selector:s];
    button.selectedImage.scale = shrinkScale;
    button.selectedImage.position = ccp((button.normalImage.contentSize.width - button.normalImage.contentSize.width*shrinkScale)/2.0f, (button.normalImage.contentSize.height - button.normalImage.contentSize.height*shrinkScale)/2.0f);
    
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    menu.position = pos;
    
    return menu;
}

-(void) swapIndecesForArray:(NSMutableArray*)array index1:(int)index1 index2:(int)index2 {
    
    NSObject *placeHolder = [array objectAtIndex:index1];
    [array replaceObjectAtIndex:index1 withObject:[array objectAtIndex:index2]];
    [array replaceObjectAtIndex:index2 withObject:placeHolder];
    
}


@end
