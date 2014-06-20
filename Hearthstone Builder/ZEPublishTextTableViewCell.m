//
//  ZETextViewTableViewCell.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 20.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPublishTextTableViewCell.h"

@interface ZEPublishTextTableViewCell () <UITextViewDelegate>

@end

@implementation ZEPublishTextTableViewCell

- (void)editingMode:(BOOL)editingMode {
    if (editingMode) {
        self.descriptionTextView.layer.borderColor = [UIColor colorWithWhite:0 alpha:.2].CGColor;
        self.descriptionTextView.layer.borderWidth = 0.5;
        self.descriptionTextView.layer.cornerRadius = 10;
        self.descriptionTextView.editable = YES;
    } else {
        self.descriptionTextView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.descriptionTextView.layer.borderWidth = 0;
        self.descriptionTextView.layer.cornerRadius = 0;
        self.descriptionTextView.editable = NO;
    }
}

- (void)updateWithDict:(NSDictionary *)dict {
    NSString *description = dict[@"description"];
    if (description.length == 0) {
        self.descriptionTextView.placeholder = NSLocalizedString(@"Please add a brief description on how to play this deck", nil);
    } else {
        self.descriptionTextView.text = dict[@"description"];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.font = [UIFont fontWithName:self.descriptionTextView.font.fontName size:12];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.delegate textViewTableViewDidEndEditing:self];
}

@end
