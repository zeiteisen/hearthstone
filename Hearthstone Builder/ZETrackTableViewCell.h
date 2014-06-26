//
//  ZETrackTableViewCell.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 26.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZETrackTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *manaLabel;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@end
