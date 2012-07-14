//
//  PowerupsScene.h
//  cake
//
//  Created by Jon Stokes on 2/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "StartMenuScene.h"

@interface PowerupsScene : CCLayer {
    
    CCLayer *scrollableLayer;
    

    
}

+(id) scene;
- (void)panForTranslation:(CGPoint)translation;


@end
