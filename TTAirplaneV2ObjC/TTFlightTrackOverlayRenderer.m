//
//  TTFlightTrackOverlayRenderer.m
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 29.12.15.
//

#import "TTFlightTrackOverlayRenderer.h"
#import "TTFlightTrackMapOverlay.h"

#import "TTPlane.h"

static inline double TTDegreesToRadians(double degrees) {
    return degrees * M_PI / 180.0f;
}

@interface TTFlightTrackOverlayRenderer()

@property (nonatomic, strong) UIImage *planeImage;
@property (nonatomic, strong) TTPlane *planeOverlay;

@end

@implementation TTFlightTrackOverlayRenderer

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay planeImage:(UIImage *)planeImage {
    self = [super initWithPolyline:overlay];
    if (self) {
        
        self.lineWidth = 4.0f;
        self.strokeColor = [UIColor grayColor];
        self.alpha = 0.9;
        self.lineDashPattern = @[@0.1, @10];
        
        _planeImage = planeImage;
        _planeOverlay = [TTPlane new];
        
        TTFlightTrackMapOverlay *overlay = (TTFlightTrackMapOverlay *)self.overlay;
        [_planeOverlay startFlightWithBezierData:overlay.bezierData];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlanePosition) name:kPlaneCoordinateDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)updatePlanePosition {
    [self setNeedsDisplayInMapRect:self.overlay.boundingMapRect];
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
     [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    
//    //draw dashed line - manual version
//        CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale)*5;
//        MKPolyline *overlay = (MKPolyline *)self.overlay;
//    
//        MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
//    
//        CGPathRef path = [self newPathForPoints:overlay.points
//                           pointCount:overlay.pointCount
//                             clipRect:clipRect
//                            zoomScale:zoomScale];
//    
//        CGFloat dashes[2];
//        dashes[0] = 0.1;
//        dashes[1] = lineWidth * 2;
//    
//    
//        if (path != nil) {
//            CGContextSaveGState(context);
//            CGContextAddPath(context, path);
//            CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
//            CGContextSetLineJoin(context, kCGLineJoinRound);
//            CGContextSetLineCap(context, kCGLineCapRound);
//            CGContextSetLineDash(context, 0.0f, dashes, 2);
//            CGContextSetLineWidth(context, lineWidth);
//            CGContextDrawPath(context, kCGPathStroke);
//            CGPathRelease(path);
//            CGContextRestoreGState(context);
//        }
    
    //draw plane
    CGImageRef imageReference = self.planeImage.CGImage;
    
    CGFloat planeSize = MKRoadWidthAtZoomScale(zoomScale)*20;
    MKMapPoint planePoint = self.planeOverlay.planePoint;
    MKMapRect planeMapRect = MKMapRectMake(planePoint.x - planeSize/2,
                                           planePoint.y - planeSize/2,
                                           planeSize,
                                           planeSize);
    CGRect planeRect = [self rectForMapRect:planeMapRect];
    
    CGContextSaveGState(context);
    CLLocationDirection direction = self.planeOverlay.direction;
    CGContextTranslateCTM(context,
                          planeRect.size.width/2 + planeRect.origin.x,
                          planeRect.size.height/2 + planeRect.origin.y);
    CGContextRotateCTM(context, TTDegreesToRadians(direction));
    CGContextDrawImage(context,
                       (CGRect)
                       { -planeRect.size.width/2,
                           -planeRect.size.height/2,
                           planeRect.size.width,
                           planeRect.size.height
                       },
                       imageReference);
    CGContextRestoreGState(context);
    
}

static BOOL lineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r) {
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}

- (CGPathRef)newPathForPoints:(MKMapPoint *)points
                   pointCount:(NSUInteger)pointCount
                     clipRect:(MKMapRect)mapRect
                    zoomScale:(MKZoomScale)zoomScale {
    CGMutablePathRef path = nil;
    
    if (pointCount <= 1) {
        return path;
    }
    
    path = CGPathCreateMutable();

    BOOL needsMove = YES;
    const double kMinPointsDistance = 5.0;
    double minPointsDistanceScaled = kMinPointsDistance / zoomScale;
    double c2 = pow(minPointsDistanceScaled, 2);
    
    MKMapPoint lastPoint = points[0];
    for (NSUInteger i = 1; i < pointCount - 1; i++) {
        MKMapPoint point = points[i];
        double a2b2 = pow((point.x - lastPoint.x), 2) + pow((point.y - lastPoint.y), 2);
        if (a2b2 >= c2) {
            if (lineIntersectsRect(point, lastPoint, mapRect)) {
                if (needsMove) {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                CGPoint cgPoint = [self pointForMapPoint:point];
                CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
                needsMove = NO;
            }
            else {
                // discontinuity, lift the pen
                needsMove = YES;
            }
            lastPoint = point;
        }
    }
    
    // If the last line segment intersects the mapRect at all, add it unconditionally
    MKMapPoint point = points[pointCount - 1];
    if (lineIntersectsRect(point, lastPoint, mapRect)) {
        if (needsMove) {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
        CGPoint cgPoint = [self pointForMapPoint:point];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
    }
    
    return path;
}

@end
