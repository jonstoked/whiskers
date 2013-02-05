//
//  FLTwitter.h
//
//  Created by Tod Cunningham on 10/23/11.
//  Copyright (c) 2011 TCC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Twitter/Twitter.h"

@interface FLTwitter : NSObject
{
    Class m_tweeterClass;
    
    id _listener;
    SEL _callback;
}

+ (FLTwitter *)defaultManager;

- (bool)isTwitterAvailable;
- (bool)canSendTweet;

- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text url:(NSURL *)url image:(UIImage *)image;
- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text url:(NSURL *)url image:(UIImage *)image;
- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text image:(UIImage *)image;
- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text;

//Rally additions
- (void)sendTweetFromViewController:(UIViewController *)viewController withText:(NSString *)text withListener: (id) listener withCallback: (SEL) callback;

- (void)sendTweetFromViewController: (UIViewController *)viewController
                           withText: (NSString *)text
                                url: (NSURL *)url
                              image: (UIImage *)image
                       withListener: (id) listener
                       withCallback: (SEL) callback;

@end
