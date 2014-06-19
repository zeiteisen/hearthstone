//
//  ZEPublishCardTableViewCell.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZEUpdateCellProtocol.h"
#import "SZTextView.h"

@protocol ZEPublishCardTableViewCellDelegate <NSObject>

- (void)publishCardTableViewDidEndEditing:(id)sender;

@end

@interface ZEPublishCardTableViewCell : UITableViewCell <ZEUpdateCellProtocol>
@property (weak, nonatomic) IBOutlet SZTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;

@property (nonatomic, weak) id<ZEPublishCardTableViewCellDelegate> delegate;

@end
