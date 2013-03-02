//
//  HelloWorldScene.mm
//  cake
//
//  Created by Jon Stokes on 3/15/11.
//  Copyright Jon Stokes 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldScene.h"


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

#define SFX_MUNCH @"munch.caf"
#define SFX_MOUTHPOP @"mouthpop.wav"
#define SFX_FART @"fart-06.wav"

//Tag ranges
//Sprite tags: 0-100
//Action tags: 101-200 
//30+ kitty children


@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init
{
	if( (self=[super initWithColor:ccc4(255, 255, 0, 255)])) 
	{
        [GameManager sharedGameManager].helloWorldScene = self;
        
        screenSize = [CCDirector sharedDirector].winSize;
        
		//gameManager tests
		isPlayerActiveArray =  [[GameManager sharedGameManager] isPlayerActiveArray];
        
        if(AUTO_START) {
            for (int i=0; i<=3; ++i)
                [[[GameManager sharedGameManager]isPlayerActiveArray] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
        }
        
        if (ONLY_TWO_KITTIES) {
            [[[GameManager sharedGameManager]isPlayerActiveArray] replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
            [[[GameManager sharedGameManager]isPlayerActiveArray] replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
            [[[GameManager sharedGameManager]isPlayerActiveArray] replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
            [[[GameManager sharedGameManager]isPlayerActiveArray] replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];

        }
        
        gameLayer = [CCLayer node];
        uiLayer = [CCLayer node];
        [self addChild:gameLayer z:-2];
        [self addChild:uiLayer z:-1];
        
        //having trouble changing the bg color.  I'm just going to add another layer below everything.
		bgLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)];
		[self addChild:bgLayer z:-10];
		
		_buttonSize = 100;
		_pelletScale = 2.5f; 
		_powerupCallCount = 0;
		_pelletInterval = 7.0f;
        
        _powerupInterval = 10.0f;
		
		kittyArray = [[ NSMutableArray alloc ] init];
		
		//music and sfx
        if([[GameManager sharedGameManager] musicOn])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MapleLeafRag.mp3" loop:YES];
        
		[self loadSFX];
		
		// enable touches
		self.isTouchEnabled = YES;
				
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		_world = new b2World(gravity, doSleep);
		
		_world->SetContinuousPhysics(true);
		
		
		 // Debug Drawing
		 m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		 _world->SetDebugDraw(m_debugDraw);
		 
//		 uint32 flags = 0;
//		 flags += b2DebugDraw::e_shapeBit;
//		 //		flags += b2DebugDraw::e_jointBit;
//		 //		flags += b2DebugDraw::e_aabbBit;
//		 //		flags += b2DebugDraw::e_pairBit;
//		 //		flags += b2DebugDraw::e_centerOfMassBit;
//		 m_debugDraw->SetFlags(flags);
        
//        starStreakBatch = [CCSpriteBatchNode batchNodeWithFile:@"whiteSquare504.png"];
//        [self addChild:starStreakBatch z:-10];
		
		[self addPauseMenu];
		[self addKitties];
		[self addButtons];
		
		_contactListener = new MyContactListener();
		_world->SetContactListener(_contactListener);
        
        if(DONT_SPAWN_COLLECTIBLES != 1) {
		
            [self schedule: @selector(addPellet:) interval:_pelletInterval];
            
            //don't start adding powerups until 15 seconds in
            CCSequence* delayedAddPowerupCall = [CCSequence actions:[CCDelayTime actionWithDuration:2.0f], [CCCallFunc actionWithTarget:self selector:@selector(startAddPowerup)], nil];
            delayedAddPowerupCall.tag = 104;
            [self runAction:delayedAddPowerupCall];
        
        }
		
		[self schedule: @selector(tick:)];
		
        if(TEST_POWERUP != @"") {
            [self addPowerup];
        }
        
        float l = 200;  //length of touch rect
        touchRects = [[NSMutableArray alloc] init];
        [touchRects addObject:[NSValue valueWithCGRect:CGRectMake(0,0,l,l)]];
        [touchRects addObject:[NSValue valueWithCGRect:CGRectMake(screenSize.width-l,0,l,l)]];
        [touchRects addObject:[NSValue valueWithCGRect:CGRectMake(screenSize.width-l,screenSize.height-l,l,l)]];
        [touchRects addObject:[NSValue valueWithCGRect:CGRectMake(0,screenSize.height-l,l,l)]];
        
        if(DEBUG != 1)
            [Flurry logEvent:@"Gameplay" timed:YES];
    
        
        
	}
	return self;
}

-(void) loadSFX {
    [[SimpleAudioEngine sharedEngine] preloadEffect:SFX_MUNCH];
    [[SimpleAudioEngine sharedEngine] preloadEffect:SFX_MOUTHPOP];
    [[SimpleAudioEngine sharedEngine] preloadEffect:SFX_FART];
    
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	_world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
    //debug points and rects must be added every frame
    for(NSValue *value in [GameManager sharedGameManager].debugPoints) {
        CGPoint point = [value CGPointValue];
        ccDrawPoint(point);
    }
    [[GameManager sharedGameManager].debugPoints removeAllObjects];


    //not really working, doesn't support rotated rects
//    for(NSValue *value in [GameManager sharedGameManager].debugRects) {
//        CGRect rect = [value CGRectValue];
//        CGPoint vertices[4]={
//            ccp(rect.origin.x,rect.origin.y - rect.size.height),
//            ccp(rect.origin.x + rect.size.width,rect.origin.y - rect.size.height),
//            ccp(rect.origin.x + rect.size.width,rect.origin.y),
//            ccp(rect.origin.x,rect.origin.y),
//        };
//        ccDrawPoly(vertices, 4, YES);
//
//    }
//    [[GameManager sharedGameManager].debugRects removeAllObjects];
    
}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);
		
	//declare collision detection arrays
	std::vector<MyContact>::iterator pos;
	std::vector<b2Body *>toDestroy;  //vector of bodies to destroy
	NSMutableArray *kittiesToGrow = [[ NSMutableArray alloc ] init];
	NSMutableArray *kittiesToShrink = [[ NSMutableArray alloc ] init];
	NSMutableArray *growScales = [[ NSMutableArray alloc ] init];
	NSMutableArray *shrinkScales = [[ NSMutableArray alloc ] init];
	
	
	// grow/shrink scales for powerups
	float pelletScale = 1.44f;
    float starScale = pelletScale;
    float lightningShrinkScale = pelletScale;
	float bulletScale = 1.03f;
	float lightningGrowScale = 1.68f;
	
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the sprite position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			
			
			if(myActor.tag!=kTagBullet) //exempt bullet from angle update
				myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			
			
			//check if body went off screen
			if(myActor.tag != kTagBullet)
			{
                if([b->GetUserData() isKindOfClass:[Kitty class]]) {
                    Kitty* kitty = (Kitty*) b->GetUserData();
                    if(kitty.wentOffScreenCount < 1 && [self bodyOutsideScreen:b]) {
                        [kitty wentOffScreen];
                        [self teleportBody:b];
                    }
                } else {
                    [self teleportBody:b];
                }


			}
			
			else //destroy arrows that are fired off screen
			{
				if((b->GetPosition().x > screenSize.width/PTM_RATIO) || (b->GetPosition().x < 0)
				   || (b->GetPosition().y > screenSize.height/PTM_RATIO) || (b->GetPosition().y < 0))
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), b) == toDestroy.end()) 
						toDestroy.push_back(b);
				}
			}
			
		}
		
		//iterate over kitties
		if([b->GetUserData() isKindOfClass:[Kitty class]])
		{
			Kitty* kitty = (Kitty*) b->GetUserData();
			kitty._isTouchingKitty = NO;
			
			//check for win condition
//			if([kitty.sprite boundingBox].size.width > screenSize.height/2)
//				[self gameDone];
            
            if(kitty.sprite.scale >= WIN_SCALE)
                [self gameDone];
            
//            if(kitty.sprite.scale >= ABOUT_TO_WIN_SCALE * WIN_SCALE && !kitty._aboutToWin) {
//                [kitty aboutToWin];
//                [self zoomInOnKitty:kitty];
//                
//            } else if (kitty.sprite.scale < ABOUT_TO_WIN_SCALE && kitty._aboutToWin) {
//                [kitty notAboutToWin];
//            }
                
			
			
		}
	} // end iteration over all bodies
	
	//iterate over all contact points
	for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos) 
	{
		MyContact contact = *pos;
		b2Body *bodyA = contact.fixtureA->GetBody();
		b2Body *bodyB = contact.fixtureB->GetBody();
		
		if((bodyA->GetUserData() != NULL) && (bodyB->GetUserData() != NULL)){
			CCSprite *spriteA = (CCSprite*) bodyA->GetUserData();
			CCSprite *spriteB = (CCSprite*) bodyB->GetUserData();
			
			//kitty-pellet collision
			if ((spriteA.tag == kTagPellet && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == kTagPellet && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == kTagPellet) {
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
						toDestroy.push_back(bodyA);
					}
					[kittiesToGrow addObject: [NSNumber numberWithInteger:spriteB.tag]];
					[growScales addObject: [NSNumber numberWithFloat:pelletScale]];
				}
				else {
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
						toDestroy.push_back(bodyB);
						
					}
					[kittiesToGrow addObject: [NSNumber numberWithInteger:spriteA.tag]];
					[growScales addObject: [NSNumber numberWithFloat:pelletScale]];
					
				}
                if([[GameManager sharedGameManager] sfxOn])
                    [[SimpleAudioEngine sharedEngine] playEffect:@"munch.caf"];
				
				
			}
			
			//kitty-star collision
			if ((spriteA.tag == kTagStar && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == kTagStar && spriteA.tag >= 0 && spriteA.tag <= 3))
			{
				if(spriteA.tag == kTagStar) 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) 
						toDestroy.push_back(bodyA);
					
					Kitty *kitty = (Kitty*) bodyB->GetUserData();
					[kitty gotStar];
				}
				else 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) 
						toDestroy.push_back(bodyB);
					
					Kitty *kitty = (Kitty*) bodyA->GetUserData();
					[kitty gotStar];						
				}
                if([[GameManager sharedGameManager] sfxOn])
                    [[SimpleAudioEngine sharedEngine] playEffect:@"munch.caf"];
				
				
			}
			
			//kitty-kitty collision
			if (spriteA.tag >= 0 && spriteA.tag <= 3 && spriteB.tag >= 0 && spriteB.tag <= 3)
			{
//				CCLOG(@"kitty-kitty collision!");
				Kitty *kittyA = (Kitty*) bodyA->GetUserData();
				Kitty *kittyB = (Kitty*) bodyB->GetUserData();
				kittyA._isTouchingKitty = YES;
				kittyB._isTouchingKitty = YES;
				
				kittyA.smallerKitty = YES;
				kittyB.smallerKitty = YES;
				
				//set one kitty to be smaller, so they turn around.  If they are the same size, they both turn around
				if(kittyA.sprite.scale < kittyB.sprite.scale)  
					kittyB.smallerKitty = NO;
				else if(kittyA.sprite.scale > kittyB.sprite.scale)
					kittyA.smallerKitty = NO;
				
				
				
				if(kittyA._hasStar)
				{
					[kittiesToShrink addObject: [NSNumber numberWithInteger:spriteB.tag]];
					[shrinkScales addObject: [NSNumber numberWithFloat:starScale]];
					[kittiesToGrow addObject: [NSNumber numberWithInteger:spriteA.tag]];
					[growScales addObject: [NSNumber numberWithFloat:starScale]];
					[kittyA lostStar];
				}
				else if (kittyB._hasStar)
				{
					[kittiesToShrink addObject: [NSNumber numberWithInteger:spriteA.tag]];
					[shrinkScales addObject: [NSNumber numberWithFloat:starScale]];
					[kittiesToGrow addObject: [NSNumber numberWithInteger:spriteB.tag]];
					[growScales addObject: [NSNumber numberWithFloat:starScale]];
					[kittyB lostStar];
					
					
				}
			}
			
			//kitty-turret collision
			if ((spriteA.tag == kTagTurret && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == kTagTurret && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == kTagTurret) 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) 
						toDestroy.push_back(bodyA);
					
					Kitty *kitty = (Kitty*) bodyB->GetUserData();
					[kitty gotTurret];
				}
				else 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) 
						toDestroy.push_back(bodyB);
					
					Kitty *kitty = (Kitty*) bodyA->GetUserData();
					[kitty gotTurret];						
				}
				
			}
			
			//kitty-lightning collision
			if ((spriteA.tag == kTagLightning && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == kTagLightning && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == kTagLightning) 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) 
						toDestroy.push_back(bodyA);
					
					Kitty *kitty = (Kitty*) bodyB->GetUserData();
					for(int i = 0; i<=3; ++i)
					{						
						//shrink each kitty but the one who collected it
						if(i!=spriteB.tag)
						{
							[kittiesToShrink addObject: [NSNumber numberWithInteger:i]];
							[shrinkScales addObject: [NSNumber numberWithFloat:lightningShrinkScale]];
						}
						else {
							[kittiesToGrow addObject: [NSNumber numberWithInteger:i]];
							[growScales addObject: [NSNumber numberWithFloat:lightningGrowScale]];
						}
						
						[self lightningAnimation];
					}
					
				}
				else 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) 
						toDestroy.push_back(bodyB);
					
					Kitty *kitty = (Kitty*) bodyA->GetUserData();
					for(int i = 0; i<=3; ++i)
					{						
						//shrink each kitty but the one who collected it
						if(i!=spriteA.tag)
						{
							[kittiesToShrink addObject: [NSNumber numberWithInteger:i]];
							[shrinkScales addObject: [NSNumber numberWithFloat:lightningShrinkScale]];
						}
						else {
							[kittiesToGrow addObject: [NSNumber numberWithInteger:i]];
							[growScales addObject: [NSNumber numberWithFloat:lightningGrowScale]];
						}
						
						
						[self lightningAnimation];
					}
					
				}
				
			}
			
			
			//kitty-bombs collision
			if ((spriteA.tag == kTagBombs && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == kTagBombs && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
                [[GameManager sharedGameManager] playEffect:SFX_FART pitch:1.0f pan:0 gain:0.8f];
				if(spriteA.tag == kTagBombs)
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) 
						toDestroy.push_back(bodyA);
					
					Kitty *kitty = (Kitty*) bodyB->GetUserData();
					[gameLayer addChild:[Bomb makeBombInWorld:_world bomberKitty:kitty]];
				}
				else 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) 
						toDestroy.push_back(bodyB);
					
					Kitty *kitty = (Kitty*) bodyA->GetUserData();
					[gameLayer addChild:[Bomb makeBombInWorld:_world bomberKitty:kitty]];
				}
				
			}
            
            
            //kitty-magnet collision
			if ((spriteA.tag == kTagMagnet && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == kTagMagnet && spriteA.tag >= 0 && spriteA.tag <= 3))
			{
				if(spriteA.tag == kTagMagnet)
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end())
						toDestroy.push_back(bodyA);
					
					Kitty *kitty = (Kitty*) bodyB->GetUserData();
					[kitty gotMagnet];
				}
				else
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end())
						toDestroy.push_back(bodyB);
					
					Kitty *kitty = (Kitty*) bodyA->GetUserData();
					[kitty gotMagnet];
				}
				
			}
			
			
			//kitty-bullet collision
			if ((spriteA.tag == kTagBullet && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == kTagBullet && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == kTagBullet) 
				{
					Bullet *bullet = (Bullet*) bodyA->GetUserData();
					Kitty *shooterKitty = (Kitty*) bullet._shooterKitty;
					
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) 
						toDestroy.push_back(bodyA);
					[kittiesToShrink addObject: [NSNumber numberWithInteger:spriteB.tag]];
					[shrinkScales addObject: [NSNumber numberWithFloat:bulletScale]];
					[kittiesToGrow addObject: [NSNumber numberWithInteger:shooterKitty.tag]];
					[growScales addObject: [NSNumber numberWithFloat:bulletScale]];
					
				}
				else 
				{
					Bullet *bullet = (Bullet*) bodyB->GetUserData();
					Kitty *shooterKitty = (Kitty*) bullet._shooterKitty;
					
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) 
						toDestroy.push_back(bodyB);	
					[kittiesToShrink addObject: [NSNumber numberWithInteger:spriteA.tag]];
					[shrinkScales addObject: [NSNumber numberWithFloat:bulletScale]];
					[kittiesToGrow addObject: [NSNumber numberWithInteger:shooterKitty.tag]];
					[growScales addObject: [NSNumber numberWithFloat:bulletScale]];
					
				}
				
			}
			
		}
		
	} //end collision detection
	
	
	[self increaseBallSizeWithScale: kittiesToGrow scales:growScales];
	[self decreaseBallSizeWithScale: kittiesToShrink scales:shrinkScales];
	
	
	//destroy box2d bodies
	std::vector<b2Body *>::iterator pos2;
	for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
		b2Body *body = *pos2;     
		if ((body->GetUserData() != NULL) && ([body->GetUserData() isKindOfClass:[CCSprite class]])) {
			CCSprite *sprite = (CCSprite *) body->GetUserData();
			[gameLayer removeChild:sprite cleanup:YES];
		}
		
		else if ((body->GetUserData() != NULL) && ([body->GetUserData() isKindOfClass:[Bullet class]]))
		{
			//CCLOG(@"Is a bullet");
			Bullet *bullet = (Bullet*) body->GetUserData();
			[bullet removeSprite];
		}
		body->SetAwake(false);  //very important!! always do this before you remove a body
        
        if(_world->GetBodyCount() > 0)
            _world->DestroyBody(body);
	}
	
	//call update function for each instance of Kitty
	for (int i=0; i<[kittyArray count]; ++i)
	{
		Kitty *kitty = (Kitty *) [kittyArray objectAtIndex:i];
		[kitty tick];
        

	}
    
    //magnet
    Kitty *magnetKitty;
    for (int i=0; i<[kittyArray count]; ++i) {
        Kitty *kitty = (Kitty *) [kittyArray objectAtIndex:i];
        if(kitty.hasMagnet)
            magnetKitty = kitty;
    }
    
    for (int i=0; i<[kittyArray count]; ++i) {
        Kitty *kitty = (Kitty *) [kittyArray objectAtIndex:i];
        if(kitty.isBeingSucked) {
            
            //move kittiesBeingSucked towards kitty w/ magnet
            b2Vec2 v = [self unitVectorFromPoint:kitty.body->GetPosition() toPoint:magnetKitty.body->GetPosition()];            
            kitty.body->ApplyForce(100.0f*v, kitty.body->GetPosition());

        }
    }

	//dealocate NSMutableArrays
	[kittiesToGrow dealloc];
	[kittiesToShrink dealloc];
	[growScales dealloc];
	[shrinkScales dealloc];

}

- (b2Vec2) unitVectorFromPoint:(b2Vec2)v1 toPoint:(b2Vec2)v2 {
    
    // Get the distance between the two objects
    b2Vec2 d = v2 - v1;
    b2Vec2 dUnit = d;
    dUnit.Normalize();
    
    return dUnit;
    
}

-(void) teleportBody: (b2Body*)b {
    
    //wrap body to other side of screen
    if(b->GetPosition().x > screenSize.width/PTM_RATIO) {
        b->SetTransform(b2Vec2(0,b->GetPosition().y), b->GetAngle());
    }
    else if(b->GetPosition().x < 0) {
        b->SetTransform(b2Vec2(screenSize.width/PTM_RATIO,b->GetPosition().y), b->GetAngle());
    }
    else if(b->GetPosition().y > screenSize.height/PTM_RATIO) {
        b->SetTransform(b2Vec2(b->GetPosition().x,0), b->GetAngle());
    }
    else if(b->GetPosition().y < 0) {
        b->SetTransform(b2Vec2(b->GetPosition().x,screenSize.height/PTM_RATIO), b->GetAngle());
    }

}

-(BOOL) bodyOutsideScreen: (b2Body*)b {
    BOOL outside = NO;
    if(b->GetPosition().x > screenSize.width/PTM_RATIO) {
        outside = YES;
    }
    else if(b->GetPosition().x < 0) {
        outside = YES;
    }
    else if(b->GetPosition().y > screenSize.height/PTM_RATIO) {
        outside = YES;
    }
    else if(b->GetPosition().y < 0) {
        outside = YES;
    }
    return outside;
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//cycle through touches
	for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        
        //turn some kitties
		if(!_paused)
		{
            for(int i = 0; i <= 3; ++i) {
                CGRect touchRect = [[touchRects objectAtIndex:i] CGRectValue];
                if(CGRectContainsPoint(touchRect, location)) {
                    Kitty *myKitty = (Kitty *) [gameLayer getChildByTag:i];
                    [myKitty startTurning];
                    [self animateButtonPressWithTag:i+4];
                }
            }
        }
        
		CCSprite *pauseButton = (CCSprite*) [uiLayer getChildByTag:kTagPauseButton];
		if(ccpDistance(location, pauseButton.position) < 3.0f*pauseButton.contentSize.width/2)  //tolerance of three times the button size
		{
			if(_paused)
			{
				[self unpause];
			}
			else if(!_paused)
			{
				[self pause];
			}
		}
		
	}
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
		
	//cycle through touches
	for(UITouch *touch in touches) {
		
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        
        //stop turning some kities
        for(int i = 0; i <= 3; ++i) {
            CGRect touchRect = [[touchRects objectAtIndex:i] CGRectValue];
            if(CGRectContainsPoint(touchRect, location)) {
                Kitty *myKitty = (Kitty *) [gameLayer getChildByTag:i];
                if(myKitty._isTurning)
                    [myKitty stopTurning];
                [self animateButtonReleaseWithTag:i+4];
            }
        }
        
		

		
	}
}

-(void) addButtons {	
		
	int padding = 8;
	int buttonPosition = padding + _buttonSize;
	
	CCSprite* mySprite;
	
	
	for (int i = 0; i <= 3; ++i) 
	{		
		if([[isPlayerActiveArray objectAtIndex:i] integerValue])
		{
            NSString *fileName = [NSString stringWithFormat: @"button%i.png", i+1];
            mySprite = [CCSprite spriteWithFile:fileName];
			
            if(i==0) // bottom left
			{
				mySprite.position = ccp(buttonPosition/2,buttonPosition/2);
			}
			else if(i==1) //bottom right
			{
				mySprite.position = ccp(screenSize.width - buttonPosition/2, buttonPosition/2);
			}
			else if(i==2) // top right
			{
				mySprite.position = ccp(screenSize.width - buttonPosition/2, screenSize.height - buttonPosition/2);
			}
			else if(i==3) // top left
			{
				mySprite.position = ccp(buttonPosition/2, screenSize.height - buttonPosition/2);
			}
            
            mySprite.position = ccpAdd(mySprite.position, ccp(mySprite.contentSize.width/2.0f, -mySprite.contentSize.height/2.0f));
            mySprite.anchorPoint = ccp(1,0);
			
			mySprite.tag = 4 + i;
			
			[uiLayer addChild:mySprite z:10];
		}
	}
	
    
    minButtonScale = 0.94f;
	
	//add pause button
	CCSprite* pausebutton = [CCSprite spriteWithFile:@"pausebutton2.png"];
	pausebutton.tag = kTagPauseButton;
	pausebutton.position = ccp(screenSize.width / 2.0, (screenSize.height - (pausebutton.contentSize.height/2 + padding)));
	[uiLayer addChild:pausebutton z:10];
	
	
}

-(void) animateButtonPressWithTag: (int)tag
{	
	CCSprite *button = (CCSprite*) [uiLayer getChildByTag:tag];
	
	if(button.scale == 1.0f)
	{
		NSString *textureName = [NSString stringWithFormat: @"button%idown.png", tag-3];
		CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: textureName];
		[button setTexture: tex];
        button.scale = minButtonScale;
		
	}
	
	
	
	
}

-(void) animateButtonReleaseWithTag: (int)tag
{
	CCSprite *button = (CCSprite*) [uiLayer getChildByTag:tag];
	
	
	if(button.scale == minButtonScale)
	{
		NSString *textureName = [NSString stringWithFormat: @"button%i.png", tag-3];
		CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: textureName];
		[button setTexture: tex];
        button.scale = 1.0f;

	}
	
}

-(void) addKitties {
		
	for (int i = 0; i <= 3; ++i) {
		if([[isPlayerActiveArray objectAtIndex:i] integerValue])
		{
			//set position of kitty
            // 3 2
            // 0 1
			CGPoint position;
			if(i == 0) {
				position = ccp(screenSize.width/4, screenSize.height/4);
			}
			else if(i == 1) {
                if(DEBUG_WENT_OFFSCREEN == 1) {
                    position = ccp(screenSize.width/2, screenSize.height/4);
                } else {
                    position = ccp(screenSize.width*3/4, screenSize.height/4);
                }
			}
			else if(i==2) {
				position = ccp(screenSize.width*3/4, screenSize.height*3/4);
			}
			else if(i==3) {
				position = ccp(screenSize.width/4, screenSize.height*3/4);
			}
			
			//initialize and add kitty
			Kitty *kitty = [Kitty kittyWithParentNode:gameLayer position:position tag:i world:_world];
			[gameLayer addChild:kitty z:-1];
			
			//add kitty to kittyArray
			[kittyArray addObject:kitty];
            [[GameManager sharedGameManager].kitties addObject:kitty];
                
            //for star trail
//            kitty.starStreakBatch = starStreakBatch;
			
		}
		
	}
	
	
	int mustacheXoffset = 70; //value taken from AI file
    
    //load mustache y offset array
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mustacheYoffsets" ofType:@"plist"];
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableArray *offsets = [dict objectForKey:@"Root"];
    
    //not sure why the offsets look correct without this swapping
//    [[GameManager sharedGameManager] swapIndecesForArray:offsets index1:1 index2:50];
//    [[GameManager sharedGameManager] swapIndecesForArray:offsets index1:2 index2:31];
//    [[GameManager sharedGameManager] swapIndecesForArray:offsets index1:3 index2:42];
//    [[GameManager sharedGameManager] swapIndecesForArray:offsets index1:4 index2:14];
	
	//add mustaches to kitties
	for (int i=0; i<[kittyArray count]; ++i)
	{
		Kitty *kitty = (Kitty*) [kittyArray objectAtIndex:i];
		int mustacheNumber = 1 + [[[[GameManager sharedGameManager] selectedMustacheArray] objectAtIndex:kitty.tag] integerValue];
		NSString *imageName = [NSString stringWithFormat: @"Layer-%i.png", mustacheNumber];
		CCSprite *musSprite = [CCSprite spriteWithFile:imageName];
		musSprite.position = ccp(kitty.sprite.contentSize.width/2 + mustacheXoffset, kitty.sprite.contentSize.height/2 -
                                 [[offsets objectAtIndex:mustacheNumber-1] intValue]);
		[kitty.sprite addChild:musSprite z:10];
        
        //track mustaches in flurry
        NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", mustacheNumber], @"mustacheNumber",nil];
        [[GameManager sharedGameManager] logFlurryEvent:@"Mustache Selected" withParameters:eventDict];
		
	}
	
	
}

-(void) addPellet: (ccTime) dt {
	
	float myScale = 0.5f;
	
	CCSprite* mySprite = [CCSprite spriteWithFile:@"pellet.png"];
	[mySprite setColor:ccc3(244,131,96)];
	mySprite.tag = kTagPellet;
	[gameLayer addChild:mySprite];
	[mySprite runAction: [CCScaleBy actionWithDuration:0.1 scale:myScale]];
	
	// Create body 
	b2BodyDef dynamicBodyDef;
	dynamicBodyDef.type = b2_dynamicBody;
	
	int padding = _buttonSize;
	CGPoint pos = [self makeRandomPointWithPadding:padding];
	
	dynamicBodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
	
	dynamicBodyDef.userData = mySprite;
	//dynamicBodyDef.linearDamping = 5.0f;  //makes ball floaty 
	b2Body* myDynamicBody = _world->CreateBody(&dynamicBodyDef);
	
	// Create circle shape
	b2CircleShape circle;
	circle.m_radius =  mySprite.contentSize.width/2/PTM_RATIO*myScale;
	
	// Create shape definition and add to body
	b2FixtureDef dynamicFixtureDef;
	dynamicFixtureDef.shape = &circle;
	dynamicFixtureDef.density = 0.1f;
	dynamicFixtureDef.friction = 0.3f;
	dynamicFixtureDef.restitution = 0.0f; 
	myDynamicBody->CreateFixture(&dynamicFixtureDef);
	
	/*
	for(int i = 0; i<3; ++i)
	{
		Kitty *myKitty = (Kitty*) [self getChildByTag:i];
		if(myKitty._hasTurret)
		{
			CCSprite *myturret = (CCSprite*) [myKitty getChildByTag:12];
			CCLOG(@"turret position x: %f y: %f", myturret.position.x, myturret.position.y);
			CGPoint worldPos = [myKitty convertToWorldSpace:myturret.position];
			CCLOG(@"world position x: %f y: %f", worldPos.x, worldPos.y);
			
			
		}
	}*/
	
	
}

-(void) addStar {
	
	[self createPowerupCollectible:kTagStar fileName:@"starIcon.png"];
	
}

-(void) addTurret {
	
	[self createPowerupCollectible:kTagTurret fileName:@"bulletIcon.png"];
	
}

-(void) addLightning {
	
	[self createPowerupCollectible:kTagLightning fileName:@"lightningIcon copy.png"];
}

-(void) addBombs {
	
	[self createPowerupCollectible:kTagBombs fileName:@"bombIcon.png"];
}

-(void) addMagnet {
	
	[self createPowerupCollectible:kTagMagnet fileName:@"magnetIcon.png"];
}


-(void) createPowerupCollectible:(int) tag fileName:(NSString*) fileName
{
		
	float myScale = 0.7;
	CCSprite* mySprite = [CCSprite spriteWithFile:fileName];
	mySprite.tag = tag;
	mySprite.scale = myScale;
	[gameLayer addChild:mySprite];
	
	//add pulsing animation
	float pulseScale = 0.9;
	CCAction* scaleDown = [CCScaleBy actionWithDuration:0.4 scale:pulseScale];
	CCAction* scaleUp = [CCScaleBy actionWithDuration:0.4 scale:1/pulseScale];
	CCSequence *pulseSequence = [CCSequence actions:scaleDown, scaleUp, nil];
	CCRepeatForever *repeatPulse = [CCRepeatForever actionWithAction:pulseSequence];
	[mySprite runAction:repeatPulse];
	
	// Create body 
	b2BodyDef dynamicBodyDef;
	dynamicBodyDef.type = b2_dynamicBody;
	
	int padding = _buttonSize * 2;
	CGPoint pos = [self makeRandomPointWithPadding:padding];
	dynamicBodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
	
	dynamicBodyDef.userData = mySprite;
	b2Body* myDynamicBody = _world->CreateBody(&dynamicBodyDef);
	
	// Create circle shape
	b2CircleShape circle;
	circle.m_radius =  mySprite.contentSize.width/2/PTM_RATIO*myScale;
	
	// Create shape definition and add to body
	b2FixtureDef dynamicFixtureDef;
	dynamicFixtureDef.shape = &circle;
	dynamicFixtureDef.density = 0.1f;
	dynamicFixtureDef.friction = 0.3f;
	dynamicFixtureDef.restitution = 0.0f; 
	myDynamicBody->CreateFixture(&dynamicFixtureDef);
}

-(void) startAddPowerup
{
	[self schedule: @selector(addPowerup) interval:_powerupInterval];
}

-(void) addPowerup {
    
    ++addPowerupCount;
    
    if(TEST_POWERUP == @"star") 
        [self addStar];
    else if(TEST_POWERUP == @"turret")
        [self addTurret];
    else if(TEST_POWERUP == @"lightning")
        [self addLightning];
    else if(TEST_POWERUP == @"bomb")
        [self addBombs];
    else if(TEST_POWERUP == @"magnet")
        [self addMagnet];
    else {
        
        int lightningProb = 15;
        int turretProb = 20;
        int bombProb = 20;
        int starProb = 45;
        
        int rand = arc4random()%100 + 1;
        
        BOOL spawnTwoPowerups = arc4random()%100+1 <= 15;
        spawnTwoPowerups = (addPowerupCount == 1) ? NO : spawnTwoPowerups;
        
        if(rand <= lightningProb) {
            [self addLightning];
            if(spawnTwoPowerups)
                [self addLightning];
        } else if(rand <= lightningProb + turretProb) {
             [self addTurret];
            if(spawnTwoPowerups)
                [self addTurret];
        } else if(rand <= lightningProb + turretProb + bombProb) {
            [self addBombs];
            if(spawnTwoPowerups)
                [self addBombs];
        } else {
            [self addStar];
            if(spawnTwoPowerups)
                [self addStar];
        }
        
    }
    
	
}

-(void) increaseBallSizeWithScale: (NSMutableArray *) kittiesToGrow scales:(NSMutableArray *) growScales {
	for(int i = 0; i < [kittiesToGrow count]; ++i) {
		int tag = [[kittiesToGrow objectAtIndex:i] integerValue];
		Kitty* myKitty = (Kitty*) [gameLayer getChildByTag:tag];
		float myScale = [[growScales objectAtIndex:i] floatValue];
		[myKitty growWithScale: myScale];
		
		
	}
}

-(void) decreaseBallSizeWithScale: (NSMutableArray *) kittiesToShrink scales:(NSMutableArray *) shrinkScales {
	for(int i = 0; i < [kittiesToShrink count]; ++i) {
		int tag = [[kittiesToShrink objectAtIndex:i] integerValue];
		Kitty* myKitty = (Kitty*) [gameLayer getChildByTag:tag];
		float myScale = [[shrinkScales objectAtIndex:i] floatValue];
		[myKitty shrinkWithScale: myScale];
		
	}
}

-(CGPoint) makeRandomPointWithPadding: (int) padding
{
	//create a random spawn point that does not conflict with current body positions
	int randomX, randomY;
	BOOL isBehindKitty = YES;
	CGPoint pos;
	
	//make a point, then ceck the point against all body positions, if they overlap, make another one
	while(isBehindKitty){
		isBehindKitty = NO;
		randomX = padding + (arc4random() % (int)(screenSize.width - 2 * padding)); 
		randomY = padding + (arc4random() % (int)(screenSize.height - 2 * padding)); 
		pos = ccp(randomX, randomY);
		for(int i = 0; i<=3; ++i)
		{
			Kitty* kitty = (Kitty*)[gameLayer getChildByTag:i];
			float halfWidth = [kitty.sprite boundingBox].size.width/2;
			float distance = ccpDistance(pos, kitty.position);
			if(distance < 1.5*halfWidth)
			{
				isBehindKitty = YES;
				CCLOG(@"Isbehindkitty");
			}
		}
	}
	
	return pos;
}


-(void) lightningAnimation
{
	//blink the screen diferent colors
	float delay = 0.04f;
	CCSequence* blinkScreen = [CCSequence actions: [CCCallFunc actionWithTarget:self selector:@selector(setBGColorGreen)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorBlue)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorPink)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorYellow)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorGrey)], [CCDelayTime actionWithDuration:delay],
							   nil];
	CCSequence* repeatBlinkScreen = [CCSequence actions:blinkScreen, blinkScreen, blinkScreen,nil];
	[self runAction:repeatBlinkScreen];
		
	CCSprite* lightning1 = [CCSprite spriteWithFile:@"lightningWhite.png"];
	lightning1.tag = kTagLightningSprite;
	lightning1.position = ccp(screenSize.width/2, screenSize.height*3/2);
	[gameLayer addChild:lightning1 z:-1];
	
	delay = 0.2f;
	
	CCSequence* lightningSequence = [CCSequence actions:[CCMoveBy actionWithDuration:0.3f position:ccp(0, -screenSize.height)],
									 [CCDelayTime actionWithDuration:delay],
									 [CCMoveBy actionWithDuration:0.3f position:ccp(0, -screenSize.height)],
									 [CCCallFunc actionWithTarget:self selector:@selector(removeLightning)], nil];
	
	[lightning1 runAction:lightningSequence];
	
}

-(void) removeLightning
{
	CCLOG(@"removelightning called!");
	[gameLayer removeChildByTag:kTagLightningSprite cleanup:YES];
}


-(void) setBGColorGreen
{
    [bgLayer setColor:ccc3(96, 246, 133)];
    
}

-(void) setBGColorBlue
{
	[bgLayer setColor:ccc3(246, 207, 95)];
}

-(void) setBGColorPink
{
	[bgLayer setColor:ccc3(95, 134, 246)];
}

-(void) setBGColorYellow
{
	[bgLayer setColor:ccc3(246, 95, 209)];
}

-(void) setBGColorGrey
{
	[bgLayer setColor:ccc3(70, 70, 70)];
}

-(void) zoomInOnKitty: (Kitty*) kitty {
    
    //zoom in so kitty fills 80% of screen height
    float kittyHeight = kitty.sprite.scale * kitty.sprite.contentSize.height;
    float screenHeight = [CCDirector sharedDirector].winSize.height;
    float padding = 0.2f;
    float gameLayerScale = screenHeight/(kittyHeight + padding * kittyHeight);
    
    float dur = 0.2f;
    
    [gameLayer runAction:[CCScaleTo actionWithDuration:dur scale:gameLayerScale]];
    
    [gameLayer runAction:[CCRotateTo actionWithDuration:dur angle:kitty.rotation]];
    
    gameLayer.anchorPoint = ccp(0.5f, 0.5f);
    [gameLayer runAction:[CCMoveTo actionWithDuration:dur position:kitty.position]];
    
    
    [self schedule:@selector(zoomOut) interval:2.0f];
    
}

-(void) zoomOut {
    
    [self unschedule:@selector(zoomOut)];
    
    float dur = 0.2f;
    [gameLayer runAction:[CCScaleTo actionWithDuration:dur scale:1.0f]];
    [gameLayer runAction:[CCRotateTo actionWithDuration:dur angle:0]];
    gameLayer.anchorPoint = ccp(0,0);
    [gameLayer runAction:[CCMoveTo actionWithDuration:dur position:ccp(0,0)]];
    
}

-(void) animateExplosionAtPosition:(CGPoint)position withColor:(ccColor3B)color {
    
    CCSprite *circle = [CCSprite spriteWithFile:@"circle171.png"];
    circle.scale = 0;
    circle.tag = kTagExplosion;
    circle.color = color;
    circle.position = position;
    [gameLayer addChild:circle];
    
    float dur = 0.2f;
    float finalScale = BOMB_EXPLOSION_RADIUS/171.0f;
    
    id scaleUp = [CCScaleTo actionWithDuration:dur scale:finalScale];
    [circle runAction:[CCEaseExponentialOut actionWithAction:scaleUp]];
    
    id fadeOut = [CCFadeTo actionWithDuration:dur opacity:0.3f];  //if you fade all the way out, the player won't see the true explosion radus
    [circle runAction:fadeOut];
    
    id remove = [CCSequence actions:[CCDelayTime actionWithDuration:dur], [CCCallFunc actionWithTarget:self selector:@selector(removeExplosion)], nil];
    [circle runAction:remove];
    
    [[GameManager sharedGameManager] playEffect:SFX_MOUTHPOP pitch:1.0f pan:0 gain:1.3f];
    
}

-(void) removeExplosion {
    
    [gameLayer removeChildByTag:kTagExplosion cleanup:YES];
    
}
     


-(void) pause
{
	//[[CCDirector sharedDirector] pause];
	[self unschedule: @selector(tick:)];
	[self unschedule: @selector(addPellet:)];
	[self unschedule: @selector(addPowerup)];
	[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	_paused = YES;
	
	//pause all actions
	for(CCNode *child in self.children)
	{
        [[CCActionManager sharedManager] pauseTarget:child];
	}
	
	//pause all Kitties
	for(int i = 0; i <= 3; ++i)
	{
		Kitty* myCat = (Kitty*) [gameLayer getChildByTag:i];
		[myCat pauseKitty];
	}
	
    id moveOnScreen = [CCMoveTo actionWithDuration:0.3f position:pauseMenuPositionPaused];
    
	id ease = [CCEaseInOut actionWithAction:moveOnScreen rate:3];
	[pauseMenuLayer runAction:ease];
    
    
    [[GameManager sharedGameManager] logFlurryEvent:@"Displayed Pause Menu"];
	
}

-(void) unpause
{	
	[self schedule: @selector(tick:)];
	[self schedule: @selector(addPellet:) interval:_pelletInterval];
	[self schedule: @selector(addPowerup) interval:_powerupInterval];
	
    if([[GameManager sharedGameManager] musicOn])
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
	_paused = NO;
	
	//pause all actions
	for(CCNode *child in self.children)
	{
        [[CCActionManager sharedManager] resumeTarget:child];

	}
	
	//unpause all kitties
	for(int i = 0; i <= 3; ++i)
	{
		Kitty* myCat = (Kitty*) [gameLayer getChildByTag:i];
		[myCat unpauseKitty];
	}
		
    id moveOffScreen = [CCMoveTo actionWithDuration:0.3f position:PauseMenuPositionUnpaused];
    id ease = [CCEaseInOut actionWithAction:moveOffScreen rate:3];
	[pauseMenuLayer runAction:ease];
}

-(void) resetGame
{
    
	[[CCDirector sharedDirector] replaceScene:[StartMenuScene scene]];
	
}

-(CGPoint) cocosPosFromAdobePos:(CGPoint)pos forSprite:(CCSprite*)sprite {
    
    return ccpAdd(pos, ccp(sprite.contentSize.width/2.0f, -sprite.contentSize.height/2.0f));
    
}


-(void) addPauseMenu
{	
    pauseMenuLayer = [CCLayer node];
    pauseMenuLayer.position = PauseMenuPositionUnpaused = ccp(-screenSize.width,0);
    pauseMenuPositionPaused = ccp(0,0);
	[self addChild:pauseMenuLayer z:8];
    
    CCSprite *pauseMenuBG = [CCSprite spriteWithFile:@"pauseMenuBG.png"];
    pauseMenuBG.opacity = 0.3f*255;
    pauseMenuBG.position = [self cocosPosFromAdobePos:ccp(157,555) forSprite:pauseMenuBG];
    [pauseMenuLayer addChild:pauseMenuBG];
    
    if(FORCE_GAME_END == 1) {
	
        [CCMenuItemFont setFontName:@"Courier"];
        [CCMenuItemFont setFontSize:46];
        CCMenuItemFont* item2 = [CCMenuItemFont itemFromString:@"Force Game End" target:self selector:@selector(forceGameDone)];
        CCMenu *menuuu = [CCMenu menuWithItems:item2, nil];
        menuuu.position = ccp(screenSize.width/2.0f, screenSize.height*0.9f);
        [self addChild:menuuu];
        
    }
    
    //play button
    CCMenu* playMenu = [[GameManager sharedGameManager] menuAtPosition:CGPointMake(513,422) imageName:@"playButtonPauseMenu.png" target:self selector:@selector(playPressed:)];
    [pauseMenuLayer addChild:playMenu];
    
    
    //quit button
    CCMenu *quitMenu = [[GameManager sharedGameManager] menuAtPosition:CGPointMake(756,270) imageName:@"quitButton.png" target:self selector:@selector(quitPressed:)];
    [pauseMenuLayer addChild:quitMenu];
    
    
    //music and sound buttons
    NSString *imageNameOnMusic = [GameManager sharedGameManager].musicOn ? @"musicButtonOn.png" : @"musicButtonOff.png";
    NSString *imageNameOffMusic = ![GameManager sharedGameManager].musicOn ? @"musicButtonOn.png" : @"musicButtonOff.png";
    CCMenu *musicMenu = [[GameManager sharedGameManager] toggleMenuAtPosition:ccp(298,270) imageNameOn:imageNameOnMusic imageNameOff:imageNameOffMusic target:self selector:@selector(musicToggleTouched:)];
    [pauseMenuLayer addChild:musicMenu];
    
    NSString *imageNameOnSfx = [GameManager sharedGameManager].sfxOn ? @"soundButtonOn.png" : @"soundButtonOff.png";
    NSString *imageNameOffSfx = ![GameManager sharedGameManager].sfxOn ? @"soundButtonOn.png" : @"soundButtonOff.png";

    CCMenu *sfxMenu = [[GameManager sharedGameManager] toggleMenuAtPosition:ccp(542,270) imageNameOn:imageNameOnSfx imageNameOff:imageNameOffSfx target:self selector:@selector(sfxToggleTouched:)];
    [pauseMenuLayer addChild:sfxMenu];
	
}

-(void) menuItem1Touched:(id)sender {
	[self resetGame];
}

-(void) forceGameDone {
	[self gameDone];
}

-(void) playPressed: (id) sender {
    [self unpause];
}

-(void) thanksPressed: (id) sender {
    CCLOG(@"thanks");
}

-(void) quitPressed: (id) sender {
    [self resetGame];
}


-(void) musicToggleTouched:(id)sender {
    CCLOG(@"musicOn: %i", [[GameManager sharedGameManager] musicOn]);
    
    if([[GameManager sharedGameManager] musicOn])
    {
        [[GameManager sharedGameManager] setMusicOn:NO];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];

    }
    else
    {
        [[GameManager sharedGameManager] setMusicOn:YES];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MapleLeafRag.mp3" loop:YES];

    }    
}

-(void) sfxToggleTouched:(id)sender {
    
    if([[GameManager sharedGameManager] sfxOn])
    {
        [[GameManager sharedGameManager] setSfxOn:NO];
        
    }
    else
    {
        [[GameManager sharedGameManager] setSfxOn:YES];
        [[GameManager sharedGameManager] playRandomMeow];
        
    }    
}



-(void) gameDone {
    
    for(CCNode *node in gameLayer.children) {
        if([node isKindOfClass:[Bomb class]]) {
            Bomb *bomb = (Bomb*) node;
            [bomb explode];
        }
    }
	
	//store final kitty scales for use in GameOverScene
	for(int i=0; i<[kittyArray count]; ++i)
	{
		Kitty *kitty = (Kitty*) [kittyArray objectAtIndex:i];
		
		[[[GameManager sharedGameManager] finalKittyScales] 
		 replaceObjectAtIndex:kitty.tag withObject:[NSNumber numberWithFloat:kitty.sprite.scale]];
	}
	
	//replace scene
	GameOverScene *gameOverScene = [GameOverScene node];
	[[CCDirector sharedDirector] replaceScene:gameOverScene];
	
}

-(void) onExit
{
	[super onExit];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    if(DEBUG != 1)
        [Flurry endTimedEvent:@"Gameplay" withParameters:nil];
    
    //remove any sprites that have physics bodies before you delete the world
    for(CCSprite *sprite in gameLayer.children) {
        if(sprite.tag == kTagBomb) {
			[gameLayer removeChild:sprite cleanup:YES];
        }
    }
	
	[kittyArray dealloc];
    [touchRects dealloc];
	
	delete _contactListener;
	delete _world;
	_world = NULL;
	
	delete m_debugDraw;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
