//
//  HelloWorldScene.h
//  cake
//
//  Created by Jon Stokes on 3/15/11.
//  Copyright Jon Stokes 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "SimpleAudioEngine.h"
#import "MyContactListener.h"
#import "Kitty.h"
#import "Bullet.h"
#import "GameOverScene.h"
#import "StartMenuScene.h"
#import "GameManager.h"
#import "Bomb.h"
#import "Global.h"  



// HelloWorld Layer
@interface HelloWorld : CCLayerColor
{
	b2World* _world;
	GLESDebugDraw *m_debugDraw;
	MyContactListener *_contactListener;
	
	
	int _buttonSize;
	int _powerupCallCount;
	float _pelletScale;
	BOOL _paused;
	float _pelletInterval;
	float _powerupInterval;
	CCLayerColor *pauseMenuLayer;
	CCLayerColor *bgLayer;
	float _minButtonScale;
	float _maxButtonScale;
	NSMutableArray *isPlayerActiveArray;
	NSMutableArray *kittyArray;  //array of active kitties, can contain less than 4 objects
    CCMenuItemFont *musicToggle;
    CCMenuItemFont *sfxToggle;

	
	
	
	
	
}

@property (nonatomic,readwrite) CCLayerColor* pauseMenuLayer;


// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(void) draw;
-(void) tick: (ccTime) dt;
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) addButtons;
-(void) addKitties;
-(void) addPellet: (ccTime) dt;
-(void) addStar;
-(void) addTurret;
-(void) addPowerup: (ccTime) dt;
-(void) increaseBallSize: (NSMutableArray *) kittiesToGrow;
-(void) decreaseBallSize: (NSMutableArray *) kittiesToShrink;
-(void) increaseBallSizeWithScale: (NSMutableArray *) kittiesToGrow scales:(NSMutableArray *) growScales;
-(void) decreaseBallSizeWithScale: (NSMutableArray *) kittiesToShrink scales:(NSMutableArray *) shrinkScales;
-(CGPoint) makeRandomPointWithPadding: (int) padding;
-(void) pause;
-(void) unpause;
-(void) resetGame;
-(void) addPauseMenu;


@end
