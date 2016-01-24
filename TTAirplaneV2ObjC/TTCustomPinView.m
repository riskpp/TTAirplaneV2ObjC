//
//  TTCustomPinView.m
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 29.12.15.
//

#import "TTCustomPinView.h"
#import "TTCustomPointAnnotation.h"

static CGFloat kViewWidth = 40;
static CGFloat kViewHeight = 20;

@interface TTCustomPinView ()
@property (nonatomic, strong) UILabel *annotationLabel;
@end

@implementation TTCustomPinView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(-kViewWidth/2, -kViewHeight/2);
        self.enabled = NO;
        self.annotationLabel = [self prepareLabel];
        [self addSubview:self.annotationLabel];
        self.enabled = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelTitle:) name:kCustomPointAnnotationTitleChangedNotification object:annotation];
    }
    return self;
}

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLabelText:(NSString *)labelText {
    _labelText = labelText;
    self.annotationLabel.text = labelText;
}

- (void)updateLabelTitle:(NSNotification *)notification {
    self.labelText = self.annotation.title;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.labelText = nil;
}

- (UILabel *)prepareLabel {
    UILabel *annotationLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, kViewWidth, kViewHeight}];
    annotationLabel.font = [UIFont systemFontOfSize:13.0];
    annotationLabel.textAlignment = NSTextAlignmentCenter;
    annotationLabel.textColor = [UIColor whiteColor];
    annotationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|
                                       UIViewAutoresizingFlexibleHeight;
    annotationLabel.layer.backgroundColor = [UIColor grayColor].CGColor;
    annotationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    annotationLabel.layer.borderWidth = 1.0f;
    annotationLabel.layer.cornerRadius = kViewHeight * 0.5f;
    annotationLabel.layer.opacity = 0.7f;
    return annotationLabel;
}

@end
