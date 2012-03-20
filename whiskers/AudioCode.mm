//
//  AudioCode.mm
//  cake
//
//  Created by Jon Stokes on 5/27/11.
//  Copyright 2011 Jon Stokes. All rights reserved.
//

#import "AudioCode.h"


@implementation AudioCode

-(id) init
{	
	if( (self=[super init] )) 
	{
		sewingMachineSound = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"sewingmachine.caf"] retain];
		sewingMachineSound.looping = YES;
			
			
			
			
	}
	
	return self;
}
		


@end
