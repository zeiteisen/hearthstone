//
//  ZETextViewTableViewCell.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 20.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"
#import "ZEUpdateCellProtocol.h"

@protocol ZEPublishTextTableViewCellDelegate <NSObject>

- (void)textViewTableViewDidEndEditing:(id)sender;

@end

@interface ZEPublishTextTableViewCell : UITableViewCell <ZEUpdateCellProtocol>

@property IBOutlet SZTextView *descriptionTextView;
@property (nonatomic, weak) id <ZEPublishTextTableViewCellDelegate> delegate;

@end
