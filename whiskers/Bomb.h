//
//  Bomb.h
//  cake
//
//  Created by Jon Stokes on 11/3/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "Kitty.h"
#import "GameManager.h"


@interface Bomb : CCNode {
	
	CCSprite* sprite;
	b2Body* body;
	b2World* _world;
	Kitty* _bomberKitty; // kitty that dropped the BOMB!
	CGPoint _position;
	CCParticleSystemQuad *psSparks;
    
    float bombLife;
    float timeLastBlink;
    float blinkRate;
	
	
}
/*
@property (nonatomic,readwrite) CCSprite* sprite;
@property (nonatomic,readwrite) b2Body* body;
@property (nonatomic,readwrite) Kitty* _bomberKitty;
@property (nonatomic,readwrite) b2World* _world;
@property (nonatomic,readwrite) CGPoint _position;*/



+(id) makeBombInWorld: (b2World*)world bomberKitty:(Kitty*)bomberKitty;
-(id) initBombInWorld: (b2World*)world bomberKitty:(Kitty*)bomberKitty;
-(b2Body*) createRoundBodyForSprite:(CCSprite*) mySprite;
-(CGPoint) makeRandomPointWithPadding: (int) padding;
-(void) removeSprite;
-(void) dealloc;




@end