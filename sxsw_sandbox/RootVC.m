//
//  RootVC.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "RootVC.h"
#import "SPCoreDataWrapper.h"
#import "Event.h"
#import "Event+SXSW.h"
#import <CoreLocation/CoreLocation.h>

@implementation RootVC

- (id)init
{
    if (!(self = [super initWithNibName:nil bundle:nil]))
        return nil;
    
    [self setTitle:@"Map"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [self.view addSubview:_mapView];
    
    _frc = [self fetchedResultsController];
    NSError *error = nil;
    [_frc setDelegate:self];
    if (error) NSLog(@"Error: %@", [error localizedDescription]);
}

#pragma mark Private Return Methods

- (UIImageView *)spotifyBullseye
{
    if (!_spotifyBullseye)
    {
        CGFloat const margin = 5.0f;
        _spotifyBullseye = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, _mapView.bounds.size.width - margin * 2, _mapView.bounds.size.height - margin * 2)];
        [_spotifyBullseye setImage:[UIImage imageNamed:@"images/spot_gradient.png"]];
        [_spotifyBullseye setContentMode:UIViewContentModeScaleAspectFit];
        [_spotifyBullseye setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    }
    return _spotifyBullseye;
}

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SELF.artist != nil"]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"artist" ascending:YES]]];
    [fetchRequest setFetchLimit:10];
    return fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_frc)
    {
        _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                   managedObjectContext:[SPCoreDataWrapper readContext] sectionNameKeyPath:nil
                                                              cacheName:@"MainCache"];
    }
    return _frc;
}

#pragma mark Private Methods

- (void)reloadMapData
{
    
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    // Reload map?
    if (_mapView)
        [_mapView addAnnotations:[controller fetchedObjects]];
}

#pragma mark MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    NSError *error = nil;
    [_frc performFetch:&error];
    if (error) NSLog(@"Error: %@", [error localizedDescription]);
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"ERROR LOADING MAP: %@", [error localizedDescription]);
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{    
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
    [mapView setCenterCoordinate:userLocation.coordinate];    
    [mapView setRegion:[mapView regionThatFits:region]];
    
    NSLog(@"User Location: %f %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    
    BOOL firstTime = !_spotifyBullseye;
    if (firstTime) {
        _spotifyBullseye = [self spotifyBullseye];
        [_spotifyBullseye setAlpha:0.0f];
        [self.view addSubview:_spotifyBullseye];
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [_spotifyBullseye setAlpha:1.0f];
                         }
                         completion:nil];
    }
}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
        return nil;
    
    if ([annotation isKindOfClass:[Event class]]) {
        static NSString *const eventAnnotationIdentifier = @"eventAnnotationIdentifier";
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:eventAnnotationIdentifier];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:eventAnnotationIdentifier];
            [pin setCanShowCallout:YES];
            
        }
        [pin setAnnotation:annotation];
        return pin;
    }
    return nil;
}

// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
}

/*
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    
}

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
fromOldState:(MKAnnotationViewDragState)oldState
{
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    
}

// Called after the provided overlay views have been added and positioned in the map.
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    
}
*/
@end
