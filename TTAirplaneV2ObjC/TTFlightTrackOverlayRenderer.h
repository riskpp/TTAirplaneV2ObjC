//
//  TTFlightTrackOverlayRenderer.h
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 29.12.15.
//

#import <MapKit/MapKit.h>

@interface TTFlightTrackOverlayRenderer : MKPolylineRenderer

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay planeImage:(UIImage *)planeImage;

@end
