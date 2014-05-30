//
//  ZEReadDescriptionViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 27.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEReadDescriptionViewController.h"
#import "ZEWebViewController.h"

@interface ZEReadDescriptionViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation ZEReadDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.descriptionTextView.text = self.deckObject[@"description"];
    self.descriptionTextView.font = [ZEUtility myStandardFont];
    self.descriptionTextView.delegate = self;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    ZEWebViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"WebViewController"];
    vc.url = URL;
    [self.navigationController pushViewController:vc animated:YES];
    return NO;
}

@end
