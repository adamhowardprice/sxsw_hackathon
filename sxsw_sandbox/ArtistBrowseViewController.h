//
//  ArtistBrowseViewController.h
//  Hydra
//
//  Created by Brian Gerstle on 3/10/13.
//  Copyright (c) 2013 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaLibSpotify.h>

@interface ArtistBrowseViewController : UITableViewController
@property (nonatomic, strong, readonly) SPArtistBrowse* artist;

- (id)initWithArtist:(SPArtistBrowse*)artist;

@end
