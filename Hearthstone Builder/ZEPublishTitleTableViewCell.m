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

- (void)editingMode:(BOOL)editingMode {
    if (editingMode) {
        [self.titleTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [self.titleTextField setNeedsDisplay];
        self.titleTextField.userInteractionEnabled = YES;
    } else {
        [self.titleTextField setBorderStyle:UITextBorderStyleNone];
        [self.titleTextField setNeedsDisplay];
        self.titleTextField.userInteractionEnabled = NO;
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
    self.titleTextField.font = [ZEUtility myStandardFont];
    self.minionsCount.textColor = [ZEUtility legendaryColor];
    self.dustCount.textColor = [ZEUtility rareColor];
    self.spellsCount.textColor = [ZEUtility commonColor];
    self.weaponsCount.textColor = [ZEUtility epicColor];
    self.titleTextField.textColor = [ZEUtility rareColor];
}

@end
