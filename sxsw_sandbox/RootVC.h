//
//  RootVC.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RootVC : UIViewController <MKMapViewDelegate, NSFetchedResultsControllerDelegate>
{
    MKMapView *_mapView;
    
    UIImageView *_spotifyBullseye;
    
    NSFetchedResultsController *_frc;
}
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *spotifyBullseye;

@end
