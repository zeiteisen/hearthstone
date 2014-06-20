//
//  ZEPublishTableViewController.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 25.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZEPublishTableViewController : UITableViewController

@property (nonatomic, assign) NSInteger selectedDeckNumber;
@property (nonatomic, strong) PFObject *deckObject;

@end
