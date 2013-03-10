//
//  RootVC.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "RootVC.h"

@interface RootVC ()

@end

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
    
    [self.view setBackgroundColor:[UIColor blueColor]];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [self.view addSubview:_mapView];
    
    CGFloat const margin = 5.0f;
    UIImageView *spotifyGradient = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, _mapView.bounds.size.width - margin * 2, _mapView.bounds.size.height - margin * 2)];
    [spotifyGradient setImage:[UIImage imageNamed:@"images/spot_gradient.png"]];
    [spotifyGradient setContentMode:UIViewContentModeScaleAspectFit];
    [spotifyGradient setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:spotifyGradient];
}

#pragma mark MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{

}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
    [mapView setCenterCoordinate:userLocation.coordinate];    
    [mapView setRegion:[mapView regionThatFits:region]];
    
    NSLog(@"User Location: %f %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
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

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
}

// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
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
