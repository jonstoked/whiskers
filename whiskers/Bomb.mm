//
//  Bomb.mm
//  cake
//
//  Created by Jon Stokes on 11/3/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "Bomb.h"
#import "Global.h"

#define PTM_RATIO 32


@implementation Bomb


+(id) makeBombInWorld: (b2World*)world bomberKitty:(Kitty*)bomberKitty
{
	return [[[self alloc] initBombInWorld:world bomberKitty:bomberKitty] autorelease];
}

-(id) initBombInWorld: (b2World*)world bomberKitty:(Kitty*)bomberKitty
{
	if ((self = [super init]))
	{
		//bomb spawns above screen, then drops to a random point on the screen, waits a period and then explodes
		CCLOG(@"Initialize Bomb!");
		_world = world;
		_bomberKitty = bomberKitty;
		scaleInitial = 0.7f;		
        
//        CGPoint leftEyePos = ccpMult(_shooterKitty.leftEyePos, _shooterKitty.sprite.scale);
//		CGPoint worldPos = [_shooterKitty convertToWorldSpace:leftEyePos];
//		self.position = ccpMult(bomberKitty.tailPosition, bomberKitty.sprite.scale);
        self.position = [bomberKitty convertToWorldSpace:bomberKitty.tailPosition];
		
		sprite = [CCSprite spriteWithFile:@"bomb.png"];
		self.tag = kTagBomb;
		sprite.tag = kTagBomb;
		sprite.color = bomberKitty.sprite.color;
		sprite.position = ccp(18, 6);  //value taken directly from Adobe Illustrator file
		//sprite.anchorPoint = ccp(50/[sprite boundingBox].size.width,50/[sprite boundingBox].size.height); //take from AI file
		[self addChild:sprite];
		
		//add sparks particle effect to bomb's wick
		psSparks = [CCParticleSystemQuad particleWithFile:@"psSparks.plist"];
		psSparks.positionType = kCCPositionTypeRelative;
		psSparks.startColor = ccc4FFromccc3B(sprite.color);
		psSparks.endColor = ccc4FFromccc3B(sprite.color);
		[self addChild:psSparks z:-9];
				
		//make kitty poop bomb, then create physics body
        self.scale = 0.3f;
        float dur = 0.5f;
		id scaleUp = [CCScaleTo actionWithDuration:dur scale:1.0f];
		id ease = [CCEaseIn actionWithAction:scaleUp rate:2];
		id sequence = [CCSequence actions:ease, [CCCallFunc actionWithTarget:self selector:@selector(createBody)], nil];
		[self runAction:sequence];
        
        float angle = CC_DEGREES_TO_RADIANS(fmodf(bomberKitty.rotation,360.0f));
        CGPoint finalBombPos = ccpMult(ccpForAngle(angle), 80);
        finalBombPos = ccp(-finalBombPos.x, finalBombPos.y);  //not sure why I have to do this
        
        id move = [CCMoveBy actionWithDuration:dur position:finalBombPos];
        id ease2 = [CCEaseOut actionWithAction:move rate:2];
        [self runAction:ease2];
		
		float explosionDelay = 8.0f;
		[self schedule: @selector(explode:) interval:explosionDelay];
		
		[self schedule: @selector(tick:)];

		
	}
	
	return self;
}

-(void) tick: (ccTime) dt
{
	psSparks.position = ccpAdd(sprite.position,ccp(66,50));
}

-(void) createBody
{
	CCLOG(@"creating bomb body");
	body = [self createRoundBodyForSprite:sprite];
}

-(b2Body*) createRoundBodyForSprite:(CCSprite*) mySprite
{
	
	// Create body 
	b2BodyDef dynamicBodyDef;
	dynamicBodyDef.type = b2_dynamicBody;
	
	//set position
	dynamicBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	dynamicBodyDef.userData = self;  //assign body's reference back to its owning object
	
	// Create circle shape
	b2CircleShape circle;
	//circle.m_radius =  scaleInitial*mySprite.contentSize.width/2/PTM_RATIO;
	circle.m_radius =  63/PTM_RATIO;

	
	// Create shape definition and add to body
	b2FixtureDef dynamicFixtureDef;
	dynamicFixtureDef.shape = &circle;
	dynamicFixtureDef.density = 0.1f;
	dynamicFixtureDef.friction = 0.3f;
	dynamicFixtureDef.restitution = 0.0f; 
	//dynamicFixtureDef.filter.groupIndex = -(_bomberKitty.tag+1);  //this would allow the shooterKitty to travel through the bomb
	b2Body* myBody = _world->CreateBody(&dynamicBodyDef);
	myBody->CreateFixture(&dynamicFixtureDef);
	
	return myBody;
	
}

-(void) explode: (ccTime) dt  //modified from http://www.vellios.com/2010/06/12/bombs-with-box2d-cocos2d/
{
	CCLOG(@"explode called");

	//apply outward explosion force to each body in world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		CCNode* node = (CCNode*) b->GetUserData();
		if((node.tag != _bomberKitty.tag)  && (node.tag >=0) && (node.tag <=3))
		{		
			Kitty *kitty = (Kitty*) b->GetUserData();
			// get body and bomb position
			b2Vec2 bodyPosition = b->GetPosition();
			b2Vec2 bombPosition = body->GetPosition();
			
			// Get the distance between the two objects
			b2Vec2 d = bodyPosition - bombPosition;
			float distance = d.Length();
			b2Vec2 dUnit = d;
			dUnit.Normalize();
			
			//multiply the vector by a constant force
			float explosionForce = 2000.0f;
			dUnit *= (explosionForce/distance);
			CCLOG(@"d.Length():     %f", distance);
			CCLOG(@"dUnit.Length(): %f", dUnit.Length());
			
			//apply linear impulse to body
			b->ApplyLinearImpulse(dUnit, bodyPosition);
			
			//shrink kitty depending on how far it is from bomb
			
			if(distance < 16.0f)
			{
				//y = mx+b
				//independent(x):distance
				//dependent(y):shrinkScale
				float x1 = 0.0;
				float x2 = 16.0;
				float y1 = 3.0;  
				float y2 = 1.0;  
				
				//determine slope and y-intercept of scaling function
				float m = (y1 - y2)/(x1 - x2);
				float b = y1 - m*x1;
				
				//determine force
				float shrinkScale = m * distance + b;
				CCLOG(@"bomb shrinkScale: %f", shrinkScale);
				[kitty shrinkWithScale:shrinkScale];
			}
			
			
		}
	}
	
	[self.parent removeChildByTag:kTagBomb cleanup:YES];  //remove the bomb
		
}

-(void) dealloc
{
	
	 if(body!=NULL)
	 {
		 body->SetAwake(false);
		 _world->DestroyBody(body); 
		 body = NULL;
	 }
	 
	if(sprite!=nil)
	{
		[self removeChild:sprite cleanup:YES];
		sprite=nil;
	}
     
    
	
	[super dealloc];
}

@end