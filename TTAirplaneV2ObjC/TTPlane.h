//
//  TTPlaneOverlay.h
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 03.01.16.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

extern NSString *const kPlaneCoordinateDidChangeNotification;

@class TTBezierData;

@interface TTPlane : NSObject
@property (nonatomic, assign) CLLocationDirection direction;
@property (nonatomic, assign) MKMapPoint planePoint;

- (void)startFlightWithBezierData:(TTBezierData *)bezierData;

@end
