//
//  ZEOtherDeckTableViewCell.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 28.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZEOtherDeckTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *highlightImageView;
@property (weak, nonatomic) IBOutlet UILabel *deckNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dustLabel;
@property (weak, nonatomic) IBOutlet UILabel *spellsLabel;
@property (weak, nonatomic) IBOutlet UILabel *minionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weaponsLabel;
@property (weak, nonatomic) IBOutlet UIView *upvoteView;
@property (weak, nonatomic) IBOutlet UIView *viewsView;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@end
