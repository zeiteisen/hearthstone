//
//  ZEPublishCardTableViewCell.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPublishCardTableViewCell.h"
#import "ZEDataManager.h"

@interface ZEPublishCardTableViewCell () <UITextViewDelegate>

@end

@implementation ZEPublishCardTableViewCell

- (void)editingMode:(BOOL)editingMode {
    if (editingMode) {
        self.descriptionTextView.layer.borderColor = [UIColor colorWithWhite:0 alpha:.2].CGColor;
        self.descriptionTextView.layer.borderWidth = 0.5;
        self.descriptionTextView.layer.cornerRadius = 10;
        self.descriptionTextView.userInteractionEnabled = YES;
    } else {
        self.descriptionTextView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.descriptionTextView.layer.borderWidth = 0;
        self.descriptionTextView.layer.cornerRadius = 0;
        self.descriptionTextView.userInteractionEnabled = NO;
    }
}

- (void)updateWithDict:(NSDictionary *)dict {
    NSString *imageName = dict[@"name"];
    NSString *description = dict[@"description"];
    self.cardImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", imageName]];
    if (description.length == 0) {
        self.descriptionTextView.text = @"";
        self.descriptionTextView.placeholder = [self getFlavourTextFromCardName:imageName];
    } else {
        self.descriptionTextView.text = description;
    }
}

- (NSString *)getFlavourTextFromCardName:(NSString *)compareTo {
    NSArray *cards = [ZEDataManager sharedInstance].cards;
    for (NSDictionary *cardDict in cards) {
        NSString *cardName = cardDict[@"name"];
        if ([cardName isEqualToString:compareTo]) {
            return cardDict[@"flavour_text"];
        }
    }
    return NSLocalizedString(@"Why did you pick this card", nil);
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
    self.descriptionTextView.font = [ZEUtility myStandardFont];
    self.descriptionTextView.font = [UIFont fontWithName:self.descriptionTextView.font.fontName size:12];
    self.descriptionTextView.delegate = self;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(publishCardTableViewDidEndEditing:)]) {
        [self.delegate publishCardTableViewDidEndEditing:self];
    }
}

@end
