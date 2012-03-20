//
//  Bullet.h
//  cake
//
//  Created by Jon Stokes on 4/6/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "Kitty.h"



@interface Bullet : CCNode {
	
	CCSprite* sprite;
	b2Body* body;
	b2World* _world;
	Kitty* _shooterKitty; // the kitty that fired the bullet
	
	
}

@property (nonatomic,readwrite) CCSprite* sprite;
@property (nonatomic,readwrite) b2Body* body;
@property (nonatomic,readwrite) Kitty* _shooterKitty;
@property (nonatomic,readwrite) b2World* _world;


+(id) makeBulletInWorld: (b2World*)world shooterKitty:(Kitty*)shooterKitty;
-(id) initBulletInWorld: (b2World*)world shooterKitty:(Kitty*)shooterKitty;
-(void) removeSprite;
-(void) dealloc;




@end