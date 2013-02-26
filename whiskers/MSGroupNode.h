//
//  MSGroupNode.h
//  cake
//
//  Created by Jon Stokes on 7/26/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MustacheSelectNode.h"

@interface MSGroupNode : CCNode {
	
	MustacheSelectNode *msNode;
	CCMenu *joinMenu;
	BOOL isActive;
	CCNode *swipeInstruction;
    CCSprite *swipeArrow;
    CCSprite *swipeText;
    BOOL fadeSwipeTextCalled;
    CCSprite *name;
	
}

@property (nonatomic,readwrite) BOOL isActive;
@property (nonatomic, readwrite) MustacheSelectNode *msNode;


+(id) msGroupNodeWithTag:(int)tag;
-(id) initWithTag:(int)tag;
-(void) fadeSwipeText;



@end
