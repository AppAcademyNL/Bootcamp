//
//  MasterViewController.m
//  Feeds
//
//  Created by Daniel Salber on 23/11/15.
//  Copyright © 2015 mackey.nl. All rights reserved.
//

#import "MasterViewController.h"
#import "TAAYouTubeWrapper.h"
#import "GTLYouTube.h"
#import "Feeds-Swift.h"


@interface MasterViewController ()

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) DetailViewController *detailViewController;

@end

@implementation MasterViewController

#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TAAYouTubeWrapper videosForUser:@"TVAcademyNL" onCompletion:^(BOOL succeeded, NSArray *videos, NSError *error) {
        NSAssert1(succeeded, @"error: %@", error);
        self.objects = videos;
        NSAssert([NSThread isMainThread], @"not main thread");
        [self.tableView reloadData];
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GTLYouTubeVideo *video = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        controller.video = video;
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell" forIndexPath:indexPath];

    GTLYouTubeVideo *object = self.objects[indexPath.row];
    cell.textLabel.text = object.snippet.title;
    
    // for demo purposes only; this is NOT an efficient way to display a thumbnail in a list
    NSString *imageUrl = object.snippet.thumbnails.standard.url;
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    cell.imageView.image = image;
    
    return cell;
}


@end
