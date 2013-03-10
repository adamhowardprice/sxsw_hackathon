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
#import "Venue+SXSW.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <CocoaLibSpotify.h>
@implementation RootVC

- (id)init
{
    if (!(self = [super initWithNibName:nil bundle:nil]))
        return nil;
    
    [self setTitle:@"Concerts"];
    
    _results = [[NSMutableArray alloc] init];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [SPCoreDataWrapper removeVenuesWithNoCoordinates];
}

#pragma mark Private Return Methods

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES]]];
    return fetchRequest;
}

#pragma mark Private Methods

- (void)reloadMapData
{
    
}

#pragma mark MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    NSError *error = nil;
    NSFetchRequest *fetch = [self fetchRequest];
    NSArray *results = [[SPCoreDataWrapper readContext] executeFetchRequest:fetch error:&error];
    if (error) NSLog(@"Error: %@", error);
    NSArray *sortedResults = [results sortedArrayUsingComparator:
                              ^NSComparisonResult(id obj1, id obj2)
    {
        float distance1 = [[(Event *)obj1 venue] distanceToCoordinate:mapView.userLocation.coordinate];
        float distance2 = [[(Event *)obj2 venue] distanceToCoordinate:mapView.userLocation.coordinate];
        return distance1 > distance2;
    }];
    [_results addObjectsFromArray:sortedResults];
    [mapView addAnnotations:_results];
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
    NSLog(@"Added Views: %d", [views count]);
    
    if ([_results count])
        [mapView selectAnnotation:_results[0] animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    Event* event = (Event*)view.annotation;
    [self playEvent:event];
}


/*


- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    
}

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
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

#pragma mark - Playback

- (void)playEvent:(Event*)event
{
    NSString* artistName = event.artist.name;
    [SPAsyncLoading waitUntilLoaded:[SPSearch liveSearchWithSearchQuery:artistName inSession:[SPSession sharedSession]]
                            timeout:kSPAsyncLoadingDefaultTimeout
                               then:^(NSArray *loadedItems, NSArray *notLoadedItems)
     {
         if ([loadedItems count]) {
             SPSearch* search = [loadedItems lastObject];
             if ([search.artists count]) {
                 SPArtist* artist = search.artists[0];
                 
                 if ([artist.name compare:search.searchQuery options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                     [SPAsyncLoading waitUntilLoaded:[SPArtistBrowse browseArtist:artist
                                                                        inSession:[SPSession sharedSession]
                                                                             type:SP_ARTISTBROWSE_NO_ALBUMS]
                                             timeout:kSPAsyncLoadingDefaultTimeout
                                                then:^(NSArray *loadedItems, NSArray *notLoadedItems)
                      {
                          if ([loadedItems count]) {
                              SPArtistBrowse* browse = [loadedItems lastObject];
                              SPTrack* track = browse.topTracks[0];
                              
                              AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                              
                              __weak RootVC* weakSelf = self;
                              [delegate.playbackManager playTrack:track callback:^(NSError *error) {
                                  if (error) {
                                      [weakSelf spotifyFailedToPlayEvent:event error:error];
                                  } else {
                                      [weakSelf setTitle:artist.name];
                                  }
                              }];
                          } else {
                              id unloaded = [notLoadedItems lastObject];
                              [self spotifyFailedToPlayEvent:event error:((SPArtistBrowse*)unloaded).loadError];
                          }
                      }];
                 } else {
                     NSLog(@"Got search results, but not sure about accuracy: %@ vs. %@",
                           artist.name,
                           search.searchQuery);
                     [self spotifyFailedToPlayEvent:event error:nil];
                 }                 
             } else {
                 [self spotifyFailedToPlayEvent:event error:nil];
             }
         } else {
             id unloaded = [notLoadedItems lastObject];
             [self spotifyFailedToPlayEvent:event error:((SPSearch*)unloaded).searchError];
         }
     }];
}

- (void)spotifyFailedToPlayEvent:(Event*)event error:(NSError*)error
{
    // TODO fall back to event MP3

    if (error) {
        UIAlertView* trackPlayFailed = [[UIAlertView alloc] initWithTitle:@"Playback Failed"
                                                                  message:[error description]
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [trackPlayFailed show];
    } else {
        NSLog(@"No results for event: %@", event.artist);
    }
}

@end
