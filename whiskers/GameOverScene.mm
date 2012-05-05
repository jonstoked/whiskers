//
//  GameOverScene.m
//  cake
//
//  Created by Jon Stokes on 3/15/11.
//  Copyright 2010 Jon Stokes. All rights reserved.
//

#import "GameOverScene.h"



@implementation GameOverScene

+(id) scene
{
	CCScene* scene = [CCScene node];
	CCLayer* mainLayer = [GameOverScene node];
	[scene addChild:mainLayer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {

	
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)];
		[self addChild:bgLayer z:-10];
		
		for(int i=0; i < [[GameManager sharedGameManager] finalKittyScales].count; ++i)
			CCLOG(@"finalKittyScales[%i] = %f", i, [[[[GameManager sharedGameManager] finalKittyScales] objectAtIndex:i] floatValue]);
		
		NSMutableArray *kittySpriteArray = [[NSMutableArray alloc] init];
		NSMutableArray *finalKittyScales = [[GameManager sharedGameManager] finalKittyScales];
		NSMutableArray *isPlayerActiveArray = [[GameManager sharedGameManager] isPlayerActiveArray];
				
		//add kitty sprites
		for(int i = 0; i<=3; ++i)
		{
			if([[isPlayerActiveArray objectAtIndex:i] integerValue])
			{

				//add kitty sprites to array with scales from game manager
				CCSprite *kittySprite = [CCSprite spriteWithFile:@"francineWhite.png"];
				kittySprite.tag = i;
				kittySprite.scale = [[finalKittyScales objectAtIndex:i] floatValue];
	
				//set color of kitty
				switch (i) {
					case 0:
					{
						[kittySprite setColor:ccc3(96, 246, 133)];
						break;
					}
					case 1:
					{
						[kittySprite setColor:ccc3(246, 207, 95)];
						break;
					}
					case 2:
					{
						[kittySprite setColor:ccc3(95, 134, 246)];
						break;
					}
					case 3:
					{
						[kittySprite setColor:ccc3(246, 95, 209)];
						break;
					}
				}
				
				[kittySpriteArray addObject:kittySprite];
				CCLOG(@"pre-sorted kitty scale[%i]: %f", i, kittySprite.scale);
				
			}
		}//end for
		
		int mustacheXoffset = 70; //value taken from AI file
		
		//add mustaches to kitties
		for (int i=0; i<[kittySpriteArray count]; ++i)
		{
			CCSprite *kittySprite = (CCSprite*) [kittySpriteArray objectAtIndex:i];
			int mustacheNumber = 1 + [[[[GameManager sharedGameManager] selectedMustacheArray] objectAtIndex:kittySprite.tag] integerValue];
			NSString *imageName = [NSString stringWithFormat: @"Layer-%i.png", mustacheNumber];
			CCSprite *musSprite = [CCSprite spriteWithFile:imageName];
			musSprite.position = ccp(kittySprite.contentSize.width/2 + mustacheXoffset, kittySprite.contentSize.height/2);
			//musSprite.position = ccpAdd(musSprite.position, ccp(mustacheXoffset, 0));
			[kittySprite addChild:musSprite];
			
		}
		
		
		//sort kittySpriteArray by scales, so they are added to screen largest to smallest
		NSSortDescriptor *sortDescriptor;
		sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"scale" ascending:NO] autorelease];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		NSArray *sortedKittySpriteArray;
		sortedKittySpriteArray = [kittySpriteArray sortedArrayUsingDescriptors:sortDescriptors];
		
		//the kitties will be stacked on top of each other, biggest to smallest, to show their relative size
		//each consecutive kitty will be offset to the right by...
		//CGPoint kittyOffset = ccp(134,0); //some random screen math :)
        CGPoint kittyOffset = ccp(134,0); //some random screen math :)
		
		
        float allKittiesWidth = 0.0f;
		//add kitties to screen
		for(int i = 0 ; i < [sortedKittySpriteArray count]; ++i)
		{
			CCSprite *sprite = (CCSprite*) [sortedKittySpriteArray objectAtIndex:i];
            CCLOG(@"kitty width: %f", sprite.boundingBox.size.width);

			//resize largest kitty to exact winning scale and add winner text to top of screen
			if(i==0)
			{
				[self addWinnerTextForSprite:sprite];
				//if(sprite.scale > 0.8f)
					sprite.scale = 0.8f;  //winning size
                allKittiesWidth = allKittiesWidth + sprite.boundingBox.size.width;
			}
            else  {
                allKittiesWidth = allKittiesWidth + 30.0f;
            }
        }
        
        //CGPoint biggestKittyLowerRight = ccp(screenSize.width/2, screenSize.height/4);
        CGPoint biggestKittyLowerRight;

        for(int i = 0 ; i < [sortedKittySpriteArray count]; ++i)
		{
			CCSprite *sprite = (CCSprite*) [sortedKittySpriteArray objectAtIndex:i];
            if(i==0) {
                 biggestKittyLowerRight = ccp(screenSize.width/2.0f - allKittiesWidth/2.0f + sprite.boundingBox.size.width, screenSize.height/4);
            }
                
			
			sprite.anchorPoint = ccp(1,0);
            
			sprite.position = ccpAdd(biggestKittyLowerRight, ccpMult(ccp(30.0f,0.0f), (float) i));
			
			//move a kitty on screen every half second
			[self performSelector:@selector(moveNodeOnScreenFromLeft:) withObject:sprite afterDelay:0.5*i];
			
			CCLOG(@"postsorted kitty scale[%i]: %f", i, sprite.scale);
			
			
			//add background to kitty so you can't see through him
			CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"francineBackground.png"];
			backgroundSprite.anchorPoint = ccp(0,0);
			[sprite addChild:backgroundSprite z:-1];
			 
			
		}
		
		[self addButtons];
		
		
	}	
	return self;
}

//add to JSLibrary
-(void)moveNodeOnScreenFromLeft:(CCNode *)node

{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	[self addChild:node];
	CGPoint finalPosition = node.position;
	node.position = ccp(node.position.x-screenSize.width, node.position.y);
	CCAction* moveOnScreen = [CCMoveTo actionWithDuration:0.3f position:finalPosition];
	CCEaseInOut* ease = [CCEaseInOut actionWithAction:moveOnScreen rate:3];
	[node runAction:ease];
}


-(void) addWinnerTextForSprite: (CCSprite*) sprite
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	CCSprite *winnerText;
	
	switch (sprite.tag) {
		case 0:
		{
			winnerText = [CCSprite spriteWithFile:@"clarenceWins.png"];
			break;
		}
		case 1:
		{
			winnerText = [CCSprite spriteWithFile:@"helenWins.png"];
			break;
		}
		case 2:
		{
			winnerText = [CCSprite spriteWithFile:@"johnrWins.png"];
			break;
		}
		case 3:
		{
			winnerText = [CCSprite spriteWithFile:@"margieWins.png"];
			break;
		}
	}
	
	winnerText.color = sprite.color;
	winnerText.position = ccp(screenSize.width/2, 688); //taken from AI file
	[self addChild:winnerText];
}

- (void) addButtons
{
	//offset depressed sprite so it looks as if button drops directly onto the dropshadow
	CGPoint depressedButtonOffset = ccp(6,2);
	
	//playAgain Button
	CCSprite *buttonNormal = [CCSprite spriteWithFile:@"playAgainButton.png"];
	CCSprite *buttonDepressed = [CCSprite spriteWithFile:@"playAgainButtonDepressed.png"];
	CCMenuItemSprite *menuItem = [CCMenuItemSprite itemFromNormalSprite:buttonNormal selectedSprite:buttonDepressed 
										   disabledSprite:nil target:self selector:@selector(playAgain:)];
	buttonDepressed.position = depressedButtonOffset;

	CCMenu *menu = [CCMenu menuWithItems:menuItem, nil];
	[self addChild:menu];
	menu.position = CGPointMake(359,96);  //from AI file
	
	
	//home Button
	CCSprite *buttonNormal2 = [CCSprite spriteWithFile:@"homeButton.png"];
	CCSprite *buttonDepressed2 = [CCSprite spriteWithFile:@"homeButtonDepressed.png"];
	CCMenuItemSprite *menuItem2 = [CCMenuItemSprite itemFromNormalSprite:buttonNormal2 selectedSprite:buttonDepressed2 
														 disabledSprite:nil target:self selector:@selector(resetGame:)];
	buttonDepressed2.position = depressedButtonOffset;
	
	CCMenu *menu2 = [CCMenu menuWithItems:menuItem2, nil];
	[self addChild:menu2];
	menu2.position = CGPointMake(721,96);  //from AI file
	
}

- (void)resetGame:(id) sender {

	[[CCDirector sharedDirector] replaceScene:[StartMenuScene scene]];
	
}
	
- (void)playAgain:(id) sender {
	
	[[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
	
}

- (void)dealloc {

	[super dealloc];
}

@end
