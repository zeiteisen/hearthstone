//
//  ZEStartViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 24.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEStartViewController.h"
#import "ZEMyDecksViewController.h"
#import "ZEPickClassViewController.h"
#import "NSMutableArray+Shuffle.h"
#import "ZELegalViewController.h"

@interface ZEStartViewController ()
@property (weak, nonatomic) IBOutlet UIButton *myDeckButton;
@property (weak, nonatomic) IBOutlet UIButton *otherDecksButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ZEStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myDeckButton.titleLabel.font = [ZEUtility myStandardFont];
    self.otherDecksButton.titleLabel.font = [ZEUtility myStandardFont];
    self.otherDecksButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.otherDecksButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.otherDecksButton setTitle:NSLocalizedString(@"Other\nDecks", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        NSString *imageName = [NSString stringWithFormat:@"bg%i.jpg", i];
        [images addObject:[UIImage imageNamed:imageName]];
    }
    [images shuffle];
    self.imageView.image = [images lastObject];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Actions

- (IBAction)myDecksTouched:(id)sender {
    ZEMyDecksViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"MyDecksViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)otherDecksTouched:(id)sender {
    ZEPickClassViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PickClassViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)legalTouched:(id)sender {
    ZELegalViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"LegalViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
