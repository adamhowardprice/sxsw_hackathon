//
//  ArtistBrowseViewController.m
//  Hydra
//
//  Created by Brian Gerstle on 3/10/13.
//  Copyright (c) 2013 Your Company. All rights reserved.
//

#import "ArtistBrowseViewController.h"
#import "AppDelegate.h"

@interface ArtistBrowseViewController ()

@end

@implementation ArtistBrowseViewController

#pragma mark - Object Lifecycle

- (void)privateInit
{
    if (!_artist && self) {
        [NSException raise:@"ArtistBrowseViewController" format:@"Missing artist for %@", self];
    }
    [_artist addObserver:self forKeyPath:@"loaded" options:NSKeyValueObservingOptionInitial context:NULL];
    
    // TODO: observe playback changes
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.playbackManager addObserver:self forKeyPath:@"currentTrack" options:0 context:NULL];
}

- (id)initWithArtist:(SPArtistBrowse *)artist
{
    self = [super init];
    if (self) {
        _artist = artist;
        [self privateInit];
    }
    
    return self;
}

- (void)dealloc
{
    [_artist removeObserver:self forKeyPath:@"loaded" context:NULL];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.playbackManager removeObserver:self forKeyPath:@"currentTrack"];
}

#pragma mark - View Management

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _artist.artist.name;
    self.tableView.allowsMultipleSelection = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isEqual:_artist])
    {
        [self.tableView reloadData];
        NSLog(@"Loaded artist %@", _artist);
    }
    else if ([keyPath isEqualToString:@"currentTrack"])
    {
        [self.tableView reloadData];
    }
    else if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)])
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_artist topTracks] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArtistBrowseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    SPTrack* track = [_artist topTracks][indexPath.row];
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    SPTrack* currentTrack = delegate.playbackManager.currentTrack;
    
    cell.textLabel.text = track.name;
    
    // Change color if currently playing
    cell.textLabel.textColor = [track.spotifyURL.absoluteString isEqualToString:currentTrack.spotifyURL.absoluteString]
    ? [UIColor blueColor] : [UIColor blackColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.allowsSelection = NO;
    SPTrack* track = _artist.topTracks[indexPath.row];
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    __weak ArtistBrowseViewController* weakSelf = self;
    
    [delegate.playbackManager playTrack:track callback:^(NSError *error) {
        weakSelf.tableView.allowsSelection = YES;
        [weakSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (error) {
            UIAlertView* trackPlayFailed = [[UIAlertView alloc] initWithTitle:@"Failed To Play Track"
                                                                      message:[error description]
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
            [trackPlayFailed show];
        }
    }];
}

@end
