//
//  ZEReadDescriptionViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 27.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEReadDescriptionViewController.h"

@interface ZEReadDescriptionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation ZEReadDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.deckObject[@"title"];
    self.descriptionTextView.text = self.deckObject[@"description"];
}

- (IBAction)closeTouched:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
