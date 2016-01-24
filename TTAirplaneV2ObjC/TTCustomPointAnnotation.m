//
//  TTCustomPointAnnotation.m
//  TTAirplaneObjC
//
//  Created by Ольга Королева on 03.01.16.
//

#import "TTCustomPointAnnotation.h"

NSString *const kCustomPointAnnotationTitleChangedNotification = @"kCustomPointAnnotationTitleChangedNotification";

@implementation TTCustomPointAnnotation

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCustomPointAnnotationTitleChangedNotification object:self];
}

@end
