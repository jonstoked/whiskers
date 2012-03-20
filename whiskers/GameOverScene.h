//
//  GameOverScene.h
//  cake
//
//  Created by Jon Stokes on 3/15/11.
//  Copyright 2010 Jon Stokes. All rights reserved.
//

#import "cocos2d.h"
#import "HelloWorldScene.h"
#import "StartMenuScene.h"
#import "GameManager.h"
#import "MustacheScene.h"


@interface GameOverLayer {

}

@end

@interface GameOverScene : CCScene {
	GameOverLayer *_layer;
}

@property (nonatomic, retain) GameOverLayer *layer;

-(void) addWinnerTextForSprite: (CCSprite*) sprite;


@end
