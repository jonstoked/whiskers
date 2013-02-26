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
{
	if( (self=[super init])) 
	{
		isActive = NO;
        fadeSwipeTextCalled = NO;
		
		//add mustacheSelectNode
		self.tag = tag;
		msNode = [MustacheSelectNode mustacheSelectNodeWithTag:self.tag];
		msNode.position = ccp(57*0.3,0);
		[self addChild:msNode];
		[msNode makeInactive];
        
        joinMenu = [[GameManager sharedGameManager] menuAtPosition:ccp(-13,-125) imageName:@"joinButton.png" target:self selector:@selector(join)];
        [self addChild:joinMenu];
		
		//add swipe instruction menu that tells user to swipe so they can select a  mustache
		swipeInstruction = [CCNode new];
		[self addChild:swipeInstruction];
		swipeText = [CCSprite spriteWithFile:@"swipeText.png"];
		swipeArrow = [CCSprite spriteWithFile:@"swipeArrow.png"];
		[swipeInstruction addChild:swipeText];
		[swipeInstruction addChild:swipeArrow];
		swipeInstruction.visible = NO;
        swipeInstruction.position = joinMenu.position;
        
        NSString *nameString;
        switch (tag) {
            case 0:
                nameString = @"clarence.png";
                break;
            case 1:
                nameString = @"helen.png";
                break;
            case 2:
                nameString = @"johnr.png";
                break;
            case 3:
                nameString = @"margie.png";
                break;
                
            default:
                break;
        }
        
        name = [CCSprite spriteWithFile:nameString];
        [self addChild:name];
        name.position = swipeInstruction.position;
        name.opacity = 0;
		
	}
	
	return self;
	
}

-(void) join {
	
	joinMenu.position = ccp(-500,0);
	swipeInstruction.visible = YES;
    id moveLeft = [CCMoveBy actionWithDuration:1.0f position:ccp(-400, 0)];
    [swipeArrow runAction:moveLeft];
	[msNode makeActive];
	isActive = YES;
	
	
}


-(void) fadeSwipeText {
    if(!fadeSwipeTextCalled)
    {
        id fadeout = [CCFadeOut actionWithDuration:0.5f];
        [swipeText runAction:fadeout];
        fadeSwipeTextCalled = YES;
        [self schedule:@selector(fadeInName) interval:0.6f];
    }
}

-(void) fadeInName {
    [self unschedule:@selector(fadeInName)];
    id fadein = [CCFadeIn actionWithDuration:0.5f];
    [name runAction:fadein];
}

@end
