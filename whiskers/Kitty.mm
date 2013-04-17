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
_isTouchingKitty, leftEyePos, rightEyePos, smallerKitty, isTouchingKittyCount, particleSystemStarTrail,
hasMagnet, isBeingSucked, shouldSuck, tailPosition, isFacingOtherKitty, starStreakBatch, recentlyWentOffScreen, wentOffScreenCount;


+(id) kittyWithParentNode:(CCNode*)parentNode position:(CGPoint)position tag:(int)tag world:(b2World*)world
{
	return [[[self alloc] initWithParentNode:parentNode position:position tag:tag world:world] autorelease];
}

-(id) initWithParentNode:(CCNode*)parentNode position:(CGPoint)position tag:(int)tag world:(b2World*)world
{
	if ((self = [super init]))
	{
        float kittyScale = START_SCALE;
        if(DEBUG_KITTY_SCALE != 0) {
            if(SCALE_ALL_KITTIES == 1 || tag == 1)
                kittyScale = DEBUG_KITTY_SCALE;
        }
        
        if(DEBUG_WENT_OFFSCREEN != 0 && tag == 1)
            kittyScale = 0.65f;
            
        _bulletCount = 0;
		_maxExtent = 9.0f; 
		_hasStar = NO;
		_hasTurret = NO;
		_isTouchingKitty = NO;
		_world = world;
		smallerKitty = YES;
		kittyCollisionFilter = -(tag+1);
		isTouchingKittyCount = 0;
        starScaleNonClassic = 1.75f;
		
		//values taken from francine18x18 psd file
		//used as spawn positions for eye bullets!
		leftEyePos = ccp(28*1.5,28*5.5);
		rightEyePos = ccp(28*5.5,28*5.5);
        		
		//initialize sound effects
		sewingMachineSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"sewingmachine.caf"] retain];
		sewingMachineSound.looping = YES;
        sewingMachineSound.gain = 0.4f;
		
		//add kitty sprite
		sprite = [CCSprite spriteWithFile:@"francineWhite.png"];
		sprite.scale = kittyScale;
		[self addChild:sprite z:-1];
		self.tag = tag;
		sprite.tag = tag;
		
		//add background to kitty so you can't see through him
		backgroundSprite = [CCSprite spriteWithFile:@"francineBackground.png"];
		backgroundSprite.anchorPoint = ccp(0,0);
		[sprite addChild:backgroundSprite z:-1];
        
        
		//set color of kitty
		//used colorblender to pick complementary colors http://www.colorblender.com/
		switch (tag) {
			case 0:
			{
				[sprite setColor:whiskersGreen];
				break;
			}
			case 1:
			{
				[sprite setColor:whiskersYellow];
				break;
			}
			case 2:
			{
				[sprite setColor:whiskersBlue];
				break;
			}
			case 3:
			{
				[sprite setColor:whiskersPink];
				break;
			}
				
		}
		
		// Create box body 
		b2BodyDef boxBodyDef;
		boxBodyDef.type = b2_dynamicBody;
		boxBodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO); 
		boxBodyDef.userData = self;
        if([GameManager sharedGameManager].classicMode) {
            boxBodyDef.linearDamping = 6.0f;  //adds air resistance to box
        }
        boxBodyDef.angularDamping = 9.0f;
		body = world->CreateBody(&boxBodyDef);
        
        [self createFixtureWithDensity:KITTY_DENSITY friction:0 restitution:0];
        
        if(![GameManager sharedGameManager].classicMode) {
            [self turnRight];
        }
        
        if(ONE_KITTY_MOVING) {
            if(self.tag == kTagKitty1) {
                _isMoving = YES;
            }
        } else if(NO_KITTIES_MOVING) {
          //do nothing
        } else {
            _isMoving = YES;
        }
		  
	}
	
	return self;
}

-(void) tick
{
	
	float f;
    
    float minMass = 1.111; //mass at scale 0.08
    float maxMass = 100.0;
    float mass = body->GetMass();
	
    b2Vec2 lv = body->GetLinearVelocity();
    speed = lv.Length()*PTM_RATIO;
    
	//make kitty move forward automatically by applying a force every tick
	if(_isMoving && !isBeingSucked && [GameManager sharedGameManager].classicMode)
	{
		float angleRad = body->GetAngle();
		
		b2Vec2 forceVec;
		forceVec = b2Vec2(cos(angleRad), sin(angleRad));  //gives a unit vector
		
        //scale force from min to max as kitty's mass increases
		float minForce = 60.0;
		float maxForce = 1100.0;
		
		//determine force
        f = minForce + mass/maxMass * maxForce * (_hasStar ? 2.5f : 1.0f);
        
        //slightly speed up kitty in mid-range sizes because I can't fucking write a function to give quadratic coefficents
        //FFUFFFUUFUFUCK
        //http://www.wolframalpha.com/input/?i=y+%3D+-5x%5E2+%2B+5x
        
        float boostFactor = 4.5f;
        float midRangeBoost = -boostFactor*sprite.scale*sprite.scale + boostFactor*sprite.scale;
        
        if(sprite.scale <= WIN_SCALE *0.8f) {
            f += f * midRangeBoost;
        }
        
        if(self.tag == 1) {
            
//            CCLOG(@"midRangeBoost: %f", midRangeBoost);
//            CCLOG(@"force: %f", f);
//            CCLOG(@"scale: %f", sprite.scale);
        
        }
		
		forceVec *= f; //multiply force unit vector by scalar
		body->ApplyForce(forceVec, body->GetPosition());
		
	}
	
	//make kitty turn by applying a torque
	if(_isTurning)
	{		
		//scale applied torque based on the mass
		float minTorque = 10.5;
		float maxTorque = 5000; //3500

        float torque = minTorque + (mass-minMass)/maxMass * maxTorque;
        
        if( body->GetAngularVelocity() > -2.5) {//3.4  //mid sizes were turning a little too fast
            body->ApplyTorque(-torque);
        }
		
//		CCLOG(@"Angular Velocity: %f", body->GetAngularVelocity());
//        CCLOG(@"Applying Torque: %f", torque);
//        CCLOG(@"Mass: %f", mass);

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
        particleSystemStarTrail.startSpin = self.rotation;
        particleSystemStarTrail.endSpin = particleSystemStarTrail.startSpin;
        particleSystemStarTrail.startSize = sprite.boundingBox.size.width;
		particleSystemStarTrail.endSize = particleSystemStarTrail.startSize;
//        particleSystemStarTrail.startColor = ccc4FFromccc3B([[GameManager sharedGameManager] randomWhiskersColor]);
//        particleSystemStarTrail.endColor = particleSystemStarTrail.startColor;

	}
    
    tailPosition = ccp(-[sprite boundingBox].size.width/2.0f,-[sprite boundingBox].size.height/2.0f);
    
    //check if another kitty is in front of you
    CGPoint justInFront = [self convertToWorldSpace:ccp([sprite boundingBox].size.width/2.0f + 5, 0)];
    
    isFacingOtherKitty = NO;
    for(Kitty *kitty in [GameManager sharedGameManager].kitties) {
        if(kitty.tag != self.tag) {
            //do circular distance check to other kitty (kinda janky)
            float distanceToOtherKitty = ccpDistance(justInFront, kitty.position);
            if(distanceToOtherKitty < sqrtf(2.0f)*[kitty.sprite boundingBox].size.width/2.0f) {
                isFacingOtherKitty = YES;
            }

        }
    }
    
    
    
}

-(void) growWithScale: (float) scale
{
    float myScale = scale;
    float dur = 0.1f;
    
	[sprite runAction: [CCScaleBy actionWithDuration:dur scale:myScale]];
    	
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
    
    [self schedule:@selector(updateLinearVelocity) interval:dur];
//    [self updateLinearVelocity];
    
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

-(void) shrinkWithScale: (float) scale
{
    float myScale = scale;
	if(sprite.scale/myScale > START_SCALE)
	{
        
        float dur = 0.1f;
        
		[sprite runAction: [CCScaleBy actionWithDuration:dur scale:1.0/myScale]];
        
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
        
        [self schedule:@selector(updateLinearVelocity) interval:dur];

        
	}
    
    //apply a hurt animation
    //js wip
//    id fadeKitty = [CCActionTween actionWithDuration:0.5f key:@"opacity" from:1.0f to:0.2f];
//    id repeat = [CCRepeat actionWithAction:fadeKitty times:5];
//    [sprite runAction:repeat];
//    [self schedule:@selector(showKitty) interval:3.0f];
    
    
    //change rate of fire of bullets when you change size??
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
		particleSystemStarTrail = [CCParticleSystemQuad particleWithFile:@"squares.plist"];  //32x32 white pixel
		particleSystemStarTrail.positionType = kCCPositionTypeFree;
		particleSystemStarTrail.tag = 300+self.tag;
		particleSystemStarTrail.startColor = ccc4FFromccc3B(sprite.color);
		particleSystemStarTrail.endColor = particleSystemStarTrail.startColor;
		particleSystemStarTrail.startSize = sprite.boundingBox.size.width;
		particleSystemStarTrail.endSize = particleSystemStarTrail.startSize;
        
//        float sp = speed; //for debugging
        particleSystemStarTrail.totalParticles = 100;
        particleSystemStarTrail.life = 0.8f; 
        particleSystemStarTrail.emissionRate = 3 + 15*(1-sprite.scale);

		[self.parent addChild:particleSystemStarTrail z:-9];
		
		CCSequence* lostStarCall = [CCSequence actions:[CCDelayTime actionWithDuration:5.0f], [CCCallFunc actionWithTarget:self selector:@selector(lostStar)], nil];
		lostStarCall.tag = 101;
		[self runAction:lostStarCall];
        
//        float delay = 3.0f/speed;
//        [self schedule:@selector(addStreakSprite) interval:delay];
        
        [self updateLinearVelocity];

		
	}
}

-(void) lostStar
{
	_hasStar = NO;
	
	[self.parent removeChildByTag:300+self.tag cleanup:YES];  //remove particle emitter
	[self stopActionByTag:101];
    
    [self updateLinearVelocity];
    
//    [self unschedule:@selector(addStreakSprite)];

	
}

-(void) addStreakSprite {
    
    float life = 0.4f;
    
    CCSprite *s = [CCSprite spriteWithFile:@"whiteSquare32.png"];
    s.tag = kTagKitty0Streak + self.tag;
    s.scale = sprite.boundingBox.size.width / s.contentSize.width;
    s.rotation = self.rotation;
    s.color = [[GameManager sharedGameManager] randomWhiskersColor];
    s.position = self.position;
    
    [starStreakBatch addChild:s];
//    [self.parent addChild:s z:-10];
    
    id call = [CCCallFuncND actionWithTarget:self selector:@selector(removeSpriteFromParent:data:) data:s];
    id delay = [CCDelayTime actionWithDuration:life];
    id seq = [CCSequence actions:delay,call, nil];
    [self runAction:seq];
    
}

- (void) removeSpriteFromParent:(id)sender data:(CCSprite*)s {
    
        [s.parent removeChild:s cleanup:YES];

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
		if(!sewingMachineSound.isPlaying && [[GameManager sharedGameManager] sfxOn]) {
			[sewingMachineSound play];
		}
        
    }
	
}

-(void) lostTurret
{
	_hasTurret = NO;
	
	[sewingMachineSound stop];
	[self stopActionByTag:103];  //stops bullet firing CCAction
		
}		

-(void) shootTurret
{
	
	[self.parent addChild:[Bullet makeBulletInWorld:_world shooterKitty:self]];
	
}


//js wip
-(void) gotMagnet {
    
    if(!hasMagnet) {
        hasMagnet = YES;
        for(int i = 0; i <=3; ++i) {
            if(i != self.tag) { //tags should be same as kitties array indeces
                
                Kitty *kittyToSuck = (Kitty*) [[GameManager sharedGameManager].kitties objectAtIndex:i];
                [kittyToSuck suckKittyTowardsKitty:self];
            
            }
        }
        
        [self schedule:@selector(lostMagnet) interval:4.0f];
    }
}

-(void) lostMagnet {
    
    [self unschedule:@selector(lostMagnet)];
    
    if(hasMagnet) {
        
        hasMagnet = NO;
        
        //shoot kitties off you
        for(int i = 0; i < [[GameManager sharedGameManager].kitties count]; ++i) {
            Kitty *kittyBeingSucked = (Kitty*) [[GameManager sharedGameManager].kitties objectAtIndex:i];
            if(kittyBeingSucked.isBeingSucked) {
                [kittyBeingSucked stopBeingSucked];
                kittyBeingSucked.body->ApplyLinearImpulse(b2Vec2(100.0,0.0), kittyBeingSucked.body->GetPosition());
            }
            
        }
        
    }
    
}

-(void) suckKittyTowardsKitty:(Kitty*) kitty {
    
    if(!isBeingSucked) {
        isBeingSucked = YES;
        shouldSuck = YES;
#define BEING_SUCKED_DENSITY 0.05
        [self createFixtureWithDensity:BEING_SUCKED_DENSITY friction:0 restitution:0];
    }
    
}

-(void) stopBeingSucked {
    
    if(isBeingSucked) {
        isBeingSucked = NO;
        shouldSuck = NO;
        [self createFixtureWithDensity:KITTY_DENSITY friction:0 restitution:0];
        
    }
    
}

//js wip
-(void) createFixtureWithDensity:(float)density friction:(float)friction restitution:(float)restitution {
    
    //destroy current fixture(s)
    b2Fixture* f;
    for (f = body->GetFixtureList(); f; f = f->GetNext())
    {
        body->DestroyFixture(f);
        break;
    }
    
    //create new one
    b2PolygonShape platformShape;
    float width = [sprite boundingBox].size.width/PTM_RATIO/2.0f;
    float height = [sprite boundingBox].size.height/PTM_RATIO/2.0f;
    _currentExtent = width;
    platformShape.SetAsBox(width, height);// SetAsBox uses the half width and height (extents)
    
    // Create shape definition and add to body
    b2FixtureDef boxFixtureDef;
    boxFixtureDef.shape = &platformShape;
    boxFixtureDef.density = density; 
    boxFixtureDef.friction = friction;
    boxFixtureDef.restitution = restitution;
    boxFixtureDef.filter.groupIndex = kittyCollisionFilter;  //used for collision filtering so eye bullets don't collide with shooter kitty
    fixture = body->CreateFixture(&boxFixtureDef);
    
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

-(void) turnRight {
    float lv = 1.4f/sprite.scale; //was 1.2
    if(_hasStar) {
        lv*=starScaleNonClassic;
    }
    float angle = atan2f(body->GetLinearVelocity().y, body->GetLinearVelocity().x);
    CCLOG(@"angle: %f", angle);
    float newAngle;
    if((angle >= M_PI/4.0f && angle <=3*M_PI/4.0f) || body->GetLinearVelocity().Length() == 0) {
        newAngle = 0;
        body->SetLinearVelocity(b2Vec2(lv,0));
        body->SetTransform(body->GetPosition(), 0);
    } else if (angle >= -M_PI/4.0f && angle <= M_PI/4.0f) {
        newAngle = 90;
        body->SetLinearVelocity(b2Vec2(0,-lv));
        body->SetTransform(body->GetPosition(), -M_PI/2.0f);
    } else if (angle >= -3*M_PI/4.0f && angle <=-M_PI/4.0f) {
        newAngle = 180;
        body->SetLinearVelocity(b2Vec2(-lv,0));
        body->SetTransform(body->GetPosition(), M_PI);
    } else {
        newAngle = 270;
        body->SetLinearVelocity(b2Vec2(0,lv));
        body->SetTransform(body->GetPosition(), M_PI/2.0f);
    }
    
    [self animateTurnFromAngle:CC_RADIANS_TO_DEGREES(angle) toAngle:newAngle];
}

-(void) animateTurnFromAngle:(float)a1 toAngle:(float)a2 {
    
    if(!_hasStar) {
    
        CCSprite *s = [CCSprite spriteWithFile:@"directionArrow.png"];
        s.color = sprite.color;
        s.position = self.position;
        s.scale = sprite.boundingBox.size.width/s.contentSize.width;
        s.rotation = a2;
        [self.parent addChild:s z:-10];
        float dur = 0.5f;
        
        id fadeout = [CCFadeOut actionWithDuration:dur];
        [s runAction:fadeout];
        
        id remove = [CCCallFuncND actionWithTarget:self selector:@selector(removeSpriteFromParent:data:) data:s];
        id delay = [CCDelayTime actionWithDuration:dur];
        id seq = [CCSequence actions:delay,remove, nil];
        [self runAction:seq];
        
    }
    
    
}

-(void) updateLinearVelocity {
    
    if(![GameManager sharedGameManager].classicMode) {
        
        [self unschedule:@selector(updateLinearVelocity)];
        float lv = 1.4f/sprite.scale; //was 1.2
        b2Vec2 lvUnit = body->GetLinearVelocity();
        lvUnit.Normalize();
        if(_hasStar) {
            body->SetLinearVelocity(starScaleNonClassic*lv*lvUnit);
        } else {
            body->SetLinearVelocity(lv*lvUnit);
        }
    }
}

//makes kitty turn around if he is touching another kitty for too long
-(void) turnAround
{
	if(!turnAroundRecentlyCalled) {
        
        if(smallerKitty && isFacingOtherKitty) {
            turnAroundRecentlyCalled = YES;
            
            //waits three seconds and then allows turnAround() to becalled again
            CCSequence* resetTurnAroundSequence = [CCSequence actions:[CCDelayTime actionWithDuration:3.0f], [CCCallFunc actionWithTarget:self selector:@selector(resetTurnAroundRecentlyCalled)], nil];
            [self runAction:resetTurnAroundSequence];
            body->SetTransform(body->GetPosition(),(body->GetAngle() + M_PI));
            
        }
    }
}

-(void) resetTurnAroundRecentlyCalled  
{
	turnAroundRecentlyCalled = NO;
}

-(void) wentOffScreen {
    if([GameManager sharedGameManager].classicMode) {
        
//    ++wentOffScreenCount;
////    if(wentOffScreenCount == 2) {
////        body->SetTransform(body->GetPosition(),(body->GetAngle() + M_PI));
////    }
//    [self schedule:@selector(resetWentOffScreen) interval:1.0f];
        
    }
    
}

-(void) resetWentOffScreen {
    wentOffScreenCount = 0;
    [self unschedule:@selector(resetWentOffScreen)];
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

-(void) showKitty {
    [self unschedule:@selector(showKitty)];
    sprite.opacity = 1.0f;
}

-(void) onExit
{
    if(_hasTurret)
		[self lostTurret];
    
	[super onExit];
}

-(void) dealloc
{
    
	[super dealloc];
}
















@end