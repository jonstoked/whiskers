//
//  MSGroupNode.mm
//  cake
//
//  Created by Jon Stokes on 7/26/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "MSGroupNode.h"


@implementation MSGroupNode

@synthesize isActive, msNode;

+(id) msGroupNodeWithTag:(int)tag
{
	return [[[self alloc] initWithTag:tag] autorelease];
}

-(id) initWithTag:(int)tag
//-(id) init
{
	if( (self=[super init])) 
	{
		isActive = NO;
        fadeSwipeTextCalled = NO;
		
		//add mustacheSelectNode
		self.tag = tag;
		msNode = [MustacheSelectNode mustacheSelectNodeWithTag:self.tag];
		//msNode.position = ccp(128*0.3,0);
		msNode.position = ccp(57*0.3,0);
		[self addChild:msNode];
		[msNode makeInactive];
		
//		CCSprite *joinButtonSprite = [CCSprite spriteWithFile:@"joinButton.png"];
//		CCSprite *joinButtonDepressedSprite = [CCSprite spriteWithFile:@"joinButtonDepressed.png"];
//		CCMenuItemSprite *joinButton = [CCMenuItemSprite itemFromNormalSprite:joinButtonSprite selectedSprite:joinButtonDepressedSprite 
//															   disabledSprite:nil target:self selector:@selector(join:)];
//		
//		//offset depressed sprite so it looks as if button drops directly onto the dropshadow
//		joinButtonDepressedSprite.anchorPoint = ccp(-4.0/joinButtonDepressedSprite.contentSize.width,
//													-2.0/joinButtonDepressedSprite.contentSize.height);
        
        float shrinkScale = 0.97f;
        CCMenuItemImage * joinButton = [CCMenuItemImage itemFromNormalImage:@"joinButtonDepressed.png" selectedImage:@"joinButtonDepressed.png" target:self selector:@selector(join:)];
        joinButton.selectedImage.scale = shrinkScale;
        joinButton.selectedImage.position = ccp((joinButton.normalImage.contentSize.width - joinButton.normalImage.contentSize.width*shrinkScale)/2.0f, (joinButton.normalImage.contentSize.height - joinButton.normalImage.contentSize.height*shrinkScale)/2.0f);
		
		joinMenu = [CCMenu menuWithItems:joinButton, nil];
		
		//add swipe instruction menu that tells user to swipe so they can select a  mustache
		swipeInstruction = [CCNode new];
		[self addChild:swipeInstruction];
		swipeText = [CCSprite spriteWithFile:@"swipeText.png"];
		swipeArrow = [CCSprite spriteWithFile:@"swipeArrow.png"];
		[swipeInstruction addChild:swipeText];
		[swipeInstruction addChild:swipeArrow];
		swipeInstruction.visible = NO;
		
		//position values taken directly from AI file
		joinMenu.position = ccp(0, -125);
		swipeInstruction.position = joinMenu.position;
		[self addChild:joinMenu];
		
		//add this later after you figure out the ccbitmapfontatlas
		/*
		 //add Swipe to select mustache instructions
		 CCLabelTTF *swipeInstructions = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
		 swipeInstructions.color = ccc3(0,0,0);
		 //swipeInstructions.position = ccp(winSize.width/2, winSize.height/2);
		 [self addChild:swipeInstructions];
		 */
		
		
		
	}
	
	return self;
	
}

-(void) join:(id)sender {
	
	joinMenu.position = ccp(-500,0);
	swipeInstruction.visible = YES;
    id moveLeft = [CCMoveBy actionWithDuration:1.0f position:ccp(-400, 0)];
    [swipeArrow runAction:moveLeft];
	[msNode makeActive];
	isActive = YES;
	
	
}

-(void) done {
    
    
}


-(void) fadeSwipeText {
    if(!fadeSwipeTextCalled)
    {
        id fadeout = [CCFadeOut actionWithDuration:0.5f];
        [swipeText runAction:fadeout];
        fadeSwipeTextCalled = YES;
    }
}

@end
