//  GameManager.h
//  cake
//
//  Created by Jon Stokes on 7/6/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//
// adapted from Ray Wenderlich and Rod Strougo's code on p174 of "Learning Cocos2d"

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameManager : NSObject {
	NSMutableArray *isPlayerActiveArray;
	NSMutableArray *selectedMustacheArray;
	NSMutableArray *finalKittyScales;
    BOOL musicOn;
    BOOL sfxOn;
    NSMutableDictionary *gameDict;
    NSMutableArray *kitties;
	
}

@property (nonatomic,readwrite) NSMutableArray *isPlayerActiveArray;
@property (nonatomic,readwrite) NSMutableArray *selectedMustacheArray;
@property (nonatomic,readwrite) NSMutableArray *finalKittyScales;
@property (readwrite) BOOL musicOn;
@property (readwrite) BOOL sfxOn;
@property (readwrite) NSMutableDictionary *gameDict;
@property (nonatomic,readwrite) NSMutableArray *kitties;







+(GameManager*)sharedGameManager;                                  

@end
