
//
//  Bullet.mm
//  cake
//
//  Created by Jon Stokes on 4/6/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "Bullet.h"

#define PTM_RATIO 32



@implementation Bullet

@synthesize sprite, body, _shooterKitty, _world;


+(id) makeBulletInWorld: (b2World*)world shooterKitty:(Kitty*)shooterKitty
{
	return [[[self alloc] initBulletInWorld:world shooterKitty:shooterKitty] autorelease];
}

-(id) initBulletInWorld: (b2World*)world shooterKitty:(Kitty*)shooterKitty
{
	if ((self = [super init]))
	{
		//CCLOG(@"made it to initBulletInWorld");
		_world = world;
		_shooterKitty = shooterKitty;
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		float myScale = 1.0f;
		float bulletSpeed = 20.0f;
		
		sprite = [CCSprite spriteWithFile:@"eyeBullet2.png"];
		sprite.tag = 11;
		self.tag = 11;
		sprite.scale = shooterKitty.sprite.scale;
		sprite.color = shooterKitty.sprite.color;
		[self addChild:sprite];
		
		// Create body 
		b2BodyDef dynamicBodyDef;
		dynamicBodyDef.type = b2_dynamicBody;
		
		//set position and angle of bullet
		//CCSprite *myturret = (CCSprite*) [_shooterKitty getChildByTag:12];
		//CGPoint worldPos = [_shooterKitty convertToWorldSpace:myturret.position];
		CGPoint leftEyePos = ccpMult(_shooterKitty.leftEyePos, _shooterKitty.sprite.scale);
		CGPoint worldPos = [_shooterKitty convertToWorldSpace:leftEyePos];
		
		sprite.rotation = _shooterKitty.rotation;
		dynamicBodyDef.position.Set(worldPos.x/PTM_RATIO, worldPos.y/PTM_RATIO);

		//dynamicBodyDef.position.Set((_shooterKitty.position.x+(256*_shooterKitty.sprite.scale))/PTM_RATIO, (_shooterKitty.position.y+(96*_shooterKitty.sprite.scale))/PTM_RATIO);
		
		//left eye position from PS file: (265, 96)
		//CGPoint leftEyePositionAbsolute = CGPointMake((265 - 252)*_shooterKitty.scale,(504 - 96 - 252)*_shooterKitty.scale);
		//CGPoint leftEyePositionRelative = ccpAdd(_shooterKitty.position, leftEyePositionAbsolute);
		//dynamicBodyDef.position.Set(leftEyePositionRelative.x/PTM_RATIO, leftEyePositionRelative.y/PTM_RATIO);
		
		dynamicBodyDef.userData = self;
		body = world->CreateBody(&dynamicBodyDef);
		
		// Create circle shape
		b2PolygonShape boxShape;
		float width = [sprite boundingBox].size.width/PTM_RATIO/2.0f; 
		float height = [sprite boundingBox].size.height/PTM_RATIO/2.0f; 
		boxShape.SetAsBox(width, height);// SetAsBox uses the half width and height (extents)
		
		// Create shape definition and add to body
		b2FixtureDef dynamicFixtureDef;
		dynamicFixtureDef.shape = &boxShape;
		dynamicFixtureDef.density = 0.1f;
		dynamicFixtureDef.friction = 0.3f;
		dynamicFixtureDef.restitution = 0.0f; 
		dynamicFixtureDef.filter.groupIndex = -(shooterKitty.tag+1);
		body->CreateFixture(&dynamicFixtureDef);
		
		//set direction of bullet
		++_shooterKitty._bulletCount;
		//CCLOG(@"bullet count: 
		int mod = _shooterKitty._bulletCount % 3;  //make a way to offset each bullet a little so they don't fire straight
		int rot = ((int) _shooterKitty.rotation + 3*(mod-1)) % 360;
		float x = cos(CC_DEGREES_TO_RADIANS(rot));
		float y = sin(CC_DEGREES_TO_RADIANS(rot));
		CGPoint shootVec = ccpMult(ccp(x,y), bulletSpeed);

		//CCLOG(@"vec point x: %f y: %f", shootVec.x, shootVec.y);
		body->SetLinearVelocity(b2Vec2(shootVec.x, -shootVec.y));
		
		
	}
	
	return self;
}

-(void) removeSprite
{
	if(sprite!=nil)
	{
		[self removeChild:sprite cleanup:YES];
		sprite=nil;
	}
}

-(void) dealloc
{
	/*
	if(body!=NULL)
	{
		_world->DestroyBody(body); 
		body = NULL;
	}
	*/
	 
	if(sprite!=nil)
	{
		[self removeChild:sprite cleanup:YES];
		sprite=nil;
	}
	
	[super dealloc];
}

@end
