//
//  ZELeftFilterTableViewCell.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 28.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZELeftFilterTableViewCell.h"

@implementation ZELeftFilterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.label.textColor = [UIColor redColor];
    } else {
        self.label.textColor = [UIColor whiteColor];
    }
}

@end
