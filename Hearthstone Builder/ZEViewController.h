//
//  ZEViewController.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 12.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZEViewController : UIViewController
@property (nonatomic, strong) NSString *hero;
@property (nonatomic, assign) NSInteger selectedDeckNumber;
@property (nonatomic, assign) BOOL viewDeckMode;
@end
