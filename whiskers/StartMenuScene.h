//
//  StartMenuScene.h
//  cake
//
//  Created by Jon Stokes on 4/11/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface StartMenuScene : CCLayer 
{
	CCSprite *kitty;
	CGPoint source;
	CCSpriteBatchNode *spritesBgNode;
	NSArray *images;
	NSMutableArray *activeMustaches;
	int mustacheCount;
	float offset;
	float kittyScale;
    CCMenuItemImage *powerupsButton;
    CCMenu *powerupsMenu;
    CCMenu *playMenu;
    CCLayer *infoLayer;
    BOOL infoVisible;
    CCLayerColor* colorLayer;
}

+(id) scene;

@end
