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
#import "ZEQuickSearchTableViewCell.h"
#import "NSString+Score.h"
#import "ZEDataManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface ZEStartViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FBInterstitialAdDelegate>
@property (weak, nonatomic) IBOutlet UIButton *myDeckButton;
@property (weak, nonatomic) IBOutlet UIButton *otherDecksButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *quickSearchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
@end

@implementation ZEStartViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myDeckButton.titleLabel.font = [ZEUtility myStandardFont];
    self.otherDecksButton.titleLabel.font = [ZEUtility myStandardFont];
    self.otherDecksButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.otherDecksButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.otherDecksButton setTitle:NSLocalizedString(@"Other\nDecks", nil) forState:UIControlStateNormal];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.quickSearchTextField.delegate = self;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    FBSDKLikeControl *likeButton = [[FBSDKLikeControl alloc] init];
    likeButton.objectID = @"https://www.facebook.com/deckforhearthstone";
    likeButton.frame = CGRectMake(10, _quickSearchTextField.frame.origin.y + _quickSearchTextField.frame.size.height + 10, likeButton.frame.size.width, likeButton.frame.size.height);
    [self.view insertSubview:likeButton belowSubview:_tableView];
    [self loadInterstitalAd];
}

- (void) loadInterstitalAd {
    self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:@"165510983782268_275006002832765"];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        NSString *imageName = [NSString stringWithFormat:@"bg%i.jpg", i];
        [images addObject:[UIImage imageNamed:imageName]];
    }
    [images shuffle];
    self.imageView.image = [images lastObject];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textUpdated)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:self.quickSearchTextField];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillChange:)
//                                                 name:UIKeyboardWillChangeFrameNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.tableViewBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardSize = [keyboardFrameBegin CGRectValue];
    self.tableViewBottomConstraint.constant = keyboardSize.size.height;
    [self.view layoutIfNeeded];
    
//    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
//        bottomConstraint.constant = keyboardSize.height
//        view.layoutIfNeeded()
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)filterCardsWithText:(NSString *)text {
    text = [text lowercaseString];
    NSMutableArray *searchResult = [NSMutableArray array];
    for (NSDictionary *card in [ZEDataManager sharedInstance].cards) {
        // search for name
        NSString *name = [card[@"name"] lowercaseString];
        CGFloat nameResult = [name scoreAgainst:text];
        
        // search for set
        NSString *set = [card[@"set"] lowercaseString];
        CGFloat setResult = [set scoreAgainst:text];
        
        // search for effect
        NSArray *effectList = card[@"mechanics"];
        CGFloat effectResult = 0;
        for (NSString *effect in effectList) {
            CGFloat newEffectResult = [[effect lowercaseString] scoreAgainst:text];
            if (newEffectResult > effectResult) {
                effectResult = newEffectResult;
            }
        }
        
        // search for race
        NSString *race = card[@"race"];
        CGFloat raceResult = [[race lowercaseString] scoreAgainst:text];
        
        // search for quality
        NSString *quality = card[@"rarity"];
        CGFloat qualitiyResult = [[quality lowercaseString] scoreAgainst:text];
        
        CGFloat resultList[5] = {nameResult, setResult, effectResult, raceResult, qualitiyResult};
        CGFloat score = 0;
        for (int i = 0; i < 5; i++) {
            CGFloat value = resultList[i];
            if (value > score) {
                score = value;
            }
        }
        
        if (score > .2) {
            NSDictionary *evaluatedObject = @{@"value": @(score), @"card": card};
            [searchResult addObject:evaluatedObject];
        }
    }
    [searchResult sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        CGFloat val1 = [obj1[@"value"] floatValue];
        CGFloat val2 = [obj2[@"value"] floatValue];
        if (val1 > val2) {
            return NSOrderedAscending;
        } else if (val1 < val2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    NSMutableArray *searchResult2 = [NSMutableArray array];
    for (NSDictionary *dict in searchResult) {
        [searchResult2 addObject:dict[@"card"]];
    }
    self.dataSource = searchResult2;
    [self.tableView reloadData];
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

- (IBAction)contactTouched:(id)sender {
    [ZEUtility showEmailFormWithBodyText:@""];
}

#pragma mark - TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZEQuickSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZEQuickSearchTableViewCell" forIndexPath:indexPath];
    NSDictionary *card = self.dataSource[indexPath.row];
//    NSLog(@"card to show %@", card);
    NSString *cardName = [NSString stringWithFormat:@"%@.jpg", card[@"name"]];
    cell.cardImageView.image = [UIImage imageNamed:cardName];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource.count == 0) {
        tableView.hidden = true;
        [self.quickSearchTextField resignFirstResponder];
    } else {
        tableView.hidden = false;
    }
    return self.dataSource.count;
}

#pragma mark - UITextFieldDelegate

- (void)textUpdated {
    [self filterCardsWithText:_quickSearchTextField.text];
}

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    NSLog(@"Ad is loaded and ready to be displayed");
    
    // You can now display the full screen ad using this code:
    [self.interstitialAd showAdFromRootViewController:self];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    NSLog(@"Ad failed to load");
}

@end
