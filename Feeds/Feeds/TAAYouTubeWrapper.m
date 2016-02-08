//
//  TAAYouTubeWrapper.m
//  TAAYouTubeWrapper
//
//  Created by Daniel Salber on 24/11/15.
//  Copyright © 2015 The App Academy. All rights reserved.
//
//  Version: 1.3, 9-Dec-2015
//

#import "TAAYouTubeWrapper.h"
#import "GTLYouTube.h"


typedef void(^channelCompletionBlock)(BOOL succeeded, GTLYouTubeChannel *channel, NSError *error);

static NSString *kYouTubeChannelParts = @"id,snippet,brandingSettings,contentDetails,invideoPromotion,statistics,status,topicDetails";
static NSString *kYouTubePlaylistItemParts = @"id,snippet,contentDetails,status";
static NSString *kYouTubeVideoParts = @"id,snippet,contentDetails,status";


@interface TAAYouTubeWrapper ()

@property GTLServiceYouTube *youTubeService;

@end

@implementation TAAYouTubeWrapper

#pragma mark - Public API

// user name -> videos
+ (void)videosForUser:(NSString *)userName onCompletion:(videosCompletionBlock)completionBlock
{
    return [[TAAYouTubeWrapper sharedInstance] videosForUserName:userName onCompletion:completionBlock];
}

// playlist name -> videos
+ (void)videosForPlaylist:(NSString *)playlistName forUser:(NSString *)userName onCompletion:(videosCompletionBlock)completionBlock
{
    return [[TAAYouTubeWrapper sharedInstance] videosForPlaylistName:playlistName forUserName:userName onCompletion:completionBlock];
}

// channel id -> videos
+ (void)videosForChannel:(NSString *)channelIdentifier onCompletion:(videosCompletionBlock)completionBlock
{
    return [[TAAYouTubeWrapper sharedInstance] videosForChannelIdentifier:channelIdentifier onCompletion:completionBlock];
}

// playlist name, channel id -> videos
+ (void)videosForPlaylist:(NSString *)playlistName forChannel:(NSString *)channelIdentifier onCompletion:(videosCompletionBlock)completionBlock;
{
    return [[TAAYouTubeWrapper sharedInstance] videosForPlaylistName:playlistName forChannelIdentifier:channelIdentifier onCompletion:completionBlock];
}

// user name -> playlists
+ (void)playlistsForUser:(NSString *)userName onCompletion:(playlistsCompletionBlock)completionBlock
{
    return [[TAAYouTubeWrapper sharedInstance] playlistsForUserName:userName onCompletion:completionBlock];
}


#pragma mark - Init

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.youTubeService = [GTLServiceYouTube new];
        self.youTubeService.APIKey = kYouTubeAPIKey;
        NSAssert(self.youTubeService.APIKey.length > 0, @"You need to provide a valid API key.");
    }
    return self;
}


#pragma mark - Internal API

// user name -> channel -> uploads playlist id -> videos
- (void)videosForUserName:(NSString *)userName onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(userName);
    
    [self channelForUserName:userName onCompletion:^(BOOL succeeded, GTLYouTubeChannel *channel, NSError *error) {
        if (succeeded) {
            NSAssert(channel, @"no channel");
            NSAssert1(error == nil, @"error: %@", error.localizedDescription);
            NSString *uploadsID = channel.contentDetails.relatedPlaylists.uploads;
            if (uploadsID.length > 0) {
                [self videosForPlaylistIdentifier:uploadsID onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
                    if (succeeded) {
                        NSAssert1(error == nil, @"error: %@", error.localizedDescription);
                    }
                    if (completionBlock) {
                        completionBlock(succeeded, videos, error);
                    }
                }];
            }
        } else if (completionBlock) {
            completionBlock(succeeded, nil, error);
        }
    }];
}

// user name -> channel -> playlists -> playlist matching playlist name -> videos
- (void)videosForPlaylistName:(NSString *)playlistName forUserName:(NSString *)userName onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(playlistName);
    NSParameterAssert(userName);

    [self channelForUserName:userName onCompletion:^(BOOL succeeded, GTLYouTubeChannel *channel, NSError *error) {
        if (succeeded) {
            NSAssert(channel, @"no channel");
            NSAssert1(error == nil, @"error: %@", error.localizedDescription);
            [self videosForPlaylistName:playlistName forChannel:channel onCompletion:completionBlock];
        } else if (completionBlock) {
            completionBlock(succeeded, nil, error);
        }
    }];
}

// channel identifier -> channel -> playlists -> playlist matching playlist name -> videos
- (void)videosForPlaylistName:(NSString *)playlistName forChannelIdentifier:(NSString *)channelIdentifier onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(playlistName);
    NSParameterAssert(channelIdentifier);
    
    [self channelForIdentifier:channelIdentifier onCompletion:^(BOOL succeeded, GTLYouTubeChannel *channel, NSError *error) {
        if (succeeded) {
            NSAssert(channel, @"no channel");
            NSAssert1(error == nil, @"error: %@", error.localizedDescription);
            [self videosForPlaylistName:playlistName forChannel:channel onCompletion:completionBlock];
        } else if (completionBlock) {
            completionBlock(succeeded, nil, error);
        }
    }];
}

// channel -> playlists -> playlist matching playlist name -> videos
- (void)videosForPlaylistName:(NSString *)playlistName forChannel:(GTLYouTubeChannel *)channel onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(playlistName);
    NSParameterAssert(channel);
    
    [self playlistsForChannel:channel onCompletion:^(BOOL succeeded, NSArray *playlists, NSError *error) {
        if (succeeded) {
            NSAssert1(error == nil, @"error: %@", error.localizedDescription);
            NSArray *filteredPlaylists = [playlists filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                NSAssert([evaluatedObject isKindOfClass:[GTLYouTubePlaylist class]], @"not a playlist");
                GTLYouTubePlaylist *playlist = evaluatedObject;
                GTLYouTubePlaylistSnippet *snippet = playlist.snippet;
                NSAssert1(snippet, @"no snippet for playlist %@", playlist);
                return [snippet.title isEqualToString:playlistName];
            }]];
            GTLYouTubePlaylist *foundPlaylist = [filteredPlaylists firstObject];
            if (foundPlaylist) {
                [self videosForPlaylist:foundPlaylist onCompletion:completionBlock];
            } else if (completionBlock) {
                completionBlock(succeeded, nil, error);
            }
        } else if (completionBlock) {
            completionBlock(succeeded, nil, error);
        }
    }];
}


// username -> channel -> playlists
- (void)playlistsForUserName:(NSString *)userName onCompletion:(playlistsCompletionBlock)completionBlock
{
    NSParameterAssert(userName);
    
    [self channelForUserName:userName onCompletion:^(BOOL succeeded, GTLYouTubeChannel *channel, NSError *error) {
        if (succeeded) {
            NSAssert(channel, @"no channel");
            NSAssert1(error == nil, @"error: %@", error.localizedDescription);
            [self playlistsForChannel:channel onCompletion:^(BOOL succeeded, NSArray *playlists, NSError *error) {
                if (succeeded) {
                    NSAssert1(error == nil, @"error: %@", error.localizedDescription);
                }
                if (completionBlock) {
                    completionBlock(succeeded, playlists, error);
                }
            }];
        } else if (completionBlock) {
            completionBlock(succeeded, nil, error);
        }
    }];
}

//channel identifier -> channel -> uploads playlist id -> videos
- (void)videosForChannelIdentifier:(NSString *)channelIdentifier onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(channelIdentifier);
    
    [self channelForIdentifier:channelIdentifier onCompletion:^(BOOL succeeded, GTLYouTubeChannel *channel, NSError *error) {
        if (succeeded) {
            NSAssert(channel, @"no channel");
            NSAssert1(error == nil, @"error: %@", error.localizedDescription);
            NSString *uploadsID = channel.contentDetails.relatedPlaylists.uploads;
            if (uploadsID.length > 0) {
                [self videosForPlaylistIdentifier:uploadsID onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
                    if (succeeded) {
                        NSAssert1(error == nil, @"error: %@", error.localizedDescription);
                    }
                    if (completionBlock) {
                        completionBlock(succeeded, videos, error);
                    }
                }];
            }
        } else if (completionBlock) {
            completionBlock(succeeded, nil, error);
        }
    }];
}


#pragma mark - YouTube Queries

// playlist -> playlist items -> videos
- (void)videosForPlaylist:(GTLYouTubePlaylist *)playlist onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(playlist);
    
    [self videosForPlaylistIdentifier:playlist.identifier onCompletion:completionBlock];
}

// playlist ID -> playlist items -> videos
- (void)videosForPlaylistIdentifier:(NSString *)playlistIdentifier onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(playlistIdentifier);
    
    GTLQueryYouTube *playlistItemsQuery = [GTLQueryYouTube queryForPlaylistItemsListWithPart:kYouTubePlaylistItemParts];
    playlistItemsQuery.maxResults = 50; // max, see https://developers.google.com/youtube/v3/docs/playlistItems/list
    playlistItemsQuery.playlistId = playlistIdentifier;
    
    [self.youTubeService executeQuery:playlistItemsQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistItemListResponse *object, NSError *error) {
        NSArray *playlistItems = nil;
        if (!error) {
            playlistItems = object.items;
            if (playlistItems) {
                [self videosForPlaylistItems:playlistItems onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
                    if (succeeded) {
                        NSAssert1(error == nil, @"error: %@", error.localizedDescription);
                        if (completionBlock) {
                            completionBlock(succeeded, videos, error);
                        }
                    }
                }];
            } else if (completionBlock) {
                completionBlock(error == nil, playlistItems, error);
            }
        } else {
            if (completionBlock) {
                completionBlock(error == nil, playlistItems, error);
            }
        }
    }];
}

// playlist items -> videos
- (void)videosForPlaylistItems:(NSArray *)playlistItems onCompletion:(videosCompletionBlock)completionBlock
{
    NSParameterAssert(playlistItems);

    NSArray *videosIDs = [NSArray new];
    
    // extract video IDs from playlistItems
    for (GTLYouTubePlaylistItem *playlistItem in playlistItems) {
        NSString *videoID = playlistItem.contentDetails.videoId;
        NSAssert(videoID.length > 0, @"empty ID");
        videosIDs = [videosIDs arrayByAddingObject:videoID];
    }
    
    GTLQueryYouTube *videosQuery = [GTLQueryYouTube queryForVideosListWithPart:kYouTubeVideoParts];
    NSAssert(videosIDs.count > 0, @"no IDs found");
    videosQuery.identifier = (videosIDs.count > 1 ? [videosIDs componentsJoinedByString:@","] : [videosIDs firstObject]);
    
    [self.youTubeService executeQuery:videosQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *object, NSError *error) {
        NSArray *videos = nil;
        if (!error) {
            videos = object.items;
        }
        if (completionBlock) {
            completionBlock(error == nil, videos, error);
        }
    }];
}

// username -> channels -> first channel
- (void)channelForUserName:(NSString *)userName onCompletion:(channelCompletionBlock)completionBlock
{
    NSParameterAssert(userName);
    
    GTLQueryYouTube *channelQuery = [GTLQueryYouTube queryForChannelsListWithPart:kYouTubeChannelParts];
    channelQuery.forUsername = userName;
    
    [self.youTubeService executeQuery:channelQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *object, NSError *error) {
        GTLYouTubeChannel *channel = nil;
        if (!error) {
            channel = [object.items firstObject];
        }
        if (completionBlock) {
            completionBlock(error == nil, channel, error);
        }
    }];
}

// channel id -> channels -> first channel
- (void)channelForIdentifier:(NSString *)channelIdentifier onCompletion:(channelCompletionBlock)completionBlock
{
    NSParameterAssert(channelIdentifier);
    
    GTLQueryYouTube *channelQuery = [GTLQueryYouTube queryForChannelsListWithPart:kYouTubeChannelParts];
    channelQuery.identifier = channelIdentifier;
    
    [self.youTubeService executeQuery:channelQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *object, NSError *error) {
        GTLYouTubeChannel *channel = nil;
        if (!error) {
            channel = [object.items firstObject];
        }
        if (completionBlock) {
            completionBlock(error == nil, channel, error);
        }
    }];
}

// channel -> channel id -> playlists
- (void)playlistsForChannel:(GTLYouTubeChannel *)channel onCompletion:(playlistsCompletionBlock)completionBlock
{
    NSParameterAssert(channel);
    
    static NSString *playlistParts = @"id,snippet,contentDetails,status";
    GTLQueryYouTube *playlistsQuery = [GTLQueryYouTube queryForPlaylistsListWithPart:playlistParts];
    playlistsQuery.channelId = channel.identifier;
    
    [self.youTubeService executeQuery:playlistsQuery completionHandler:^(GTLServiceTicket *ticket, GTLYouTubePlaylistListResponse *object, NSError *error) {
        NSArray *playlists = nil;
        if (!error) {
            playlists = object.items;
        }
        if (completionBlock) {
            completionBlock(error == nil, playlists, error);
        }
    }];
}

@end
