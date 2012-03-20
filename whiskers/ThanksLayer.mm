//
//  ThanksLayer.mm
//  cake
//
//  Created by Jon Stokes on 3/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ThanksLayer.h"


@implementation ThanksLayer

-(id) init
{
	if( (self=[super init] )) {
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        //CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255)]; 
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(70, 70, 70, 255) width:1024 height:993]; 
        colorLayer.position = ccp(0,768-993);
        
		[self addChild:colorLayer z:-1];
        

        
        
        
	}	
	return self;
}

@end
