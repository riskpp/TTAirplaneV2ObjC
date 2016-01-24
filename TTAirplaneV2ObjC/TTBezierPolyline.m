//
//  TTBezierPolyline.m
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 03.01.16.
//

#import "TTBezierPolyline.h"

static inline MKMapPoint midPointForMapPoints(MKMapPoint p1, MKMapPoint p2) {
    return MKMapPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static inline MKMapPoint yControlPointForPoints(MKMapPoint p1, MKMapPoint p2) {
    MKMapPoint controlPoint = midPointForMapPoints(p1, p2);
    CGFloat diffY = 10*fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

@implementation TTBezierData

- (instancetype)initWithMapPoint1:(MKMapPoint)p1 point2:(MKMapPoint)p2 {
    self = [super init];
    if (self) {
        _firstPoint = p1;
        _lastPoint = p2;
        _controlPoint1 = yControlPointForPoints(_firstPoint, _lastPoint);
        _controlPoint2 = yControlPointForPoints(_lastPoint, _firstPoint);
    }
    return self;
}

- (MKMapPoint)bezierMapPointForT:(CGFloat)t {
    MKMapPoint point;
    point.x = powf((1-t), 3)*_firstPoint.x + 3*powf((1-t), 2)*t*_controlPoint1.x + 3*(1-t)*powf(t, 2)*_controlPoint2.x + powf(t, 3)*_lastPoint.x;
    point.y = powf((1-t), 3)*_firstPoint.y + 3*powf((1-t), 2)*t*_controlPoint1.y + 3*(1-t)*powf(t, 2)*_controlPoint2.y + powf(t, 3)*_lastPoint.y;
    return point;
}

@end

@implementation TTBezierPolyline

+ (instancetype)bezierPolylineWithFirstCoordinate:(CLLocationCoordinate2D)fCoordinate
                                   lastCoordinale:(CLLocationCoordinate2D)lCoordinate {
    
    TTBezierData *bezierData = [[TTBezierData alloc] initWithMapPoint1: MKMapPointForCoordinate(fCoordinate)
                                                                point2: MKMapPointForCoordinate(lCoordinate)];
    
    static int const pointsCount = 100;
    
    MKMapPoint mapPoints[pointsCount + 1];
    
    float step = 0.01f;
    int i = 0;
    for (float t = 0; t <= 1; t+=step) {
        mapPoints[i] = [bezierData bezierMapPointForT:t];
        i++;
    }
    
    TTBezierPolyline *polyline = [super polylineWithPoints:mapPoints count:pointsCount + 1];
    polyline.bezierData = bezierData;
    return polyline;
}

@end
