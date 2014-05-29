//
//  ZEOtherDecksTableViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 25.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEOtherDecksTableViewController.h"
#import "ZEViewController.h"
#import "Chartboost.h"
#import "ZEOtherDeckTableViewCell.h"

@interface ZEOtherDecksTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ZEOtherDecksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"Deck"];
    [query whereKey:@"hero" equalTo:self.hero];
    [query orderByDescending:@"updatedAt"];
    [query selectKeys:@[@"title", @"likes", @"dust", @"hero", @"minions", @"spells", @"weapons"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [ZEUtility showAlertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription];
        } else {
            self.dataSource = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    ZEOtherDeckTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.deckNameLabel.font = [ZEUtility myStandardFont];
    cell.likesLabel.font = [ZEUtility myStandardFont];
    cell.dustLabel.font = [ZEUtility myStandardFont];
    cell.spellsLabel.font = [ZEUtility myStandardFont];
    cell.minionsLabel.font = [ZEUtility myStandardFont];
    cell.weaponsLabel.font = [ZEUtility myStandardFont];
    
    PFObject *deck = self.dataSource[indexPath.row];
    cell.deckNameLabel.text = deck[@"title"];
    
    NSString *string = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Dust", nil), deck[@"dust"]];
    cell.dustLabel.text = string;
    
    if (deck[@"likes"]) {
        string = [NSString stringWithFormat:@"%@ %@", deck[@"likes"], NSLocalizedString(@"Likes", nil)];
    } else {
        string = @"";
    }
    cell.likesLabel.text = string;
    
    string = [NSString stringWithFormat:@"%@ %@", deck[@"spells"], NSLocalizedString(@"Spells", nil)];
    cell.spellsLabel.text = string;
    
    string = [NSString stringWithFormat:@"%@ %@", deck[@"minions"], NSLocalizedString(@"Minions", nil)];
    cell.minionsLabel.text = string;
    
    string = [NSString stringWithFormat:@"%@ %@", deck[@"weapons"], NSLocalizedString(@"Weapons", nil)];
    cell.weaponsLabel.text = string;
    
    NSString *imageName = [NSString stringWithFormat:@"ico_%@", deck[@"hero"]];
    cell.iconImage.image = [UIImage imageNamed:imageName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[Chartboost sharedChartboost] hasCachedInterstitial:CBLocationLevelStart]) {
        [[Chartboost sharedChartboost] showInterstitial:CBLocationLevelStart];
    }
    ZEViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
    vc.hero = self.hero;
    vc.viewDeckMode = YES;
    vc.deckObject = self.dataSource[indexPath.row];
    [vc.deckObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            [ZEUtility showAlertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription];
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

@end
