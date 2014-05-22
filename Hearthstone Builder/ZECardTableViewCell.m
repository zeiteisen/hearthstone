//
//  ZECardTableViewCell.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 13.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZECardTableViewCell.h"

@implementation ZECardTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setFaded:(BOOL)faded {
    _faded = faded;
    if (faded) {
        self.image.alpha = 0.5;
    } else {
        self.image.alpha = 1;
    }
}

- (IBAction)removeTouched:(id)sender {
    [self.delegate cardCellDidTouchedRemove:self];
}

@end
