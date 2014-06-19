//
//  ZEPublishTitleTableViewCell.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPublishTitleTableViewCell.h"

@implementation ZEPublishTitleTableViewCell

- (void)updateWithDict:(NSDictionary *)dict {
    self.dustCount.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Dust: ", nil), [dict[@"dust"] stringValue]];
    self.minionsCount.text = [NSString stringWithFormat:@"%@ %@", [dict[@"minions"] stringValue], NSLocalizedString(@"Minions", nil)];
    self.spellsCount.text = [NSString stringWithFormat:@"%@ %@", [dict[@"spells"] stringValue], NSLocalizedString(@"Spells", nil)];
    self.weaponsCount.text = [NSString stringWithFormat:@"%@ %@", [dict[@"weapons"] stringValue], NSLocalizedString(@"Weapons", nil)];
    if (dict[@"title"]) {
        self.titleTextField.text = dict[@"title"];
    } else {
        self.titleTextField.placeholder = dict[@"titlePlaceholder"];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
//    self.titleTextField.delegate = self;
//    self.descriptionTextView.delegate = self;
    self.titleTextField.font = [ZEUtility myStandardFont];
    self.minionsCount.textColor = [ZEUtility legendaryColor];
    self.dustCount.textColor = [ZEUtility rareColor];
    self.spellsCount.textColor = [ZEUtility commonColor];
    self.weaponsCount.textColor = [ZEUtility epicColor];
    self.titleTextField.textColor = [ZEUtility rareColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateContentWithDict:(NSDictionary *)dict {
    
}

@end
