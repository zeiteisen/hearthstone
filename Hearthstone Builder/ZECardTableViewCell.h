//
//  ZECardTableViewCell.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 13.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZECardTableViewCellDelegate <NSObject>

- (void)cardCellDidTouchedAdd:(id)cell;
- (void)cardCellDidTouchedRemove:(id)cell;

@end

@interface ZECardTableViewCell : UITableViewCell

@property (nonatomic, weak) id <ZECardTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *cardData;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *image;

@end
