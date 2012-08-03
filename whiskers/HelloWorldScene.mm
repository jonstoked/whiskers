//
//  HelloWorldScene.mm
//  cake
//
//  Created by Jon Stokes on 3/15/11.
//  Copyright Jon Stokes 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldScene.h"
#import "Global.h"


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

//Tag ranges
//Sprite tags: 0-100
//Action tags: 101-200 
//30+ kitty children



// HelloWorld implementation
@implementation HelloWorld

//@synthesize pauseMenuLayer;

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
		
		//gameManager tests
		isPlayerActiveArray =  [[GameManager sharedGameManager] isPlayerActiveArray];
		/*
		 for(int i=0; i < isPlayerActiveArray.count; ++i)
		 CCLOG(@"isPlayerActiveArray[%i] = %d", i, [[isPlayerActiveArray objectAtIndex:i] integerValue]);
		 for(int i=0; i <=3 ; ++i)
		 CCLOG(@"selectedMustacheArray[%i] = %d", i, [[[[GameManager sharedGameManager] selectedMustacheArray] objectAtIndex:i] integerValue]);
        
		 */
        
        if(AUTO_START) {
            for (int i=0; i<=3; ++i)
                [[[GameManager sharedGameManager]isPlayerActiveArray] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
        }
		
		_buttonSize = 100;
		_pelletScale = 2.5f;  //should be 2.0
		_powerupCallCount = 0;
		_pelletInterval = 7.0f; 
		_powerupInterval = 10.0f;
		
		kittyArray = [[ NSMutableArray alloc ] init];
		
		//having trouble changing the bg color.  I'm just going to add another layer below everything.
		bgLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)];
		[self addChild:bgLayer z:-10];
		
		
		//music and sfx
        if([[GameManager sharedGameManager] musicOn])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MapleLeafRag.mp3" loop:YES];
		
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"munch.caf"];
		//[[SimpleAudioEngine sharedEngine] preloadEffect:@"sewingmachine.caf"];
		
		
		// enable touches
		self.isTouchEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		_world = new b2World(gravity, doSleep);
		
		_world->SetContinuousPhysics(true);
		
		
//		 // Debug Drawing
//		 m_debugDraw = new GLESDebugDraw( PTM_RATIO );
//		 _world->SetDebugDraw(m_debugDraw);
//		 
//		 uint32 flags = 0;
//		 flags += b2DebugDraw::e_shapeBit;
//		 //		flags += b2DebugDraw::e_jointBit;
//		 //		flags += b2DebugDraw::e_aabbBit;
//		 //		flags += b2DebugDraw::e_pairBit;
//		 //		flags += b2DebugDraw::e_centerOfMassBit;
//		 m_debugDraw->SetFlags(flags);	
		 
		
		
		[self addPauseMenu];
		[self addKitties];
		[self addButtons];
		
		_contactListener = new MyContactListener();
		_world->SetContactListener(_contactListener);
		
		[self schedule: @selector(addPellet:) interval:_pelletInterval];
		
		//don't start adding powerups until 15 seconds in
		CCSequence* delayedAddPowerupCall = [CCSequence actions:[CCDelayTime actionWithDuration:2.0f], [CCCallFunc actionWithTarget:self selector:@selector(startAddPowerup)], nil];
		delayedAddPowerupCall.tag = 104;
		[self runAction:delayedAddPowerupCall];
		
		[self schedule: @selector(tick:)];
		
		//[self addBombs];
				
	}
	return self;
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
	
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	//declare collision detection arrays
	std::vector<MyContact>::iterator pos;
	std::vector<b2Body *>toDestroy;  //vector of bodies to destroy
	NSMutableArray *kittiesToGrow = [[ NSMutableArray alloc ] init];
	NSMutableArray *kittiesToShrink = [[ NSMutableArray alloc ] init];
	NSMutableArray *growScales = [[ NSMutableArray alloc ] init];
	NSMutableArray *shrinkScales = [[ NSMutableArray alloc ] init];
	
	
	// grow/shrink scales for powerups
    float scaleScale = 1.2f; //how fast that game gon' end?
	float pelletScale = 1.2f*scaleScale;
	float bulletScale = 1.03f;
	float lightningGrowScale = 1.4f*scaleScale;
    float lightningShrinkScale = 1.2f*scaleScale;
	
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the sprite position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			
			
			if(myActor.tag!=11) //exempt bullet from angle update
				myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			
			
			//check if body went off screen
			if(myActor.tag != 11)
			{
				if(b->GetPosition().x > screenSize.width/PTM_RATIO)
					b->SetTransform(b2Vec2(0,b->GetPosition().y), b->GetAngle());
				else if(b->GetPosition().x < 0)
					b->SetTransform(b2Vec2(screenSize.width/PTM_RATIO,b->GetPosition().y), b->GetAngle());
				else if(b->GetPosition().y > screenSize.height/PTM_RATIO)
					b->SetTransform(b2Vec2(b->GetPosition().x,0), b->GetAngle());
				else if(b->GetPosition().y < 0)
					b->SetTransform(b2Vec2(b->GetPosition().x,screenSize.height/PTM_RATIO), b->GetAngle());
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
            
            if(kitty.sprite.scale >= ABOUT_TO_WIN_SCALE * WIN_SCALE && !kitty._aboutToWin) {
                [kitty aboutToWin];
                [self zoomInOnKitty:kitty];
                
            } else if (kitty.sprite.scale < ABOUT_TO_WIN_SCALE && kitty._aboutToWin) {
                [kitty notAboutToWin];
            }
                
			
			
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
			if ((spriteA.tag == 8 && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == 8 && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == 8) {
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
			if ((spriteA.tag == 9 && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == 9 && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == 9) 
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
				CCLOG(@"kitty-kitty collision!");
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
					[shrinkScales addObject: [NSNumber numberWithFloat:pelletScale]];
					[kittiesToGrow addObject: [NSNumber numberWithInteger:spriteA.tag]];
					[growScales addObject: [NSNumber numberWithFloat:pelletScale]];
					[kittyA lostStar];
				}
				else if (kittyB._hasStar)
				{
					[kittiesToShrink addObject: [NSNumber numberWithInteger:spriteA.tag]];
					[shrinkScales addObject: [NSNumber numberWithFloat:pelletScale]];
					[kittiesToGrow addObject: [NSNumber numberWithInteger:spriteB.tag]];
					[growScales addObject: [NSNumber numberWithFloat:pelletScale]];
					[kittyB lostStar];
					
					
				}
			}
			
			//kitty-turret collision
			if ((spriteA.tag == 10 && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == 10 && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == 10) 
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
			if ((spriteA.tag == 12 && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == 12 && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				CCLOG(@"kitty-kitty collision!");
				if(spriteA.tag == 12) 
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
			if ((spriteA.tag == 14 && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == 14 && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == 14) 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) 
						toDestroy.push_back(bodyA);
					
					Kitty *kitty = (Kitty*) bodyB->GetUserData();
					[self addChild:[Bomb makeBombInWorld:_world bomberKitty:kitty]];
				}
				else 
				{
					if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) 
						toDestroy.push_back(bodyB);
					
					Kitty *kitty = (Kitty*) bodyA->GetUserData();
					[self addChild:[Bomb makeBombInWorld:_world bomberKitty:kitty]];
				}
				
			}
			
			
			//kitty-bullet collision
			if ((spriteA.tag == 11 && spriteB.tag >= 0 && spriteB.tag <= 3) ||
				(spriteB.tag == 11 && spriteA.tag >= 0 && spriteA.tag <= 3)) 
			{
				if(spriteA.tag == 11) 
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
			[self removeChild:sprite cleanup:YES];
		}
		
		else if ((body->GetUserData() != NULL) && ([body->GetUserData() isKindOfClass:[Bullet class]]))
		{
			//CCLOG(@"Is a bullet");
			Bullet *bullet = (Bullet*) body->GetUserData();
			[bullet removeSprite];
		}
		body->SetAwake(false);  //very important!! always do this before you remove a body
		_world->DestroyBody(body);
	}
	
	//call update function for each instance of Kitty
	for (int i=0; i<[kittyArray count]; ++i)
	{
		Kitty *kitty = (Kitty *) [kittyArray objectAtIndex:i];
		[kitty tick];
	}
	
	
	
	//dealocate NSMutableArrays
	[kittiesToGrow dealloc];
	[kittiesToShrink dealloc];
	[growScales dealloc];
	[shrinkScales dealloc];
	
	
	
	
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	//cycle through touches
	for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		float buttonPressTolerance = 1.5f;  //how far away you can press your finger from the button and still have it register
		
		if(!_paused)
		{
			CCSprite *button4 = (CCSprite*) [self getChildByTag:4];
			if(ccpDistance(location, button4.position) < buttonPressTolerance*button4.contentSize.width/2)
			{
				Kitty *myKitty = (Kitty *) [self getChildByTag:0];
				//[myKitty turnRight];
				[myKitty startTurning];
				[self animateButtonPressWithTag:4];
				
				
			}
			
			CCSprite *button5 = (CCSprite*) [self getChildByTag:5];
			if(ccpDistance(location, button5.position) < buttonPressTolerance*button5.contentSize.width/2)
			{
				Kitty *myKitty = (Kitty *) [self getChildByTag:1];
				//[myKitty turnRight];
				[myKitty startTurning];
				[self animateButtonPressWithTag:5];
				
			}
			
			CCSprite *button6 = (CCSprite*) [self getChildByTag:6];
			if(ccpDistance(location, button6.position) < buttonPressTolerance*button6.contentSize.width/2)
			{
				Kitty *myKitty = (Kitty *) [self getChildByTag:2];
				//[myKitty turnRight];
				[myKitty startTurning];
				[self animateButtonPressWithTag:6];
				
			}
			CCSprite *button7 = (CCSprite*) [self getChildByTag:7];
			if(ccpDistance(location, button7.position) < buttonPressTolerance*button7.contentSize.width/2)
			{
				Kitty *myKitty = (Kitty *) [self getChildByTag:3];
				//[myKitty turnRight];
				[myKitty startTurning];
				[self animateButtonPressWithTag:7];
			}
		}
		
		CCSprite *pauseButton = (CCSprite*) [self getChildByTag:13];
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
	
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float tolerance = 2.5f; //mutliply tolerance by buttonSize to allow accidentaly sliding fingers off of button area
	
	//cycle through touches
	for(UITouch *touch in touches) {
		
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		float buttonReleaseTolerance = 4.0f;  //how far away you can lift off your finger from the button and still have it register
		
		CCSprite *button4 = (CCSprite*) [self getChildByTag:4];
		CCSprite *button5 = (CCSprite*) [self getChildByTag:5];
		CCSprite *button6 = (CCSprite*) [self getChildByTag:6];
		CCSprite *button7 = (CCSprite*) [self getChildByTag:7];
		
		if(ccpDistance(location, button4.position) < buttonReleaseTolerance*button4.contentSize.width/2)
		{
			Kitty *myKitty = (Kitty *) [self getChildByTag:0];
			if(myKitty._isTurning)
				[myKitty stopTurning];
			[self animateButtonReleaseWithTag:4];
			
		}
		if(ccpDistance(location, button5.position) < buttonReleaseTolerance*button5.contentSize.width/2)
		{
			Kitty *myKitty = (Kitty *) [self getChildByTag:1];
			if(myKitty._isTurning)
				[myKitty stopTurning];
			[self animateButtonReleaseWithTag:5];
			
		}
		if(ccpDistance(location, button6.position) < buttonReleaseTolerance * button6.contentSize.width/2)
		{
			Kitty *myKitty = (Kitty *) [self getChildByTag:2];
			if(myKitty._isTurning)
				[myKitty stopTurning];	
			[self animateButtonReleaseWithTag:6];
			
		}
		if(ccpDistance(location, button7.position) < buttonReleaseTolerance * button7.contentSize.width/2)
		{
			Kitty *myKitty = (Kitty *) [self getChildByTag:3];
			if(myKitty._isTurning)
				[myKitty stopTurning];	
			[self animateButtonReleaseWithTag:7];
			
			
			
		}
		
		
		
		
		
	}
}

-(void) addButtons {	
	
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	int padding = 8;
	int buttonPosition = padding + _buttonSize;
	
	CCSprite* mySprite;
	
	
	for (int i = 0; i <= 3; ++i) 
	{		
		if([[isPlayerActiveArray objectAtIndex:i] integerValue])
		{
			if(i==0) // bottom left
			{
				mySprite = [CCSprite spriteWithFile:@"cb4.png"];
				mySprite.position = ccp(buttonPosition/2,buttonPosition/2);
			}
			else if(i==1) //bottom right
			{
				mySprite = [CCSprite spriteWithFile:@"cb5.png"];
				mySprite.position = ccp(screenSize.width - buttonPosition/2, buttonPosition/2);
			}
			else if(i==2) // top right
			{
				mySprite = [CCSprite spriteWithFile:@"cb6.png"];
				mySprite.position = ccp(screenSize.width - buttonPosition/2, screenSize.height - buttonPosition/2);
			}
			else if(i==3) // top left
			{
				mySprite = [CCSprite spriteWithFile:@"cb7.png"];
				mySprite.position = ccp(buttonPosition/2, screenSize.height - buttonPosition/2);
			}
			
			mySprite.tag = 4 + i;
			float myScale = _buttonSize/mySprite.contentSize.width;
			_maxButtonScale = myScale; //used in animateButtonPress function
			[mySprite runAction: [CCScaleBy actionWithDuration:0.05 scale:myScale]];
			
			[self addChild:mySprite z:10];
		}
	}
	
	_minButtonScale = _maxButtonScale*0.94;
	
	//add pause button
	CCSprite* pausebutton = [CCSprite spriteWithFile:@"pausebutton2.png"];
	pausebutton.tag = 13;
	pausebutton.position = ccp(screenSize.width / 2.0, (screenSize.height - (pausebutton.contentSize.height/2 + padding)));
	[self addChild:pausebutton z:10];
	
	
}

-(void) animateButtonPressWithTag: (int)tag
{	
	CCSprite *button = (CCSprite*) [self getChildByTag:tag];
	
	if((button.scale == _maxButtonScale) && (![button numberOfRunningActions]))
	{
		NSString *textureName = [NSString stringWithFormat: @"cb%idepressed.png", tag];
		CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: textureName];
		[button setTexture: tex];
		
		
		CCAction* scaleDown = [CCScaleBy actionWithDuration:0.015 scale:0.94];
		scaleDown.tag = 104;
		[button runAction:scaleDown];
	}
	
	
	
	
}

-(void) animateButtonReleaseWithTag: (int)tag
{
	CCSprite *button = (CCSprite*) [self getChildByTag:tag];
	
	
	if((button.scale == _minButtonScale) && (![button numberOfRunningActions]))
	{
		NSString *textureName = [NSString stringWithFormat: @"cb%i.png", tag];
		CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: textureName];
		[button setTexture: tex];
		
		CCAction* scaleUp = [CCScaleBy actionWithDuration:0.03 scale:(1/0.94)];
		scaleUp.tag = 105;
		[button runAction:scaleUp];
	}
	
}

-(void) addKitties {
	
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	for (int i = 0; i <= 3; ++i) {
		if([[isPlayerActiveArray objectAtIndex:i] integerValue])
		{
			//set position of kitty
			CGPoint position;
			if(i == 0) {
				position = ccp(screenSize.width/4, screenSize.height/4);
			}
			else if(i == 1) {
				position = ccp(screenSize.width*3/4, screenSize.height/4);
			}
			else if(i==2) {
				position = ccp(screenSize.width*3/4, screenSize.height*3/4);
			}
			else if(i==3) {
				position = ccp(screenSize.width/4, screenSize.height*3/4);
			}
			
			//initialize and add kitty
			Kitty *kitty = [Kitty kittyWithParentNode:self position:position tag:i world:_world];
			[self addChild:kitty];
			
			//add kitty to kittyArray
			[kittyArray addObject:kitty];
			
		}
		
	}
	
	
	int mustacheXoffset = 70; //value taken from AI file
	
	//add mustaches to kitties
	for (int i=0; i<[kittyArray count]; ++i)
	{
		Kitty *kitty = (Kitty*) [kittyArray objectAtIndex:i];
		int mustacheNumber = 1 + [[[[GameManager sharedGameManager] selectedMustacheArray] objectAtIndex:kitty.tag] integerValue];
		NSString *imageName = [NSString stringWithFormat: @"Layer-%i.png", mustacheNumber];
		CCSprite *musSprite = [CCSprite spriteWithFile:imageName];
		musSprite.position = ccp(kitty.sprite.contentSize.width/2 + mustacheXoffset, kitty.sprite.contentSize.height/2);
		[kitty.sprite addChild:musSprite];
		
	}
	
	
}

-(void) addPellet: (ccTime) dt {
	
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float myScale = 0.5f;
	BOOL isBehindKitty = YES;
	
	CCSprite* mySprite = [CCSprite spriteWithFile:@"pellet.png"];
	[mySprite setColor:ccc3(244,131,96)];
	mySprite.tag = 8;
	[self addChild:mySprite];
	[mySprite runAction: [CCScaleBy actionWithDuration:0.1 scale:myScale]];
	
	// Create body 
	b2BodyDef dynamicBodyDef;
	dynamicBodyDef.type = b2_dynamicBody;
	
	int padding = _buttonSize;
	CGPoint pos = [self makeRandomPointWithPadding:padding];
	
	//dynamicBodyDef.position.Set(randomX/PTM_RATIO, randomY/PTM_RATIO);
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
	
	[self createPowerupCollectible:9 fileName:@"starIcon.png"];
	
}

-(void) addTurret {
	
	[self createPowerupCollectible:10 fileName:@"bulletIcon.png"];
	
}

-(void) addLightning {
	
	[self createPowerupCollectible:12 fileName:@"lightningIcon copy.png"];
}

-(void) addBombs {
	
	[self createPowerupCollectible:14 fileName:@"bombIcon.png"];
}

-(void) createPowerupCollectible:(int) tag fileName:(NSString*) fileName
{
	
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	float myScale = 0.7;
	CCSprite* mySprite = [CCSprite spriteWithFile:fileName];
	mySprite.tag = tag;
	mySprite.scale = myScale;
	[self addChild:mySprite];
	
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
	[self schedule: @selector(addPowerup:) interval:_powerupInterval];
}

-(void) addPowerup: (ccTime) dt 
{
//	int mod = _powerupCallCount%9;
//	++_powerupCallCount;
//        	
//	if(mod == 2)
//		[self addTurre[t];
//	else if(mod==5)
//		[self addBombs];
//	else if(mod==8)
//		[self addLightning];
//	else 
//		[self addStar];
    
    
    int lightningProb = 15;
    int turretProb = 20;
    int bombProb = 20;
    int starProb = 45;
    
    int rand = arc4random()%100 + 1;
    
    if(rand <= lightningProb)
        [self addLightning];
    else if(rand <= lightningProb + turretProb)
         [self addTurret];
    else if(rand <= lightningProb + turretProb + bombProb)
        [self addBombs];
    else 
        [self addStar];
    

	
}

-(void) increaseBallSizeWithScale: (NSMutableArray *) kittiesToGrow scales:(NSMutableArray *) growScales {
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	for(int i = 0; i < [kittiesToGrow count]; ++i) {
		int tag = [[kittiesToGrow objectAtIndex:i] integerValue];
		Kitty* myKitty = (Kitty*) [self getChildByTag:tag];
		float myScale = [[growScales objectAtIndex:i] floatValue];
		[myKitty growWithScale: myScale];
		
		
	}
}

-(void) decreaseBallSizeWithScale: (NSMutableArray *) kittiesToShrink scales:(NSMutableArray *) shrinkScales {
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	for(int i = 0; i < [kittiesToShrink count]; ++i) {
		int tag = [[kittiesToShrink objectAtIndex:i] integerValue];
		Kitty* myKitty = (Kitty*) [self getChildByTag:tag];
		float myScale = [[shrinkScales objectAtIndex:i] floatValue];
		[myKitty shrinkWithScale: myScale];
		
	}
}

-(CGPoint) makeRandomPointWithPadding: (int) padding
{
	//create a random spawn point that does not conflict with current body positions
	int randomX, randomY;
	BOOL isBehindKitty = YES;
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	CGPoint pos;
	
	//make a point, then ceck the point against all body positions, if they overlap, make another one
	while(isBehindKitty){
		isBehindKitty = NO;
		randomX = padding + (arc4random() % (int)(screenSize.width - 2 * padding)); 
		randomY = padding + (arc4random() % (int)(screenSize.height - 2 * padding)); 
		pos = ccp(randomX, randomY);
		for(int i = 0; i<=3; ++i)
		{
			Kitty* kitty = (Kitty*)[self getChildByTag:i];
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
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float delay = 0.04f;
	CCSequence* blinkScreen = [CCSequence actions: [CCCallFunc actionWithTarget:self selector:@selector(setBGColorGreen)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorBlue)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorPink)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorYellow)], [CCDelayTime actionWithDuration:delay],
							   [CCCallFunc actionWithTarget:self selector:@selector(setBGColorGrey)], [CCDelayTime actionWithDuration:delay],
							   nil];
	CCSequence* repeatBlinkScreen = [CCSequence actions:blinkScreen, blinkScreen, blinkScreen,nil];
	[self runAction:repeatBlinkScreen];
	
	/*
	 //move three lightning bolts onto screen
	 //change the size, placement and timing of each bolt
	 int spacing = 50;
	 
	 CCSprite* lightning1 = [CCSprite spriteWithFile:@"bigWhiteLightning.png"];
	 lightning1.tag = 14;
	 lightning1.position = ccp(screenSize.width/2, screenSize.height*3/2);
	 [self addChild:lightning1 z:-1];
	 
	 CCSprite* lightning2 = [CCSprite spriteWithFile:@"bigWhiteLightning.png"];
	 lightning2.tag = 15;
	 lightning2.position = ccp(screenSize.width/2-spacing, screenSize.height*3/2);
	 lightning2.scale = 0.8;
	 [self addChild:lightning2 z:-2];
	 
	 CCSprite* lightning3 = [CCSprite spriteWithFile:@"bigWhiteLightning.png"];
	 lightning3.tag = 16;
	 lightning3.scale = 0.6;
	 lightning3.position = ccp(screenSize.width/2+spacing, screenSize.height*3/2);
	 [self addChild:lightning3 z:-3];
	 
	 CCSequence* lightningSequence = [CCSequence actions:[lightning1 runAction:moveLightning],
	 [CCDelayTime actionWithDuration:delay],
	 [lightning2 runAction:moveLightning],
	 [CCDelayTime actionWithDuration:delay],
	 [lightning3 runAction:moveLightning],
	 [CCDelayTime actionWithDuration:removeDelay],
	 [CCCallFunc actionWithTarget:self selector:@selector(removeLightning)], nil];
	 
	 */
	
	//lets try just one bolt, I'm having trouble with that sequence
	
	CCSprite* lightning1 = [CCSprite spriteWithFile:@"lightningWhite.png"];
	lightning1.tag = 14;
	lightning1.position = ccp(screenSize.width/2, screenSize.height*3/2);
	[self addChild:lightning1 z:-1];
	
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
	//for(int i = 14; i<=16; ++i)
	[self removeChildByTag:14 cleanup:YES];
}


-(void) setBGColorGreen
{
	//bgLayer.color = ccc3(96, 246, 133);
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
    float selfScale = screenHeight/(kittyHeight + padding * kittyHeight);
    
    float dur = 0.2f;
    
    [self runAction:[CCScaleTo actionWithDuration:dur scale:selfScale]];
    
    [self runAction:[CCRotateTo actionWithDuration:dur angle:kitty.rotation]];
    
    self.anchorPoint = ccp(0.5f, 0.5f);
    [self runAction:[CCMoveTo actionWithDuration:dur position:kitty.position]];
    
    
    [self schedule:@selector(zoomOut) interval:2.0f];
    
}

-(void) zoomOut {
    
    [self unschedule:@selector(zoomOut)];
    
    float dur = 0.2f;
    [self runAction:[CCScaleTo actionWithDuration:dur scale:1.0f]];
    [self runAction:[CCRotateTo actionWithDuration:dur angle:0]];
    self.anchorPoint = ccp(0,0);
    [self runAction:[CCMoveTo actionWithDuration:dur position:ccp(0,0)]];
    
}
     
     


-(void) pause
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	//[[CCDirector sharedDirector] pause];
	[self unschedule: @selector(tick:)];
	[self unschedule: @selector(addPellet:)];
	[self unschedule: @selector(addPowerup:)];
	//[[CCActionManager sharedManager] pauseAllActionsForTarget:self];
	[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	_paused = YES;
	
	//pause all actions
	for(CCNode *child in self.children)
	{
//		[[CCActionManager sharedManager] pauseAllActionsForTarget:child];
        [[CCActionManager sharedManager] pauseTarget:child];
	}
	
	//pause all Kitties
	for(int i = 0; i <= 3; ++i)
	{
		Kitty* myCat = (Kitty*) [self getChildByTag:i];
		[myCat pauseKitty];
	}
	
	//CCAction* moveOnScreen = [CCMoveBy actionWithDuration:0.3f position:ccp(screenSize.width, 0) ];
    CCAction* moveOnScreen = [CCMoveTo actionWithDuration:0.3f position:ccp(screenSize.width/2 - 849*0.8f/2, screenSize.height/2 - 548*0.8f/2) ];
    ccp(-screenSize.width/2 - 849*0.8f/2, screenSize.height/2 - 548*0.8f/2);
	CCEaseInOut* ease = [CCEaseInOut actionWithAction:moveOnScreen rate:3];
	[pauseMenuLayer runAction:ease];
	
}

-(void) unpause
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	//[[CCDirector sharedDirector] resume];
	[self schedule: @selector(tick:)];
	[self schedule: @selector(addPellet:) interval:_pelletInterval];
	[self schedule: @selector(addPowerup:) interval:_powerupInterval];
	//[[CCActionManager sharedManager] resumeAllActionsForTarget:self];
	
    if([[GameManager sharedGameManager] musicOn])
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
	_paused = NO;
	
	//pause all actions
	for(CCNode *child in self.children)
	{
//		[[CCActionManager sharedManager] resumeAllActionsForTarget:child];
        [[CCActionManager sharedManager] resumeTarget:child];

	}
	
	//unpause all kitties
	//pause all Kitties
	for(int i = 0; i <= 3; ++i)
	{
		Kitty* myCat = (Kitty*) [self getChildByTag:i];
		[myCat unpauseKitty];
	}
	
	//CCAction* moveOffScreen = [CCMoveBy actionWithDuration:0.3f position:ccp(-screenSize.width, 0)];
	
    CCAction* moveOffScreen = [CCMoveTo actionWithDuration:0.3f position:ccp(-screenSize.width/2 - 849*0.8f/2, screenSize.height/2 - 548*0.8f/2) ];
    CCEaseInOut* ease = [CCEaseInOut actionWithAction:moveOffScreen rate:3];
	[pauseMenuLayer runAction:ease];
}

-(void) resetGame
{
	[[CCDirector sharedDirector] replaceScene:[StartMenuScene scene]];
	
}

-(void) addPauseMenu
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	
	pauseMenuLayer = [CCLayerColor layerWithColor:ccc4(150, 150, 150, 150) width:849 height:548]; 
    pauseMenuLayer.scale = 0.8f;
	pauseMenuLayer.position = ccp(-screenSize.width/2 - 849*0.8f/2, screenSize.height/2 - 548*0.8f/2);
	//pauseMenuLayer.position = ccp(screenSize.width/2, screenSize.height/2);
	pauseMenuLayer.anchorPoint = ccp(0,0);
	[self addChild:pauseMenuLayer z:8]; 
	
	
//	// set CCMenuItemFont default properties
	[CCMenuItemFont setFontName:@"Courier"];
	[CCMenuItemFont setFontSize:46];
	CCMenuItemFont* item2 = [CCMenuItemFont itemFromString:@"Force Game End" target:self selector:@selector(menuItem2Touched:)];
    CCMenu *menuuu = [CCMenu menuWithItems:item2, nil];
    menuuu.position = ccp(screenSize.width/2.0f, screenSize.height*0.9f);
    //[self addChild:menuuu];
//	
//	
//	// create a few labels with text and selector
//	CCMenuItemFont* item1 = [CCMenuItemFont itemFromString:@"Restart" target:self selector:@selector(menuItem1Touched:)];
//    musicToggle = [CCMenuItemFont itemFromString:@"Music: Off" target:self selector:@selector(musicToggleTouched:)];
//    sfxToggle = [CCMenuItemFont itemFromString:@"SFX: On" target:self selector:@selector(sfxToggleTouched:)];
    
    float shrinkScale = 0.97f;
    CCMenuItemImage * playButton = [CCMenuItemImage itemFromNormalImage:@"playButtonPauseMenu.png" selectedImage:@"playButtonPauseMenu.png" target:self selector:@selector(playPressed:)];
    playButton.selectedImage.scale = shrinkScale;
    playButton.selectedImage.position = ccp((playButton.normalImage.contentSize.width - playButton.normalImage.contentSize.width*shrinkScale)/2.0f, (playButton.normalImage.contentSize.height - playButton.normalImage.contentSize.height*shrinkScale)/2.0f);
    
    CCMenu *playMenu = [CCMenu menuWithItems:playButton, nil];
    playMenu.position = CGPointMake(424,314);
    [pauseMenuLayer addChild:playMenu];
    
    
    CCMenuItemImage * thanksButton = [CCMenuItemImage itemFromNormalImage:@"thanksButton.png" selectedImage:@"thanksButton.png" target:self selector:@selector(thanksPressed:)];
    thanksButton.selectedImage.scale = shrinkScale;
    thanksButton.selectedImage.position = ccp((thanksButton.normalImage.contentSize.width - thanksButton.normalImage.contentSize.width*shrinkScale)/2.0f, (thanksButton.normalImage.contentSize.height - thanksButton.normalImage.contentSize.height*shrinkScale)/2.0f);
    
    CCMenu *thanksMenu = [CCMenu menuWithItems:thanksButton, nil];
    thanksMenu.position = CGPointMake(305, 96);
    [pauseMenuLayer addChild:thanksMenu];
    
    CCMenuItemImage * quitButton = [CCMenuItemImage itemFromNormalImage:@"quitButton.png" selectedImage:@"quitButton.png" target:self selector:@selector(quitPressed:)];
    quitButton.selectedImage.scale = shrinkScale;
    quitButton.selectedImage.position = ccp((quitButton.normalImage.contentSize.width - quitButton.normalImage.contentSize.width*shrinkScale)/2.0f, (quitButton.normalImage.contentSize.height - quitButton.normalImage.contentSize.height*shrinkScale)/2.0f);
    
    CCMenu *quitMenu = [CCMenu menuWithItems:quitButton, nil];
    quitMenu.position = CGPointMake(734,489);
    [pauseMenuLayer addChild:quitMenu];
    
    
    //music and sound buttons
    id on = [[CCMenuItemImage itemFromNormalImage:@"MusicButtonOn.png" 
                                    selectedImage:@"MusicButtonOff.png" target:nil selector:nil] retain];
    id off = [[CCMenuItemImage itemFromNormalImage:@"MusicButtonOff.png" 
                                     selectedImage:@"MusicButtonOn.png" target:nil selector:nil] retain];
    CCMenuItemToggle *toggle = [CCMenuItemToggle itemWithTarget:self 
                                     selector:@selector(musicToggleTouched:) items:on, off, nil];
    CCMenu *toggleMenu = [CCMenu menuWithItems:toggle, nil];
    toggleMenu.position = ccp(703,137); 
    [pauseMenuLayer addChild:toggleMenu];
    
    id on2 = [[CCMenuItemImage itemFromNormalImage:@"soundButtonOn.png" 
                                    selectedImage:@"soundButtonOff.png" target:nil selector:nil] retain];
    id off2 = [[CCMenuItemImage itemFromNormalImage:@"soundButtonOff.png" 
                                     selectedImage:@"soundButtonOn.png" target:nil selector:nil] retain];
    CCMenuItemToggle *toggle2 = [CCMenuItemToggle itemWithTarget:self 
                                                       selector:@selector(sfxToggleTouched:) items:on2, off2, nil];
    CCMenu *toggleMenu2 = [CCMenu menuWithItems:toggle2, nil];
    toggleMenu2.position = ccp(703,59);
    [pauseMenuLayer addChild:toggleMenu2];



	
//	// create the menu using the items
//	CCMenu* menu = [CCMenu menuWithItems:item1, item2, musicToggle, sfxToggle, nil];
//	menu.position = ccp(pauseMenuLayer.contentSize.width/2, pauseMenuLayer.contentSize.height/2);
//	menu.tag = 200;
//    [menu setColor:ccWHITE];
//	[pauseMenuLayer addChild:menu z:1];
//	
//	// calling one of the align methods is important, otherwise all labels will occupy the same location
//	[menu alignItemsVerticallyWithPadding:40];
	
}

-(void) menuItem1Touched:(id)sender {
	
	[self resetGame];
	
}

-(void) menuItem2Touched:(id)sender {
	
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
        [[musicToggle label] setString:@"Music: Off"];

    }
    else
    {
        [[GameManager sharedGameManager] setMusicOn:YES];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MapleLeafRag.mp3" loop:YES];
        [[musicToggle label] setString:@"Music: On"];

    }    
}

-(void) sfxToggleTouched:(id)sender {
    
    if([[GameManager sharedGameManager] sfxOn])
    {
        [[GameManager sharedGameManager] setSfxOn:NO];
        [[sfxToggle label] setString:@"SFX: Off"];
        
    }
    else
    {
        [[GameManager sharedGameManager] setSfxOn:YES];
        [[sfxToggle label] setString:@"SFX: On"];
        
    }    
}



-(void) gameDone {
	
	//store final kitty scales for use in GameOverScene
	for(int i=0; i<[kittyArray count]; ++i)
	{
		Kitty *kitty = (Kitty*) [kittyArray objectAtIndex:i];
		
		[[[GameManager sharedGameManager] finalKittyScales] 
		 replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:kitty.sprite.scale]];
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
	// in case you have something to dealloc, do it in this method
	
    //[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	//[SimpleAudioEngine end];
	
	[kittyArray dealloc];
	
	delete _contactListener;
	delete _world;
	_world = NULL;
	
	delete m_debugDraw;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
