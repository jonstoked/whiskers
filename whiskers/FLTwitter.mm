//
//  FLTwitter.m
//
//   Inspired from the work by Tony Ngo
//      http://tonyngo.net/2011/10/twitter-integration-tutorial/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+idevblogaday+%28iDevBlogADay%29
//
//  Created by Tod Cunningham on 10/23/11.
//  Copyright (c) 2011 TCC. All rights reserved.
//
#import "FLTwitter.h"

@implementation FLTwitter


static FLTwitter *_defaultTwitter = nil;

+ (FLTwitter *)defaultManager
{
	@synchronized( self )
	{
		if( _defaultTwitter  ==  nil )
			_defaultTwitter = [[FLTwitter alloc] init];
	}
	
	return _defaultTwitter;
}




- (id)init
{
	self = [super init];
	if( self != nil )
	{
        m_tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
	}
	
	return self;	
}




- (void)dealloc
{	
	[super dealloc];
}



// Twitter support was added in iOS5, this will make it so we don't "crash" in pre iOS5 environments by checking to 
// make sure the class is available.
- (bool)isTwitterAvailable
{
    return m_tweeterClass == nil ? NO : YES;
}




- (bool)canSendTweet
{
    if( !self.isTwitterAvailable )
        return NO;
    
    return [TWTweetComposeViewController canSendTweet];
}




- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text url:(NSURL *)url image:(UIImage *)image completionHandler:(TWTweetComposeViewControllerCompletionHandler)completionHandler
{ 
    if( !self.isTwitterAvailable )
        return;
    
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    [tweetViewController setInitialText:text];
    [tweetViewController addURL:url];
    [tweetViewController addImage:image];
    tweetViewController.completionHandler = completionHandler;
    
    [viewController presentViewController:tweetViewController animated:YES completion:nil];
    
    [tweetViewController autorelease];
}




- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text url:(NSURL *)url image:(UIImage *)image
{
    if( !self.isTwitterAvailable )
        return;
    
    TWTweetComposeViewControllerCompletionHandler tweetComplete = ^(TWTweetComposeViewControllerResult result)
    {
        if( result == TWTweetComposeViewControllerResultDone )
        {
            // the user finished composing a tweet
            
            if ([_listener respondsToSelector:_callback]) { 
                IMP call = [_listener methodForSelector:_callback];
                call(_listener,_callback,YES);
            }                        
        }
        else if(result == TWTweetComposeViewControllerResultCancelled)
        {
            // the user cancelled composing a tweet
            
            if ([_listener respondsToSelector:_callback]) { 
                IMP call = [_listener methodForSelector:_callback];
                call(_listener,_callback,NO);
            }               
        }
        
        [viewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self sendTweetFromViewController:viewController withText:text url:url image:image completionHandler:tweetComplete];
}


- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text image:(UIImage *)image
{
    return [self sendTweetFromViewController:viewController withText:text url:nil image:image];
}


- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text
{
    return [self sendTweetFromViewController:viewController withText:text url:nil image:nil];
}


//Rally additions
- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text withListener: (id) listener withCallback: (SEL) callback {
    
    _listener = listener;
    _callback = callback;
    
    return [self sendTweetFromViewController:viewController withText:text url:nil image:nil];
}

- (void)sendTweetFromViewController: (UIViewController *)viewController
                           withText: (NSString *)text
                                url: (NSURL *)url
                              image: (UIImage *)image
                       withListener: (id) listener
                       withCallback: (SEL) callback {
    
    _listener = listener;
    _callback = callback;
    
    return [self sendTweetFromViewController:viewController withText:text url:url image:image];
}




@end
