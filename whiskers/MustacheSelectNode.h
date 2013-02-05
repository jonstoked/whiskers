//
//  MustacheSelectNode.h
//  cake
//
//  Created by Jon Stokes on 7/8/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameManager.h"


@interface MustacheSelectNode : CCNode {
	
	int mustacheCount;
	CCSprite *kitty;
	float kittyScale;
	int mustacheSeparationDistance;
	CCSpriteBatchNode *mustacheBatchNode;
	int minX;
	int maxX;
	ccTime timePrevious;
	ccTime timeCurrent;
	CGPoint touchPrevious;
	CGPoint touchCurrent;
	NSMutableArray *mustacheArray;
	BOOL isSelected;
	BOOL isActive;
	int currentMustacheTag;
	NSString *mustacheYoffsets;
	CGRect touchableArea;
	float swipeVelocity;
    float swipeAcceleration;
    BOOL isSwipe;
    
    CGPoint touchStart;
    
    CCLabelTTF *rewardLabel;
    BOOL hasShownNewStacheMessage;
	

}

@property (nonatomic,readwrite) BOOL isActive;
@property (nonatomic,readwrite) BOOL hasShownNewStacheMessage;


+(id) mustacheSelectNodeWithTag:(int)tag;
-(id) initWithTag:(int)tag;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event ;
- (void)panForTranslation:(CGPoint)translation ;    
- (CGPoint)boundLayerPos:(CGPoint)newPos ;



@end
