//
//  Kitty.h
//  cake
//
//  Created by Jon Stokes on 3/21/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#include "math.h"
#import "SimpleAudioEngine.h"



@interface Kitty : CCNode {
	
	CCSprite* sprite;
	b2Body* body;
	b2Fixture* fixture;
	b2World* _world;
	
	CCSprite *backgroundSprite;
	BOOL _hasStar;
	BOOL _hasTurret;
	BOOL _aboutToWin;
	int _bulletCount;  //keeps track of number of bullets fired.  Used to add random firing pattern in bullet class
	BOOL _isTurning;
	float _currentExtent;  //the is like the radius of a box, the half-width, it represents the original extent of the starting kitty
	float _maxExtent;  //extent when reached, kitty will win
	float _minExtent;  //minimum extent that kitty can shrink to, exempt any shrinkWithScale calls after this amount
	BOOL _isMoving;
	BOOL _isTouchingKitty;  //update on collision detection to tell if this kitty is touching another kitty
	int kittyCollisionFilter;
	bool turnAroundRecentlyCalled;
	CGPoint leftEyePos;
	CGPoint rightEyePos;
	BOOL smallerKitty;
	int isTouchingKittyCount; //number of consecutive frames that kitty is touching another kitty
	CCParticleSystemQuad *particleSystemStarTrail;
	
	CDSoundSource* sewingMachineSound;
    
    BOOL hasMagnet;
    BOOL isBeingSucked;
    BOOL shouldSuck;
    
    CGPoint tailPostion;
    
    BOOL isFacingOtherKitty;
    
    CGRect debugRect;
    CGPoint debugPoint;
        
    float speed;
    
    CCSpriteBatchNode *starStreakBatch;
        
    BOOL recentlyWentOffScreen;
    
    int wentOffScreenCount;
    
    float starScaleDitalMode;
    float nextScale;
}

@property (nonatomic,readwrite) CCSprite* sprite;
@property (nonatomic,readwrite) b2Body* body;
@property (nonatomic,readwrite) b2Fixture* fixture;
@property (nonatomic,readwrite) BOOL _hasStar;
@property (nonatomic,readwrite) BOOL _hasTurret;
@property (nonatomic,readwrite) BOOL _aboutToWin;
@property (nonatomic,readwrite) int _bulletCount;
@property (nonatomic,readwrite) BOOL _isTurning;
@property (nonatomic,readwrite) float _currentExtent;
@property (nonatomic,readwrite) float _maxExtent;
@property (nonatomic,readwrite) float _minExtent;
@property (nonatomic,readwrite) float _angularVelocity;
@property (nonatomic,readwrite) CDSoundSource* sewingMachineSound;
@property (nonatomic,readwrite) BOOL _isTouchingKitty;
@property (nonatomic,readwrite) CGPoint leftEyePos;
@property (nonatomic,readwrite) CGPoint rightEyePos;
@property (nonatomic,readwrite) BOOL smallerKitty;
@property (nonatomic,readwrite) int isTouchingKittyCount;
@property (nonatomic,readwrite) CCParticleSystemQuad *particleSystemStarTrail;
@property (nonatomic,readwrite) BOOL hasMagnet;
@property (nonatomic,readwrite) BOOL isBeingSucked;
@property (nonatomic,readwrite) BOOL shouldSuck;
@property (nonatomic,readwrite) CGPoint tailPosition;
@property (nonatomic,readwrite) BOOL isFacingOtherKitty;
@property (nonatomic,readwrite) CCSpriteBatchNode *starStreakBatch;
@property (nonatomic,readwrite) BOOL recentlyWentOffScreen;
@property (nonatomic,readwrite) int wentOffScreenCount;













+(id) kittyWithParentNode:(CCNode*)parentNode position:(CGPoint)position tag:(int)tag world:(b2World*)world;
-(id) initWithParentNode:(CCNode*)parentNode position:(CGPoint)position tag:(int)tag world:(b2World*)world;
-(void) tick: (ccTime) dt;
-(void) dealloc;
-(void) growWithScale: (float) scale;
-(void) shrinkWithScale: (float) scale;
-(void) turnRight;
-(void) changeRotation;
-(void) shootTurret;
-(void) startTurning;
-(void) stopTurning;
-(void) scaleBodyMass: (float) myScale;
-(void) updateAngularVelocity;
-(void) aboutToWin;
-(void) notAboutToWin;
-(void) createFixtureWithDensity:(float)density friction:(float)friction restitution:(float)restitution;




@end