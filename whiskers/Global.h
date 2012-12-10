//
//  Global.h
//  whiskers
//
//  Created by Jon Stokes on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef whiskers_Global_h
#define whiskers_Global_h

#define AUTO_START 0
#define DEBUG_KITTY_SCALE 0 //normal start is 0.08f

#define WIN_SCALE 1.0f
#define ABOUT_TO_WIN_SCALE 0.45f

#define TEST_POWERUP @"" // @"magnet"


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
    kTagCount
    
} kTag;




#endif
