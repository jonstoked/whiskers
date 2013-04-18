//
//  Global.h
//  whiskers
//
//  Created by Jon Stokes on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef whiskers_Global_h
#define whiskers_Global_h


#define AUTO_START 1 //four kitties
#define ONLY_TWO_KITTIES 0
#define FORCE_GAME_END 0
#define ONE_KITTY_MOVING 0
#define NO_KITTIES_MOVING 0
#define DEBUG_KITTY_SCALE 0 //normal start is 0.08f, only one kitty scaled
#define SCALE_ALL_KITTIES 0
#define DONT_SPAWN_COLLECTIBLES 0
#define DEBUG_WENT_OFFSCREEN 0
#define SOUND_OFF 0
#define FORCE_ANALOG 0

#define TEST_POWERUP @""
//star
//turret
//bomb
//magnet
//lightning




#define START_SCALE 0.115f //0.08f
#define WIN_SCALE 0.9f
#define ABOUT_TO_WIN_SCALE 0.45f  //not currently used
#define GAME_FONT @"HelveticaNeue-Bold"
#define BOMB_EXPLOSION_RADIUS 256.0f

static const ccColor3B whiskersGreen = {96, 246, 133};
static const ccColor3B whiskersYellow = {246, 207, 95};
static const ccColor3B whiskersBlue = {95, 134, 246};
static const ccColor3B whiskersPink = {246, 95, 209};
static const ccColor3B whiskersOrange = {246, 132, 95};

typedef enum {
    POWERUP_TYPE_NONE,
    POWERUP_TYPE_TURRET,
    POWERUP_TYPE_BOMB,
    POWERUP_TYPE_LIGHTNING,
    POWERUP_TYPE_STAR,
    REQUEST_DATA_TYPE_COUNT,    
} kPowerupType;

typedef enum {
    kTagKitty0,
    kTagKitty1,
    kTagKitty2,
    kTagKitty3,
    kTagButton0,
    kTagButton1,                //5
    kTagButton2,
    kTagButton3,
    kTagPellet,
    kTagStar,
    kTagTurret,                 //10
    kTagBullet,
    kTagLightning,
    kTagPauseButton,
    kTagLightningSprite,
    kTagBombs,                  //15
    kTagBomb,                   
    kTagMagnet,
    kTagExplosion,
    kTagKitty0Streak,
    kTagKitty1Streak,           //20
    kTagKitty2Streak,
    kTagKitty3Streak,
    kTagInstruction0,
    kTagInstruction1,
    kTagInstruction2,           //25
    kTagInstruction3,
    kTagCount
    
} kTag;

//typedef enum {
//    kZorderKitty = -10,
//    kZorderMustache,
//    kZorderBomb,
//    kZorderPowerupCollectible,
//    
//} kZorder;




#endif
