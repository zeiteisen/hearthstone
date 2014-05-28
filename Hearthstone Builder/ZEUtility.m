//
//  ZEUtility.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 20.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEUtility.h"

@implementation ZEUtility

+ (id)instanciateViewControllerFromStoryboardIdentifier:(NSString *)identifier; {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    return [storyBoard instantiateViewControllerWithIdentifier:identifier];
}

+ (UIFont *)myStandardFont {
    return [UIFont fontWithName:@"BelweBT-Bold" size:17];
}

+ (NSMutableArray *)removeDuplicatesFrom:(NSArray *)duplicates {
    NSSet *set = [NSSet setWithArray:duplicates];
    return [[set allObjects] mutableCopy];
}

@end
