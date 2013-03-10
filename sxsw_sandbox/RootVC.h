//
//  RootVC.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RootVC : UIViewController <MKMapViewDelegate>
{
    MKMapView *_mapView;
        
    NSMutableArray *_results;
    
    UIButton *_leftButton;
    UIButton *_rightButton;
    UISlider *_timeSlider;
}
@property (nonatomic, strong) MKMapView *mapView;

@end
