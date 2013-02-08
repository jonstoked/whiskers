//  GameManager.h
//  cake
//
//  Created by Jon Stokes on 7/6/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//
// adapted from Ray Wenderlich and Rod Strougo's code on p174 of "Learning Cocos2d"

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HelloWorld;

@interface GameManager : NSObject {
    
	NSMutableArray *isPlayerActiveArray;
	NSMutableArray *selectedMustacheArray;
	NSMutableArray *finalKittyScales;
    BOOL musicOn;
    BOOL sfxOn;
    NSMutableDictionary *gameDict;
    NSMutableArray *kitties;
    HelloWorld *helloWorldScene;
    NSMutableArray *debugRects;
    NSMutableArray *debugPoints;
    int playCount;
    int mustachesUnlocked;
    BOOL hasShownNewStacheMessage;
    int matchCount;
	
}

@property (nonatomic,readwrite) NSMutableArray *isPlayerActiveArray;
@property (nonatomic,readwrite) NSMutableArray *selectedMustacheArray;
@property (nonatomic,readwrite) NSMutableArray *finalKittyScales;
@property (nonatomic, assign) BOOL musicOn;
@property (nonatomic, assign) BOOL sfxOn;
@property (nonatomic, readwrite) NSMutableDictionary *gameDict;
@property (nonatomic,readwrite) NSMutableArray *kitties;
@property (nonatomic,readwrite) HelloWorld *helloWorldScene;
@property (nonatomic,readwrite) NSMutableArray *debugRects;
@property (nonatomic,readwrite) NSMutableArray *debugPoints;
@property (nonatomic, assign) int playCount;
@property (nonatomic, assign) int mustachesUnlocked;
@property (nonatomic, assign) BOOL hasShownNewStacheMessage;
@property (nonatomic, assign) int matchCount;








+(GameManager*)sharedGameManager;
-(void) saveToDisk;
-(void) loadFromDisk;
-(ccColor3B) randomWhiskersColor;
-(CCMenu*) menuAtPosition:(CGPoint)pos imageName:(NSString*)imageName target:(id)t selector:(SEL)s;
-(void) incrementMatchCount;



@end
