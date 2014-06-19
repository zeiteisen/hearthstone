//
//  ZEPublishTitleTableViewCell.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZEUpdateCellProtocol.h"

@interface ZEPublishTitleTableViewCell : UITableViewCell <ZEUpdateCellProtocol>
@property (weak, nonatomic) IBOutlet UILabel *dustCount;
@property (weak, nonatomic) IBOutlet UILabel *spellsCount;
@property (weak, nonatomic) IBOutlet UILabel *minionsCount;
@property (weak, nonatomic) IBOutlet UILabel *weaponsCount;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@end
