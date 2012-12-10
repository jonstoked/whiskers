//  GameManager.m
//  cake
//
//  Created by Jon Stokes on 7/6/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//
// adapted from Ray Wenderlich and Rod Strougo's code on p174 of "Learning Cocos2d"

#import "GameManager.h"


@implementation GameManager
static GameManager* _sharedGameManager = nil;                      

@synthesize isPlayerActiveArray, selectedMustacheArray, finalKittyScales, musicOn, sfxOn, kitties;


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
        
        //todo change back to yes
        musicOn = NO;
        sfxOn = NO;
        
        gameDict = [[NSMutableDictionary alloc] init];
        



    }
    return self;
}

//todo: store game settings to disk

//-(void) storeGameDict {
//    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject: [GameManager gm].usersFriends] forKey:@"usersFriends"];   
//}
//
//-(void) loadGameDict {
//    gameDict = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
//    
//}


@end
