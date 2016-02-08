//
//  TAAYouTubeWrapper.h
//  TAAYouTubeWrapper
//
//  Created by Daniel Salber on 24/11/15.
//  Copyright © 2015 The App Academy. All rights reserved.
//
//
//  How to use:
//  - add Google-API-Client to your Podfile
//  - copy TAAYouTubeWrapper.h/m into your project (not into the Pods)
//

#import <Foundation/Foundation.h>

#define kYouTubeAPIKey @"Put-your-own-Youtube-API-key-here"

typedef void(^videosCompletionBlock)(BOOL succeeded, NSArray *videos, NSError *error);
typedef void(^playlistsCompletionBlock)(BOOL succeeded, NSArray *playlists, NSError *error);

@interface TAAYouTubeWrapper : NSObject

// gets all the uploaded videos for the given user name as an array of GTLYouTubeVideo objects
+ (void)videosForUser:(NSString *)userName onCompletion:(videosCompletionBlock)completionBlock;

// gets all the videos in the given playlist for the given user name as an array of GTLYouTubeVideo objects
+ (void)videosForPlaylist:(NSString *)playlistName forUser:(NSString *)userName onCompletion:(videosCompletionBlock)completionBlock;

// gets all the videos for the given channel identifier as an array of GTLYouTubeVideo objects
+ (void)videosForChannel:(NSString *)channelIdentifier onCompletion:(videosCompletionBlock)completionBlock;

// gets all the videos in the given playlist for the given channel identifier as an array of GTLYouTubeVideo objects
+ (void)videosForPlaylist:(NSString *)playlistName forChannel:(NSString *)channelIdentifier onCompletion:(videosCompletionBlock)completionBlock;

// gets all the playlists for the given user name as an array of GTLYouTubePlaylist objects
+ (void)playlistsForUser:(NSString *)userName onCompletion:(playlistsCompletionBlock)completionBlock;

@end
