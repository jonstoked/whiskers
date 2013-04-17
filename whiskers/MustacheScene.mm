//
//  MustacheScene.mm
//  cake
//
//  Created by Jon Stokes on 5/12/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "MustacheScene.h"




@implementation MustacheScene

+(id) scene
{
	CCScene* scene = [CCScene node];
	CCLayer* mainLayer = [MustacheScene node];
	[scene addChild:mainLayer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
        
        [[GameManager sharedGameManager] logFlurryEvent:@"Displayed Mustache Menu"];
        
		//self.isTouchEnabled = YES;
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		kittyScale = 1.5f;
		
		//add background
		CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)];
		[self addChild:bgLayer z:-10];
        
        playMenu = [[GameManager sharedGameManager] menuAtPosition:ccp(screenSize.width/2, screenSize.height/2) imageName:@"playButtonMustacheScene.png" target:self selector:@selector(startGame:)];
		playMenu.opacity = 100;
        [self addChild:playMenu];
        
        //mode button
        NSString *on = [GameManager sharedGameManager].analogMode ? @"modeAnalog.png" : @"modeDigital.png";
        NSString *off = ![GameManager sharedGameManager].analogMode ? @"modeAnalog.png" : @"modeDigital.png";
        modeMenu = [[GameManager sharedGameManager] toggleMenuAtPosition:ccp(513,266) imageNameOn:on imageNameOff:off target:self selector:@selector(toggleMode)];
        modeMenu.opacity = 100;
        modeMenu.isTouchEnabled = NO;
        [self addChild:modeMenu];
        
        CCMenu *backMenu = [[GameManager sharedGameManager] menuAtPosition:CGPointMake(516, screenSize.height-47) imageName:@"backButton3.png" target:self selector:@selector(backButtonPressed:)];
        
		[self addChild:backMenu];

		//initialize player nodes
		playerNode0 = [MSGroupNode msGroupNodeWithTag:0];
		playerNode1 = [MSGroupNode msGroupNodeWithTag:1];
		playerNode2 = [MSGroupNode msGroupNodeWithTag:2];
		playerNode3 = [MSGroupNode msGroupNodeWithTag:3];
		
		//reset isPlayerActiveArray
		for (int i = 0; i <=3; ++i)
			[[[GameManager sharedGameManager] isPlayerActiveArray] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];

		
		playerNodeArray = [NSMutableArray arrayWithObjects:playerNode0, playerNode1, playerNode2, playerNode3, nil];
		for(int i = 0; i < [playerNodeArray count]; ++i)
		{
			MSGroupNode *currentNode = (MSGroupNode*) [playerNodeArray objectAtIndex:i];
			currentNode.position = ccp(screenSize.width/2, screenSize.height/2);
			[self addChild:currentNode];
			currentNode.tag = i;
						
		}
		
		[self moveKittiesToCorners];
						
		[playerNodeArray retain];  //so you can use it in the startGame method
		
		[self schedule: @selector(tick:) interval:0.1];
		
	}
	return self;
}

-(void) tick: (ccTime) dt
{
	[self updateIsPlayerActiveArray];
	
	//if two or more players have joined, show start game button
	int sum = 0;
	for(int i = 0; i<[[[GameManager sharedGameManager] isPlayerActiveArray] count]; ++i)
	{
		if([[[[GameManager sharedGameManager] isPlayerActiveArray] objectAtIndex:i] integerValue] != 0)
			++sum;
	}
		
	if(sum >= 2)
	{
        playMenu.opacity = 255;
        modeMenu.opacity = playMenu.opacity;
        modeMenu.isTouchEnabled = YES;
	}
		
}

-(void) moveKittiesToCorners
{
	
	//  kitty positions:  3 2
	//                    0 1
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	int padding = 220;
	float time = 0.4f;
	
	//FOR LATER!!
	//make these so you just loop through and create a pointer with getchildbytag, so you don't have to write out
	// each command four times
	
	CCAction *move1 = [CCMoveTo actionWithDuration:time position:ccp(padding, padding)];
	CCAction *move2 = [CCMoveTo actionWithDuration:time position:ccp(screenSize.width-padding, padding)];
	CCAction *move3 = [CCMoveTo actionWithDuration:time position:ccp(screenSize.width-padding, screenSize.height-padding)];
	CCAction *move4 = [CCMoveTo actionWithDuration:time position:ccp(padding, screenSize.height-padding)];
	
	CCAction *rotate1 = [CCRotateTo actionWithDuration:time angle:45];
	CCAction *rotate2 = [CCRotateTo actionWithDuration:time angle:-45];
	CCAction *rotate3 = [CCRotateTo actionWithDuration:time angle:-135];
	CCAction *rotate4 = [CCRotateTo actionWithDuration:time angle:135];
					   
	[playerNode0 runAction:move1];
	[playerNode0 runAction:rotate1];
	[playerNode1 runAction:move2];
	[playerNode1 runAction:rotate2];
	[playerNode2 runAction:move3];
	[playerNode2 runAction:rotate3];
	[playerNode3 runAction:move4];
	[playerNode3 runAction:rotate4];
    
//    id fadein = [CCFadeTo actionWithDuration:0.6f opacity:100];
//    [playMenu runAction:fadein];
//    [modeMenu runAction:fadein];
}

-(void) startGame:(id)sender {
    
    if(playMenu.opacity == 255) {
	
        //disable touches and switch scene
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
        [[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
        
    }
		
}

-(void) backButtonPressed:(id)sender {
	
	//disable touches and switch scene
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCDirector sharedDirector] replaceScene:[StartMenuScene scene]];
	
}

-(void) toggleMode {
    
    [GameManager sharedGameManager].analogMode = ![GameManager sharedGameManager].analogMode;

}

-(void) updateIsPlayerActiveArray
{
	//update isPlayerActiveArray in GameManager singleton to carry over to helloworld scene which players have joined the game
	for(int i = 0; i < [playerNodeArray count]; ++i)
	{
		MSGroupNode *currentGroupNode = (MSGroupNode *) [playerNodeArray objectAtIndex:i];
		BOOL isActive = [currentGroupNode isActive];
		[[[GameManager sharedGameManager] isPlayerActiveArray] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:isActive]];
		
	}
}
	

- (void) dealloc
{
    
    for(MSGroupNode* node in playerNodeArray) {
        if(node.msNode.hasShownNewStacheMessage == YES)
            [GameManager sharedGameManager].hasShownNewStacheMessage = YES;
    }
	
	
	[playerNodeArray dealloc];
	[super dealloc];
}
	
	
					   

					  

					   
					   
					   
					   
					   

					   
					   
					   
					   
					   
					   
					   
@end
