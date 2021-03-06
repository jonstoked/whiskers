//  GameManager.h
//  cake
//
//  Created by Jon Stokes on 7/6/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//
// adapted from Ray Wenderlich and Rod Strougo's code on p174 of "Learning Cocos2d"

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Appirater.h"
#import "SimpleAudioEngine.h"
#import "CCMenuItemJS.h"

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
    NSMutableArray *meowNames;
    BOOL analogMode;
    int analogMatchCount;
    int digitalMatchCount;
	
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
@property (nonatomic, assign) BOOL analogMode;
@property (nonatomic, assign) int analogMatchCount;
@property (nonatomic, assign) int digitalMatchCount;









+(GameManager*)sharedGameManager;
-(void) saveToDisk;
-(void) loadFromDisk;
-(ccColor3B) randomWhiskersColor;
-(CCMenu*) menuAtPosition:(CGPoint)pos imageName:(NSString*)imageName target:(id)t selector:(SEL)s;
-(void) incrementMatchCount;

-(void) logFlurryEvent:(NSString*)eventName;
-(void) logFlurryEvent: (NSString*) eventName withParameters:(NSDictionary*)eventDict;

-(void) playEffect:(NSString*) filePath pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain;



@end
