//
//  TTBezierPolyline.h
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 03.01.16.
//

#import <MapKit/MapKit.h>

@class TTBezierPolyline;

typedef void (^TTBezierPolylineCompletionBlock)(TTBezierPolyline *bezierPolylne);

@interface TTBezierData : NSObject
@property (nonatomic, assign) MKMapPoint firstPoint;
@property (nonatomic, assign) MKMapPoint lastPoint;
@property (nonatomic, assign) MKMapPoint controlPoint1;
@property (nonatomic, assign) MKMapPoint controlPoint2;

- (MKMapPoint)bezierMapPointForT:(CGFloat)t;
@end

@interface TTBezierPolyline : MKPolyline
@property (nonatomic, strong) TTBezierData *bezierData;

+ (instancetype)bezierPolylineWithFirstCoordinate:(CLLocationCoordinate2D)fCoordinate lastCoordinale:(CLLocationCoordinate2D)lCoordinate;

@end
