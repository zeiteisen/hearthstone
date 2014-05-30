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
#import "UINavigationController+M13ProgressViewBar.h"
#import "AHKActionSheet.h"

@interface ZEOtherDecksTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ZEOtherDecksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRecent];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", self.hero]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.height = 150;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.tableHeaderView = imageView;
}

- (void)loadMostViews {
    PFQuery *query = [self defaultQuery];
    [query orderByDescending:@"views"];
    [self loadDecksWithQuery:query];
}

- (void)loadGoodCheap {
    PFQuery *query = [self defaultQuery];
    [query whereKey:@"likes" greaterThan:@10];
    [query whereKey:@"dust" lessThan:@500];
    [query orderByDescending:@"likes"];
    [self loadDecksWithQuery:query];
}

- (void)loadRecent {
    PFQuery *query = [self defaultQuery];
    [query orderByDescending:@"updatedAt"];
    [self loadDecksWithQuery:query];
}

- (void)loadMostLikes {
    PFQuery *query = [self defaultQuery];
    [query orderByDescending:@"likes"];
    [self loadDecksWithQuery:query];
}

- (PFQuery *)defaultQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"Deck"];
    [query whereKey:@"hero" equalTo:self.hero];
    [query selectKeys:@[@"title", @"likes", @"dust", @"hero", @"minions", @"spells", @"weapons", @"views"]];
    return query;
}

- (void)loadDecksWithQuery:(PFQuery *)query {
    [self showProgress];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self hideProgress];
        if (error) {
            [ZEUtility showAlertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription];
        } else {
            self.dataSource = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        }
    }];
}

- (void)showProgress {
    [self.navigationController showProgress];
    [self.navigationController setIndeterminate:YES];
}

- (void)hideProgress {
    [self.navigationController finishProgress];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    ZEOtherDeckTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    UIFont *smallerFont = [UIFont fontWithName:cell.deckNameLabel.font.fontName size:14];
    cell.dustLabel.font = smallerFont;
    cell.minionsLabel.font = smallerFont;
    cell.spellsLabel.font = smallerFont;
    cell.weaponsLabel.font = smallerFont;
    
    PFObject *deck = self.dataSource[indexPath.row];
    cell.deckNameLabel.text = deck[@"title"];
    
    NSString *string = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Dust: ", nil), deck[@"dust"]];
    cell.dustLabel.text = string;
    
    if (deck[@"likes"]) {
        cell.upvoteView.hidden = NO;
        string = [NSString stringWithFormat:@"%@", deck[@"likes"]];
    } else {
        cell.upvoteView.hidden = YES;
    }
    cell.likesLabel.text = string;
    
    if (deck[@"views"]) {
        NSNumber *views = deck[@"views"];
        string = [NSString stringWithFormat:@"%@", deck[@"views"]];
        cell.viewsLabel.text = string;
        if (views.integerValue > 100) {
            cell.viewsView.hidden = NO;
        } else {
            cell.viewsView.hidden = YES;
        }
    } else {
        cell.viewsView.hidden = YES;
    }
    
    string = [NSString stringWithFormat:@"%@ %@", deck[@"spells"], NSLocalizedString(@"Spells", nil)];
    cell.spellsLabel.text = string;
    
    string = [NSString stringWithFormat:@"%@ %@", deck[@"minions"], NSLocalizedString(@"Minions", nil)];
    cell.minionsLabel.text = string;
    
    string = [NSString stringWithFormat:@"%@ %@", deck[@"weapons"], NSLocalizedString(@"Weapons", nil)];
    cell.weaponsLabel.text = string;
    
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
    [self showProgress];
    [vc.deckObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self hideProgress];
        if (error) {
            [ZEUtility showAlertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription];
        } else {
            [vc.deckObject incrementKey:@"views"];
            [vc.deckObject saveInBackground];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

#pragma mark - Actions

- (IBAction)filterTouched:(id)sender {
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Recent", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self loadRecent];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Most likes", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self loadMostLikes];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cheap with many likes", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self loadGoodCheap];
    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Most views", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self loadMostViews];
    }];
    
    [actionSheet show];
}


@end
