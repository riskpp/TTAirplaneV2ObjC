//
//  TTPlaneOverlay.m
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 03.01.16.
//

#import "TTPlane.h"
#import "TTBezierPolyline.h"

NSString * const kPlaneCoordinateDidChangeNotification = @"kPlaneCoordinateDidChangeNotification";

NSTimeInterval flightTime = 100.0f;

static inline double TTRadiansToDegrees(double radians) {
    return radians * 180.0f / M_PI;
}

static CLLocationDirection TTDirectionBetweenPoints(MKMapPoint sourcePoint, MKMapPoint destinationPoint) {
    double x = destinationPoint.x - sourcePoint.x;
    double y = destinationPoint.y - sourcePoint.y;
    
    return fmod(TTRadiansToDegrees(atan2(y, x)), 360.0f);
}

@interface TTPlane()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) TTBezierData *bezierData;
@property (nonatomic, assign) NSTimeInterval startTime;
@end

@implementation TTPlane

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCoordinate)];
    }
    return self;
}


- (void)updateCoordinate {

    NSTimeInterval renderTime = CACurrentMediaTime() - self.startTime;
    
    if (renderTime > flightTime) {
        [self.displayLink invalidate];
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    
    //Calculate point on Bezier curve
    CGFloat t = renderTime/flightTime;
    
    MKMapPoint nextMapPoint = [_bezierData bezierMapPointForT:t];
    MKMapPoint previousMapPoint = _planePoint;
    
    _planePoint = nextMapPoint;
    _direction = TTDirectionBetweenPoints(previousMapPoint, nextMapPoint);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlaneCoordinateDidChangeNotification object:nil];
}

- (void)startFlightWithBezierData:(TTBezierData *)bezierData {

    //Initialize plane position
    self.planePoint = bezierData.firstPoint;
    self.bezierData = bezierData;
    
    self.startTime = CACurrentMediaTime();
    
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

@end
