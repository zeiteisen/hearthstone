//
//  ZEOtherDeckTableViewCell.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 28.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEOtherDeckTableViewCell.h"

@implementation ZEOtherDeckTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customize];
    }
    return self;
}

- (void)awakeFromNib {
    [self customize];
}

- (void)customize {
    self.deckNameLabel.font = [ZEUtility myStandardFont];
    self.likesLabel.font = [ZEUtility myStandardFont];
    self.dustLabel.textColor = [ZEUtility rareColor];
    self.minionsLabel.textColor = [ZEUtility legendaryColor];
    self.spellsLabel.textColor = [ZEUtility commonColor];
    self.weaponsLabel.textColor = [ZEUtility epicColor];
}

@end
