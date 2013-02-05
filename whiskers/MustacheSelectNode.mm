//
//  MustacheSelectNode.mm
//  cake
//
//  Created by Jon Stokes on 7/8/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "MustacheSelectNode.h"
#import "MSGroupNode.h"


@implementation MustacheSelectNode



+(id) mustacheSelectNodeWithTag:(int)tag
{
	return [[[self alloc] initWithTag:tag] autorelease];
}

-(id) initWithTag:(int)tag
{
	if( (self=[super init])) 
	{
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		kittyScale = 0.3f;
		self.isRelativeAnchorPoint = YES;
		timeCurrent = (ccTime) 0;
		isActive = YES;
		self.tag = tag;
		
		//create sprite batch node
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		mustacheBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"orangeMustaches.pvr.ccz"];
		mustacheBatchNode.position = self.position;
		[self addChild:mustacheBatchNode];    
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"orangeMustaches.plist"];
		
		//create array of mustache image names
		mustacheArray = [[NSMutableArray alloc] init];
		for (int i = 1; i <= 51; ++i)
		{
			NSString *imageName = [NSString stringWithFormat: @"Layer-%i.png", i];
			[mustacheArray addObject:imageName]; 
		}
        
        //hackerrific - make the logo staches the first four staches after the mario stache
        // swap...
        // 2 for 51
        // 3 for 32
        // 4 for 43
        // 5 for 15
        
        [self swapIndecesForArray:mustacheArray index1:1 index2:50];
        [self swapIndecesForArray:mustacheArray index1:2 index2:31];
        [self swapIndecesForArray:mustacheArray index1:3 index2:42];
        [self swapIndecesForArray:mustacheArray index1:4 index2:14];

		//add kitty
		kitty = [CCSprite spriteWithFile:@"francineWhiteWithTail.png"];
		
		//offset kitty to line up so mustache is centered under eyes
		kitty.anchorPoint = ccp(0.7,0.5);
		kitty.position = self.position; 
		kitty.tag = 100;
		kitty.scale = kittyScale;
		[self addChild:kitty z:-10];
		
		//CCLOG(@"kitty.tag: %i", kitty.tag);
		//set the color of the kitty
		switch (tag) {
			case 0:
			{
				[kitty setColor:ccc3(96, 246, 133)];
				break;
			}
			case 1:
			{
				[kitty setColor:ccc3(246, 207, 95)];
				break;
			}
			case 2:
			{
				[kitty setColor:ccc3(95, 134, 246)];
				break;
			}
			case 3:
			{
				[kitty setColor:ccc3(246, 95, 209)];
				break;
			}
		}
				
		mustacheSeparationDistance = screenSize.width/4;
		mustacheCount = mustacheArray.count - 1;
        
        //load mustache y offset array
        NSString *path = [[NSBundle mainBundle] pathForResource:
                          @"mustacheYoffsets" ofType:@"plist"];
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];

        
        // Build the array from the plist  
        //NSString *posString = [layoutDict objectForKey:key];
        //NSMutableArray *offsets = [[NSMutableArray alloc] initWithContentsOfFile:path];
        NSMutableArray *offsets = [dict objectForKey:@"Root"];
        
        //hackerific again, make mustache offsets match new first five mustaches
//        [self swapIndecesForArray:offsets index1:1 index2:50];
//        [self swapIndecesForArray:offsets index1:2 index2:31];
//        [self swapIndecesForArray:offsets index1:3 index2:42];
//        [self swapIndecesForArray:offsets index1:4 index2:14];

        CCLOG(@"offsets count: %i", [offsets count]);
		
		//create mustache sprites
		for(int i = 0; i <= mustacheCount; ++i) 
		{
			NSString *image = [mustacheArray objectAtIndex:i];
			CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:image];
			//mustache needs to be at x value of 438 pixels from the left of the kitty
			//int xOffset = kittyScale* (438 - kitty.contentSize.width/2);
			//sprite.position = ccp((kitty.position.x + xOffset + mustacheSeparationDistance*i), kitty.position.y);
			
            sprite.position = ccp((kitty.position.x + mustacheSeparationDistance*i), kitty.position.y - kittyScale*[[offsets objectAtIndex:i] intValue]);
//            CCLOG(@"mustache %i offset: %i", i, [[offsets objectAtIndex:i] intValue]);
//            CCLOG(@"mustache %i offset: %@", i, [offsets objectAtIndex:i]);

			sprite.tag = i;
			sprite.opacity = 0;
			[mustacheBatchNode addChild:sprite];
		}
		
		
		maxX = [mustacheBatchNode getChildByTag:0].position.x;
		minX = -[mustacheBatchNode getChildByTag:mustacheCount].position.x;
		//CCLOG(@"minX: %i", minX);
		//CCLOG(@"maxX: %i", maxX);
		
		//define touchable area
		switch (tag) {
			case 0:
			{
				touchableArea = CGRectMake(0,0, screenSize.width/2, screenSize.height/2);
				break;
			}
			case 1:
			{
				touchableArea = CGRectMake(screenSize.width/2, 0, screenSize.width/2, screenSize.height/2);
				break;
			}
			case 2:
			{
				touchableArea = CGRectMake(screenSize.width/2,screenSize.height/2, screenSize.width/2, screenSize.height/2);
				break;
			}
			case 3:
			{
				touchableArea = CGRectMake(0,screenSize.height/2, screenSize.width/2, screenSize.height/2);
				break;
			}
		}
		

		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
		
		[self schedule: @selector(tick:)];
		
		//schedule update to selected mustache each half second
		[self schedule:@selector(updateSelectedMustaches:) interval:0.5];

	}
	
	return self;
	
}

-(void) swapIndecesForArray:(NSMutableArray*)array index1:(int)index1 index2:(int)index2 {
    
    NSObject *placeHolder = [array objectAtIndex:index1];
    [mustacheArray replaceObjectAtIndex:index1 withObject:[mustacheArray objectAtIndex:index2]];
    [mustacheArray replaceObjectAtIndex:index2 withObject:placeHolder];
    
}

-(void) tick: (ccTime) dt
{

	CGSize screenSize = [CCDirector sharedDirector].winSize;

	CGPoint kittyWorldPos = [self convertToWorldSpace:kitty.position];
	//CCLOG(@"kitty position x: %f, y: %f", kittyWorldPos.x, kittyWorldPos.y);

	 //set opacity of sprite depending on how far it is from kitty
	 for(int i = 0; i <= mustacheCount; ++i)
	 {
		 CCSprite *currentMus = (CCSprite*) [mustacheBatchNode getChildByTag:i];
		 CGPoint mustacheWorldPos = [mustacheBatchNode convertToWorldSpace:currentMus.position];
         CGPoint mustacheNodePos = [self convertToNodeSpace:currentMus.position];

		 if(isActive) {
			 currentMus.opacity = (255*(mustacheSeparationDistance - ccpDistance(mustacheWorldPos, kittyWorldPos))/mustacheSeparationDistance);
             if(ccpDistance(mustacheWorldPos, kittyWorldPos) >= mustacheSeparationDistance)
                 currentMus.opacity = 0;

         }
             
		 else 
			 currentMus.opacity = (100*(mustacheSeparationDistance - ccpDistance(mustacheWorldPos, kittyWorldPos))/mustacheSeparationDistance);
		 
		 //set currentMustacheTag
		 if(ccpDistance(kittyWorldPos, mustacheWorldPos) < mustacheSeparationDistance/2.0) 
			 currentMustacheTag = i;

	 }
	
	timeCurrent += dt;  
	
	
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    if(isActive)
    {
        for( UITouch *touch in touches ) 
		{
            touchStart = [self convertTouchToNodeSpace:touch];

        }
    }
}


-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if(isActive)
	{
		for( UITouch *touch in touches ) 
		{
			
			CGPoint currentTouch = [self convertTouchToNodeSpace:touch];
			CGPoint currentTouchWorld = [self convertToWorldSpace:currentTouch];
            
            
            //if swipe is greater than threshold
			if ((CGRectContainsPoint(touchableArea, currentTouchWorld)) && (ccpDistance(touchStart, currentTouch) > 30))
			{					
				//make scrolling continue with velocity of swipe
				float scrollDuration = .3;  //maxSD = 1.5, minSD = .3  as SV goes from 0 to 5000
				float easeRate = 1;			 //maxER = 5, minER = 1 as SV goes from 0 to 5000
				CGPoint destination =  CGPointMake(swipeVelocity*scrollDuration, 0);
				//CCLOG(@"destination.x before: %f", destination.x);
				
				destination = ccpAdd(destination, mustacheBatchNode.position);  //make position absolute
				
				//make desination exactly on mustache, so one is always centered on kitties face
				destination.x = (int)destination.x;
				if(((int)destination.x % mustacheSeparationDistance) <= mustacheSeparationDistance/2)
					destination.x = destination.x - ((int)destination.x % mustacheSeparationDistance);
				else 
					destination.x = destination.x + (mustacheSeparationDistance - ((int)destination.x % mustacheSeparationDistance));

				//CCLOG(@"destination.x after: %f", destination.x);
				//CCLOG(@"mustacheBatchNode Pos x: %f, y: %f", mustacheBatchNode.position.x, mustacheBatchNode.position.y);
				
				CGPoint boundedDestination = [self boundLayerPos:destination];  //bound the destination

				CCMoveTo *swipeDecelerate = [CCMoveTo actionWithDuration:scrollDuration position:boundedDestination];
				id ease = [CCEaseOut actionWithAction:swipeDecelerate rate:2];
//                id ease = [CCEaseExponentialOut actionWithAction:swipeDecelerate];
				[mustacheBatchNode runAction:ease];
                
                [(MSGroupNode *)self.parent fadeSwipeText];
			}
		}
	}
	
}

//cctouchesmoved layer scroll methodology taken from RW >> http://www.raywenderlich.com/2343/how-to-drag-and-drop-sprites-with-cocos2d
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
	if(isActive)
	{
		for( UITouch *touch in touches ) {
		
			//UITouch *touch = [touches anyObject];  

			CGPoint currentTouch = [self convertTouchToNodeSpace:touch];
			CGPoint currentTouchWorld = [self convertToWorldSpace:currentTouch];
			
			if (CGRectContainsPoint(touchableArea, currentTouchWorld))
			{
				//CCLOG(@"touchLocation x: %f, y: %f", touchLocation.x, touchLocation.y);

				CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
				oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
				oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
				
				//calculate swipe velocity
				float dx = currentTouch.x - oldTouchLocation.x;
				float dt = timeCurrent - timePrevious;
				swipeVelocity = dx/dt;
                swipeAcceleration = swipeVelocity/dt;
				timePrevious = timeCurrent;
				
				//CCLOG(@"dx: %f", dx);
				//CCLOG(@"dt: %f", dt);
				CCLOG(@"swipeVelocity: %f", swipeVelocity);
                //CCLOG(@"swipeAcceleration: %f", swipeAcceleration);


				CGPoint translation = ccpSub(currentTouch, oldTouchLocation);    
				[self panForTranslation:translation];  
                

			}
		}
	}
	
}

//cctouchesmoved layer scroll methodology taken from RW >> http://www.raywenderlich.com/2343/how-to-drag-and-drop-sprites-with-cocos2d
- (void)panForTranslation:(CGPoint)translation {    

	CGPoint pos = ccpAdd(mustacheBatchNode.position, translation);
	CGPoint newPos = [self boundLayerPos:pos];
	
	mustacheBatchNode.position = newPos;  
    //CCLOG(@"mustacheBatchNode pos x: %f, y: %f", mustacheBatchNode.position.x, mustacheBatchNode.position.y);
     
}

//checks boundary positions
- (CGPoint)boundLayerPos:(CGPoint)newPos {
	//CCLOG(@"boundlayerpos!");
    CGPoint retval = newPos;
	retval.x = MAX(retval.x, minX); //minX = -12Kish
	retval.x = MIN(retval.x, maxX); //maxX = 0
	retval.y = 0;
    return retval;
}

- (void) makeActive
{
	if(!isActive)
	{
		isActive = YES;
		
		//set opacity for children
		kitty.opacity = 255;
	}
}

- (void) makeInactive
{
	if(isActive)
	{
		isActive = NO;
		
		//set full opacity for children
		kitty.opacity = 100;
		
	}
}


//updates selectedMustachesArray in GameManager to carry mustache over to HelloWorldScene
- (void) updateSelectedMustaches: (ccTime) dt
{
	//CCLOG(@"self.tag:      %i", self.tag);
	//CCLOG(@"currentMusTag: %i", currentMustacheTag);	
	[[[GameManager sharedGameManager] selectedMustacheArray] replaceObjectAtIndex:self.tag withObject:[NSNumber numberWithInt:currentMustacheTag]];
}

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
	[super onEnter];
}

- (void)onExit
{
	//[self updateSelectedMustaches];

	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (void) dealloc
{	
	[mustacheArray dealloc];
	
	[super dealloc];
	
}

	

@end
