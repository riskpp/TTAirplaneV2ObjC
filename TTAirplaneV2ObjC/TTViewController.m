//
//  ViewController.m
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 28.12.15.
//

#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>

#import "TTViewController.h"

//annotations
#import "TTCustomPinView.h"
#import "TTCustomPointAnnotation.h"

//overlays
#import "TTFlightTrackMapOverlay.h"
#import "TTFlightTrackOverlayRenderer.h"

static NSString * const kPlaneAnnotationViewId = @"kPlaneAnnotationViewId";
static NSString * const kPinAnnotationViewId = @"kPinAnnotationViewId";

static const UIEdgeInsets kMapEdgeInsets = (UIEdgeInsets){50, 50, 50, 50};

@interface TTViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) TTFlightTrackMapOverlay *flightTrackOverlay;

@end

@implementation TTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:60.183526
                                                       longitude:24.938965];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:40.6397511
                                                       longitude:-73.7789256];
    
    TTCustomPointAnnotation *annotation1 = [self customPinAnnotationWithLocation:location1];
    TTCustomPointAnnotation *annotation2 = [self customPinAnnotationWithLocation:location2];
    
    [self.mapView addAnnotation:annotation1];
    [self.mapView addAnnotation:annotation2];
    
    [self updateVisibleMapRect];
    
    __weak typeof(self) wSelf = self;
    [self flightTrackOverlayWithFirstCoordinate:location1.coordinate
                                 lastCoordinale:location2.coordinate
                                completionBlock:^(TTFlightTrackMapOverlay *overlay) {
                                    typeof(self) sSelf = wSelf;
                                    sSelf.flightTrackOverlay = overlay;
                                    [sSelf.mapView addOverlay:sSelf.flightTrackOverlay];
                                    [sSelf updateVisibleMapRect];
                                }];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:TTFlightTrackMapOverlay.class]) {
        TTFlightTrackOverlayRenderer *renderer =
        [[TTFlightTrackOverlayRenderer alloc] initWithOverlay:overlay planeImage:[UIImage imageNamed:@"plane"]];
        return renderer;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:MKPointAnnotation.class]){
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationViewId];
        if (!annotationView) {
            annotationView = [[TTCustomPinView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationViewId];
        } else {
            [(TTCustomPinView *)annotationView setLabelText:annotation.title];
        }
    }
    
    return annotationView;
}

#pragma mark - Utils

- (void)updateVisibleMapRect {
    MKMapRect visibleMapRect = [self visibleMapRectForAnnotations:self.mapView.annotations overlays:self.mapView.overlays];
    [self.mapView setVisibleMapRect:visibleMapRect edgePadding:kMapEdgeInsets animated:YES];
}

- (MKMapRect)visibleMapRectForAnnotations:(NSArray<id<MKAnnotation>> *)annotations overlays:(NSArray<id<MKOverlay>> *)overlays {
    MKMapRect visibleMapRect = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays) {
        if (MKMapRectIsNull(visibleMapRect)) {
            visibleMapRect = [overlay boundingMapRect];
        } else {
            visibleMapRect = MKMapRectUnion(visibleMapRect, [overlay boundingMapRect]);
        }
    }
    
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(visibleMapRect)) {
            visibleMapRect = pointRect;
        } else {
            visibleMapRect = MKMapRectUnion(visibleMapRect, pointRect);
        }
    }
    return visibleMapRect;
}

- (void)reverseGeocode:(CLLocation *)location completion:(void(^)(NSString *))completionBlock {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *ISOcountryCode = placemark.ISOcountryCode;
            if (ISOcountryCode.length > 0 && completionBlock) {
                completionBlock(ISOcountryCode);
            }
        }
    }];
}

- (void)flightTrackOverlayWithFirstCoordinate:(CLLocationCoordinate2D)fCoordinate
                               lastCoordinale:(CLLocationCoordinate2D)lCoordinate
                              completionBlock:(void(^)(TTFlightTrackMapOverlay *overlay))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TTFlightTrackMapOverlay *overlay = [TTFlightTrackMapOverlay bezierPolylineWithFirstCoordinate:fCoordinate lastCoordinale:lCoordinate];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(overlay);
            }
        });
    });
}

- (TTCustomPointAnnotation *)customPinAnnotationWithLocation:(CLLocation *)location {
    TTCustomPointAnnotation *annotation = [TTCustomPointAnnotation new];
    annotation.coordinate = location.coordinate;
    
    [self reverseGeocode:location completion:^(NSString *title) {
        annotation.title = title;
    }];
    
    return annotation;
}

@end
