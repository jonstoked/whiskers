//
//  MustacheScene.h
//  cake
//
//  Created by Jon Stokes on 5/12/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MustacheSelectNode.h"
#import "MSGroupNode.h"
#import "HelloWorldScene.h"
#import "StartMenuScene.h"


@interface MustacheScene : CCLayer {
	
	MSGroupNode *playerNode0;
	MSGroupNode *playerNode1;
	MSGroupNode *playerNode2;
	MSGroupNode *playerNode3;
	
	float kittyScale;
	NSMutableArray	*playerNodeArray;
	CCMenu *playMenu;
    CCMenu *modeMenu;
    
    CCSprite *newMode;
    BOOL showNewModeMessage;

}

@property (readwrite) NSMutableArray *playerNodeArray;


+(id) scene;

@end
