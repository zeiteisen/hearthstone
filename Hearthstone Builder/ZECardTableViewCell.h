//
//  ZECardTableViewCell.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 13.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZECardTableViewCellDelegate <NSObject>

- (void)cardCellDidTouchedRemove:(id)cell;

@end

@interface ZECardTableViewCell : UITableViewCell

@property (nonatomic, weak) id <ZECardTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *cardData;
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (nonatomic, assign) BOOL faded;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *countView;

@end
