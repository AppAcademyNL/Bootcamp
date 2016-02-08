//
//  YouTubeWrapperTests.m
//  Feeds
//
//  Created by Daniel Salber on 24/11/15.
//  Copyright © 2015 mackey.nl. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TAAYouTubeWrapper.h"

static double kYouTubeTimeout = 10.0;

@interface YouTubeWrapperTests : XCTestCase

@end

@implementation YouTubeWrapperTests

- (void)testVideosForPlaylistsTVAcademyNL {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];

    [TAAYouTubeWrapper videosForPlaylist:@"MADE BY TVA" forUser:@"TVAcademyNL" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count >= 3);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError *error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testPlaylistsTVAcademyNL {
    XCTestExpectation *expectation = [self expectationWithDescription:@"playlistsAvailable"];
    
    [TAAYouTubeWrapper playlistsForUser:@"TVAcademyNL" onCompletion:^(BOOL succeeded, NSArray *playlists, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(playlists.count >= 3);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError *error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testVideosForUserTVAcademyNL {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];

    [TAAYouTubeWrapper videosForUser:@"TVAcademyNL" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count >= 3);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError * _Nullable error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testVideosForPlaylistsGoogle {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];
    
    [TAAYouTubeWrapper videosForPlaylist:@"Non-existent playlist" forUser:@"Google" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count == 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError *error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testPlaylistsGoogle {
    XCTestExpectation *expectation = [self expectationWithDescription:@"playlistsAvailable"];
    
    [TAAYouTubeWrapper playlistsForUser:@"Google" onCompletion:^(BOOL succeeded, NSArray *playlists, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(playlists.count >= 3);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError *error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testVideosForUserGoogle {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];
    
    [TAAYouTubeWrapper videosForUser:@"Google" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count >= 3);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError * _Nullable error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testVideosForUserLateNightShow {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];
    
    [TAAYouTubeWrapper videosForUser:@"latenight" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count >= 50);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError * _Nullable error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testVideosForChannelWiseNose {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];
    
    [TAAYouTubeWrapper videosForChannel:@"UCRIw9Kbo8sY4cad9ZccJj8g" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count >= 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError * _Nullable error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testVideosForPlaylistInChannelVersus {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];
    
    [TAAYouTubeWrapper videosForPlaylist:@"Kop of Kop" forChannel:@"UCjYfcam-ZVQ7sxzwBvtmJmw" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count >= 1);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError *error) {
        XCTAssert(error == nil, @"timeout");
    }];
}

- (void)testVideosForUserMarina {
    XCTestExpectation *expectation = [self expectationWithDescription:@"videosAvailable"];
    
    [TAAYouTubeWrapper videosForUser:@"selinas2slns" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        XCTAssert(succeeded);
        XCTAssert(error == nil);
        XCTAssert(videos.count >= 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kYouTubeTimeout handler:^(NSError * _Nullable error) {
        XCTAssert(error == nil, @"timeout");
    }];
}


@end
