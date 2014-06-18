//
//  UINavigationController+Progress.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 18.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "UINavigationController+Progress.h"
#import "UINavigationController+M13ProgressViewBar.h"

@implementation UINavigationController (Progress)

- (void)hb_showProgress {
    [self showProgress];
    [self setIndeterminate:YES];
}

- (void)hb_hideProgress {
    [self finishProgress];
}

@end
