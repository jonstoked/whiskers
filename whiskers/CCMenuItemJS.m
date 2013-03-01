//
//  CCMenuItemJS.mm
//  whiskers
//
//  Created by Jon Stokes on 3/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCMenuItemJS.h"


@implementation CCMenuItemJS

-(void) selected {
    
    [[GameManager sharedGameManager] playRandomMeow];
    [super selected];
}

@end
