//
//  Kitty.mm
//  cake
//
//  Created by Jon Stokes on 3/21/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "Kitty.h"
#import "Bullet.h"
#import "Bomb.h"
#import "Global.h"




#define PTM_RATIO 32

#define KITTY_DENSITY 0.7



@implementation Kitty

@synthesize sprite, body, fixture, _hasStar, _aboutToWin, _hasTurret,
_bulletCount, _isTurning, _currentExtent, _maxExtent, _minExtent, sewingMachineSound,
_isTouchingKitty, leftEyePos, rightEyePos, smallerKitty, isTouchingKittyCount, particleSystemStarTrail;


+(id) kittyWithParentNode:(CCNode*)parentNode position:(CGPoint)position tag:(int)tag world:(b2World*)world
{
	return [[[self alloc] initWithParentNode:parentNode position:position tag:tag world:world] autorelease];
}

-(id) initWithParentNode:(CCNode*)parentNode position:(CGPoint)position tag:(int)tag world:(b2World*)world
{
	if ((self = [super init]))
	{
        float kittyScale = 0.08f;
        if(DEBUG_KITTY_SCALE != 0)
            kittyScale = DEBUG_KITTY_SCALE;
            
        _bulletCount = 0;
		_maxExtent = 9.0f; 
		_hasStar = NO;
		_hasTurret = NO;
		_isTouchingKitty = NO;
		_world = world;
		smallerKitty = YES;
		kittyCollisionFilter = -(tag+1);
		isTouchingKittyCount = 0;
		
		//values taken from francine18x18 psd file
		//used as spawn positions for eye bullets!
		leftEyePos = ccp(28*1.5,28*5.5);
		rightEyePos = ccp(28*5.5,28*5.5); 
        
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		//initialize sound effects
		sewingMachineSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"sewingmachine.caf"] retain];
		sewingMachineSound.looping = YES;
		
		//add kitty sprite
		sprite = [CCSprite spriteWithFile:@"francineWhite.png"];
		sprite.scale = kittyScale;
		[self addChild:sprite];
		self.tag = tag;
		sprite.tag = tag;
		
		//add background to kitty so you can't see through him
		backgroundSprite = [CCSprite spriteWithFile:@"francineBackground.png"];
		backgroundSprite.anchorPoint = ccp(0,0);
		[sprite addChild:backgroundSprite z:-1];
        
        
		//set color of kitty
		//used colorblender to pick complementing colors http://www.colorblender.com/
		switch (tag) {
			case 0:
			{
				[sprite setColor:ccc3(96, 246, 133)];
				break;
			}
			case 1:
			{
				[sprite setColor:ccc3(246, 207, 95)];
				break;
			}
			case 2:
			{
				[sprite setColor:ccc3(95, 134, 246)];
				break;
			}
			case 3:
			{
				[sprite setColor:ccc3(246, 95, 209)];
				break;
			}
				
		}
		
		// Create box body 
		b2BodyDef boxBodyDef;
		boxBodyDef.type = b2_dynamicBody;
		boxBodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO); 
		boxBodyDef.userData = self;
		boxBodyDef.linearDamping = 6.0f;  //adds air resistance to box
		body = world->CreateBody(&boxBodyDef);
		
		b2PolygonShape platformShape;
		float width = [sprite boundingBox].size.width/PTM_RATIO/2.0f; 
		float height = [sprite boundingBox].size.height/PTM_RATIO/2.0f; 
		_currentExtent = width;
		platformShape.SetAsBox(width, height);// SetAsBox uses the half width and height (extents)
		
		// Create shape definition and add to body
		b2FixtureDef boxFixtureDef;
		boxFixtureDef.shape = &platformShape;
		boxFixtureDef.density = KITTY_DENSITY;  //1.0f
		boxFixtureDef.friction = 0.0f;
		boxFixtureDef.restitution = 0.0f;
		boxFixtureDef.filter.groupIndex = kittyCollisionFilter;  //used for collision filtering so eye bullets don't collide with shooter kitty
		fixture = body->CreateFixture(&boxFixtureDef);
		
		_isMoving = YES;  //set to YES if you want the kitty to move
		
        
	}
	
	return self;
}

-(void) tick
{
	
	float f;
	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	//make kitty move forward automatically by applying a force every tick
	if(_isMoving) 
	{
		float angleRad = body->GetAngle();
		
		b2Vec2 forceVec;
		forceVec = b2Vec2(cos(angleRad), sin(angleRad));  //gives a unit vector
		
		//scale applied force based on the mass
		//define points for slope-intercept form
		float minMass = 1.0; float x1 = minMass;
		float maxMass = 100.0; float x2 = maxMass;
		float minForce = 75.0; float y1 = minForce;  //was 50
		float maxForce = 1600.0; float y2 = maxForce;  //was 2400
		
		//determine slope and y-intercept of scaling function
		float slope = (y1 - y2)/(x1 - x2);
		float b = y1 - slope*x1;
		
		//determine force
		float mass = body->GetMass();
		f = mass*slope + b;
		if(_hasStar)
			f = 2.5*f;  //speed up kitty if he has a star
		
		forceVec *= f; //multiply force unit vector by scalar
		b2Vec2 linVel = body->GetLinearVelocity();
		float currentSpeed = linVel.Length();
		body->ApplyForce(forceVec, body->GetPosition());
		
	}
	
	//make kitty turn by applying a torque
	if(_isTurning)
	{
		//CCLOG(@"rot vel: %f", body->GetAngularVelocity());
		//CCLOG(@"   mass: %f", body->GetMass()); 
		//CCLOG(@"lin vel: %f", body->GetLinearVelocity().Length());
		
		//scale applied torque based on the mass
		//define points for slope-intercept form
		float minMass = 1.0; float x1 = minMass;
		float maxMass = 100.0; float x2 = maxMass;
		float minTorque = 3.0; float y1 = minTorque;
		float maxTorque = 900.0; float y2 = maxTorque; //was 900
		
		//determine slope and y-intercept of scaling function
		float slope = (y1 - y2)/(x1 - x2);
		float b = y1 - slope*x1;
		float mass = body->GetMass();
		float torque = slope*mass + b;
		
		//scale maximum angular velocity based on mass
		//define points for slope-intercept form
		//float minMass = 1.0; float x1 = minMass;
		//float maxMass = 100.0; float x2 = maxMass;
		float minAngVel = 3.0; y1 = minAngVel;
		float maxAngVel = 0.2; y2 = maxAngVel; 
		
		//determine slope and y-intercept of scaling function
		slope = (y1 - y2)/(x1 - x2);
		b = y1 - slope*x1;
		mass = body->GetMass();
		float angVel = slope*mass + b;
		
		//set maximum angular velocity, so kitty can't spin faster as he gets bigger
		if( body->GetAngularVelocity() > -angVel)
			body->ApplyTorque(-torque);
		
		//CCLOG(@"Force: %f", f);
		//CCLOG(@"Angular Velocity: %f", body->GetAngularVelocity());
		//CCLOG(@"Angular Velocity: %f", angVel);
		//CCLOG(@"Torque: %f", torque);
		
	}
	
	
	//inrement isTouchingKittyCount
	if(_isTouchingKitty == YES)
		++isTouchingKittyCount;
	else 
		isTouchingKittyCount = 0;
    
	//turn around if kitty has been touching another kitty for the last 60 frames
	if(isTouchingKittyCount > 60)
		[self turnAround];
	
	//update star trail position and angle
	if(_hasStar)
	{
		particleSystemStarTrail.position = self.position;
		particleSystemStarTrail.angle = -self.rotation + 180.0f;
	}
	
	
}	 

-(void) growWithScale: (float) myScale
{		
	[sprite runAction: [CCScaleBy actionWithDuration:0.1 scale:myScale]];
	
	//destroy current fixture and re-create a larger one
	b2Shape *shape = (b2Shape *)fixture->GetShape();
	b2PolygonShape platformShape;
	float width = [sprite boundingBox].size.width/PTM_RATIO/2.0f*myScale;
	_currentExtent = width;
	
	float height = [sprite boundingBox].size.height/PTM_RATIO/2.0f*myScale;
	//CCLOG(@"Kitty Length: %f", 2*width);
	platformShape.SetAsBox(width, height);// SetAsBox uses the half width and height (extents)
	
	b2FixtureDef fixdef;
	fixdef.shape = &platformShape;
	fixdef.density = KITTY_DENSITY;
	fixdef.friction = 0.3f;
	fixdef.restitution = 0.0f;
	fixdef.filter.groupIndex = kittyCollisionFilter;
	body->DestroyFixture(fixture);
	fixture = body->CreateFixture(&fixdef);
    
//    if(_hasTurret) {
//        [self stopActionByTag:103];
//        
//        //start auto-firing bullets
//		float rateOfFire = sprite.scale;
//		CCSequence* shootTurretCall = [CCSequence actions:[CCDelayTime actionWithDuration:rateOfFire], [CCCallFunc actionWithTarget:self selector:@selector(shootTurret)], nil];
//		CCRepeatForever* repeatSequence = [CCRepeatForever actionWithAction:shootTurretCall];
//		repeatSequence.tag = 103;
//		[self runAction:repeatSequence];
//    }
}

-(void) shrinkWithScale: (float) myScale
{	
	CCLOG(@"scale: %f", sprite.scale);	
	
	if(sprite.scale/myScale > 0.08f)
	{
        
		[sprite runAction: [CCScaleBy actionWithDuration:0.1 scale:1.0/myScale]];
        
		//destroy current fixture and re-create a larger one
		b2Shape *shape = (b2Shape *)fixture->GetShape();
		b2PolygonShape platformShape;
		float width = [sprite boundingBox].size.width/PTM_RATIO/2.0f*(1.0/myScale);
		_currentExtent = width;
		float height = [sprite boundingBox].size.height/PTM_RATIO/2.0f*(1.0/myScale);
		platformShape.SetAsBox(width, height);// SetAsBox uses the half width and height (extents)
		
		b2FixtureDef fixdef;
		fixdef.shape = &platformShape;
		fixdef.density = KITTY_DENSITY;
		fixdef.friction = 0.3f;
		fixdef.restitution = 0.0f;
		fixdef.filter.groupIndex = kittyCollisionFilter;
		body->DestroyFixture(fixture);
		fixture = body->CreateFixture(&fixdef);
        
	}
    
//    if(_hasTurret) {
//        [self stopActionByTag:103];
//        
//        //start auto-firing bullets
//		float rateOfFire = sprite.scale;
//		CCSequence* shootTurretCall = [CCSequence actions:[CCDelayTime actionWithDuration:rateOfFire], [CCCallFunc actionWithTarget:self selector:@selector(shootTurret)], nil];
//		CCRepeatForever* repeatSequence = [CCRepeatForever actionWithAction:shootTurretCall];
//		repeatSequence.tag = 103;
//		[self runAction:repeatSequence];
//    }
	
}

-(void) gotStar

{
	if(!_hasStar)
	{
		//a star makes you speedup and blink.  If you hit another kitty, they will shrink once.
		_hasStar = YES;
		
		//add the particle emitter to leave trail of stars behind kitty
		particleSystemStarTrail = [CCParticleSystemQuad particleWithFile:@"psStarTrail.plist"];
		particleSystemStarTrail.positionType = kCCPositionTypeFree;
		particleSystemStarTrail.tag = 300+self.tag;
		particleSystemStarTrail.startColor = ccc4FFromccc3B(sprite.color);
		particleSystemStarTrail.endColor = ccc4FFromccc3B(sprite.color);
		particleSystemStarTrail.startSize = particleSystemStarTrail.startSize*sprite.scale;
		[self.parent addChild:particleSystemStarTrail z:-9];
		
		CCSequence* lostStarCall = [CCSequence actions:[CCDelayTime actionWithDuration:5.0f], [CCCallFunc actionWithTarget:self selector:@selector(lostStar)], nil];
		lostStarCall.tag = 101;
		[self runAction:lostStarCall];
		
	}
}

-(void) lostStar
{
	_hasStar = NO;
	
	[self.parent removeChildByTag:300+self.tag cleanup:YES];  //remove particle emitter
	[self stopActionByTag:101]; //stop CCCallFunc
	
}

//todo: make rate of fire update when scale changes
-(void) gotTurret
{
	if(!_hasTurret)
	{
		_hasTurret = YES;
		
		//schedule the lostTurret call
		CCSequence* lostTurretCall = [CCSequence actions:[CCDelayTime actionWithDuration:7.0f], [CCCallFunc actionWithTarget:self selector:@selector(lostTurret)], nil];
		lostTurretCall.tag = 102;
		[self runAction:lostTurretCall];
		
		//start auto-firing bullets
		float rateOfFire = sprite.scale;
		CCSequence* shootTurretCall = [CCSequence actions:[CCDelayTime actionWithDuration:rateOfFire], [CCCallFunc actionWithTarget:self selector:@selector(shootTurret)], nil];
		CCRepeatForever* repeatSequence = [CCRepeatForever actionWithAction:shootTurretCall];
		repeatSequence.tag = 103;
		[self runAction:repeatSequence];
		
		//play sewing machine sound
		if(!sewingMachineSound.isPlaying)
		{
			[sewingMachineSound play];
		}
		
		//change collision filter index
		//fixture.filter.groupIndex = -1;
	}
	
	
}

-(void) lostTurret
{
	_hasTurret = NO;
	
	[sewingMachineSound stop];
	[self stopActionByTag:103];  //stops bullet firing CCAction
	
	//change collision filter index
	//fixture.filter.groupIndex = 1;
	
}		

-(void) shootTurret
{
	
	[self.parent addChild:[Bullet makeBulletInWorld:_world shooterKitty:self]];
	
}


-(void) aboutToWin
{
	
	if(!_aboutToWin);
	{
		/*
		 CCTintTo* tint1 = [CCTintTo actionWithDuration:1 red:255 green:0 blue:0];
		 CCTintTo* tint2 = [CCTintTo actionWithDuration:1 red:0 green:255 blue:0];
		 CCSequence* sequence = [CCSequence actions: tint1, tint2, nil];
		 CCRepeatForever* repeatSequence = [CCRepeatForever actionWithAction:sequence];
		 repeatSequence.tag = 22;
		 [sprite runAction:repeatSequence];
		 */
		
		_aboutToWin = YES;
	}
	
	
}

-(void) notAboutToWin
{
	if(_aboutToWin)
	{
		//[sprite stopAllActions];
		_aboutToWin = NO;
	}
	
	
}

-(void) startTurning
{
	if(!_isTurning)
		_isTurning = YES;
}

-(void) stopTurning
{
	if(_isTurning)
	{
		_isTurning = NO;
		body->SetAngularVelocity(0);
		body->SetFixedRotation(false);
        [self schedule:@selector(stopTurningAgain:) interval:0.1f];
	}
    
	
}

-(void) stopTurningAgain: (ccTime) dt {
    [self unschedule:@selector(stopTurningAgain:)];
    body->SetAngularVelocity(0);
    body->SetFixedRotation(false); 
}

//makes kitty turn around if he is touching another kitty for too long
-(void) turnAround
{
	if((!turnAroundRecentlyCalled) && (smallerKitty))
	{
		turnAroundRecentlyCalled = YES;
		
		//waits three seconds and then allows turnAround() to becalled again
		CCSequence* resetTurnAroundSequence = [CCSequence actions:[CCDelayTime actionWithDuration:3.0f], [CCCallFunc actionWithTarget:self selector:@selector(resetTurnAroundRecentlyCalled)], nil];
		[self runAction:resetTurnAroundSequence];
		body->SetTransform(body->GetPosition(),(body->GetAngle() + M_PI));
		
	}
}

-(void) resetTurnAroundRecentlyCalled  //used so the function is not called more than one time per second
{
	turnAroundRecentlyCalled = NO;
}

-(void) scaleBodyMass: (float) myScale  //use this function later with a powerup that modifies mass so one kitty can bounce
//all the others around
{
	b2MassData massData;
	body->GetFixtureList()->GetMassData(&massData);
	b2MassData *newMass = new b2MassData();
	
	newMass->mass = massData.mass*myScale;
	newMass->I = massData.I;
	newMass->center = massData.center;
	
	body->SetMassData(newMass);
}

-(void) pauseKitty
{
	if(_hasTurret)
		[sewingMachineSound stop];
}

-(void) unpauseKitty
{
	if(_hasTurret)
		[sewingMachineSound play];
}

-(void) dealloc
{
	// Must manually unschedule, it is not done automatically for us.
	//[[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
	if(_hasTurret)
		[self lostTurret];
    
	[super dealloc];
}
















@end