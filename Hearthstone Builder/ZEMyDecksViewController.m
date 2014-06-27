//
//  ZEMyDecksViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 24.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEMyDecksViewController.h"
#import "ZEViewController.h"
#import "ZEPickClassViewController.h"
#import "ZEMyDecksTableViewCell.h"
#import "AHKActionSheet.h"
#import "ZETrackTableViewController.h"
#import "ZEDrawSimulatorViewController.h"
#import "ZEStatsViewController.h"

@interface ZEMyDecksViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ZEMyDecksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = NSLocalizedString(@"Decks", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateDataSource];
    [self.tableView reloadData];
}

- (void)updateDataSource {
    self.dataSource = [NSMutableArray array];
    NSMutableArray *myDecks = [[NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY]] mutableCopy];
    NSMutableArray *likedDecks = [NSMutableArray array];
    NSArray *likedDecksData = [[NSUserDefaults standardUserDefaults] objectForKey:MyLikesUserDefaultsKey];
    for (NSData *deckData in likedDecksData) {
        PFObject *deckObject = [NSKeyedUnarchiver unarchiveObjectWithData:deckData];
        [likedDecks addObject:deckObject];
    }
    [self.dataSource addObject:myDecks];
    [self.dataSource addObject:likedDecks];
}

- (IBAction)newDeckTouched:(id)sender {
    ZEPickClassViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PickClassViewController"];
    vc.newDeckMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)copyLikedDeckToMyDeck:(PFObject *)likedDeck {
    NSMutableDictionary *copy = [NSMutableDictionary dictionary];
    copy[@"deck"] = likedDeck[@"deck"];
    if (likedDeck[@"description"]) {
        copy[@"description"] = likedDeck[@"description"];
    }
    if (likedDeck[@"cardDescriptions"]) {
        copy[@"cardDescriptions"] = likedDeck[@"cardDescriptions"];
    }
    copy[@"dust"] = likedDeck[@"dust"];
    copy[@"hero"] = likedDeck[@"hero"];
    copy[@"minions"] = likedDeck[@"minions"];
    copy[@"spells"] = likedDeck[@"spells"];
    copy[@"weapons"] = likedDeck[@"weapons"];
    NSString *deckName = likedDeck[@"title"];
    copy[@"title"] = [self addCopyStringToDeckName:deckName];
    [ZEUtility createDeckToUserDefaults:copy];
}

- (NSString *)addCopyStringToDeckName:(NSString *)deckName {
    if (![deckName hasPrefix:NSLocalizedString(@"Copy:", nil)]) {
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Copy:", nil), deckName];
    }
    return deckName;
}

- (void)duplicateMyDeck:(NSDictionary *)myDeck {
    NSMutableDictionary *copy = [NSMutableDictionary dictionaryWithDictionary:myDeck];
    NSString *deckName = myDeck[@"title"];
    copy[@"title"] = [self addCopyStringToDeckName:deckName];
    [copy removeObjectForKey:@"objectId"];
    [ZEUtility createDeckToUserDefaults:copy];
}

#pragma mark - UITableViewDelgate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionData = self.dataSource[section];
    return sectionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"MyDeckCell";
    ZEMyDecksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    NSArray *data = self.dataSource[indexPath.section];
    NSString *title = @"";
    NSString *heroName = @"";
    if (indexPath.section == 0) {
        NSDictionary *deck = data[indexPath.row];
        if (deck[@"title"]) {
            title = deck[@"title"];
        } else {
            title = deck[@"hero"];
        }
        heroName = deck[@"hero"];
        NSArray *cardsInDeck = deck[@"deck"];
        if (cardsInDeck.count == 30) {
            cell.completedIconImageView.hidden = NO;
        } else {
            cell.completedIconImageView.hidden = YES;
        }
    } else {
        PFObject *deckObject = data[indexPath.row];
        title = deckObject[@"title"];
        heroName = deckObject[@"hero"];
        cell.completedIconImageView.hidden = YES;
    }

    cell.label.font = [ZEUtility myStandardFont];
    cell.label.text = title;
    NSString *imageName = [NSString stringWithFormat:@"ico_%@", heroName];
    cell.image.image = [UIImage imageNamed:imageName];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"My Decks", nil);
    } else {
        return NSLocalizedString(@"Liked Decks", nil);
    }
}

- (void)showMyDeck:(NSDictionary *)deck indexPath:(NSIndexPath *)indexPath {
    ZEViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
    vc.hero = deck[@"hero"];
    vc.selectedDeckNumber = indexPath.row;
    vc.viewDeckMode = YES;
    vc.editable = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableArray *)cardDataFromCardNames:(NSArray *)cardNames {
    return [ZEUtility cardDataFromCardNames:cardNames fromDataBase:[ZEDataManager sharedInstance].cards];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data = self.dataSource[indexPath.section];
    if (indexPath.section == 0) {
        NSDictionary *deck = data[indexPath.row];
        NSArray *cardsInDeck = deck[@"deck"];
        if (cardsInDeck.count != 30) {
            [self showMyDeck:deck indexPath:indexPath];
        } else {
            AHKActionSheet *sheet = [[AHKActionSheet alloc] initWithTitle:nil];
            [sheet addButtonWithTitle:NSLocalizedString(@"Show/Edit Deck", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                [self showMyDeck:deck indexPath:indexPath];
            }];
            [sheet addButtonWithTitle:NSLocalizedString(@"Card Tracker", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                ZETrackTableViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"TrackTableViewController"];
                vc.selectedDeckNumber = indexPath.row;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            if (deck[@"stats"]) { // check of the deck has stats
                [sheet addButtonWithTitle:NSLocalizedString(@"Show Stats", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                    ZEStatsViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"StatsViewController"];
                    vc.deckFromUserDefaults = deck;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
            }
            [sheet addButtonWithTitle:NSLocalizedString(@"Make a Copy", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                [self duplicateMyDeck:deck];
                [self updateDataSource];
                [self.tableView reloadData];
                [ZEUtility showToastWithText:NSLocalizedString(@"Deck Duplicated", nil) duration:2];
            }];
            [sheet addButtonWithTitle:NSLocalizedString(@"Draw Card Simulator", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                ZEDrawSimulatorViewController *drawSimulator = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"DrawSimulatorViewController"];
                drawSimulator.deck = [self cardDataFromCardNames:cardsInDeck];
                [self.navigationController pushViewController:drawSimulator animated:YES];
            }];

            [sheet show];
        }
    } else {
        PFObject *likedDeck = data[indexPath.row];
        AHKActionSheet *sheet = [[AHKActionSheet alloc] initWithTitle:nil];
        [sheet addButtonWithTitle:NSLocalizedString(@"Show Deck", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
            ZEViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
            vc.hero = likedDeck[@"hero"];
            vc.viewDeckMode = YES;
            vc.editable = NO;
            vc.deckObject = likedDeck;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [sheet addButtonWithTitle:NSLocalizedString(@"Copy to My Decks", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
            [self copyLikedDeckToMyDeck:likedDeck];
            [ZEUtility showToastWithText:NSLocalizedString(@"Deck Copied", nil) duration:2];
            [self updateDataSource];
            [self.tableView reloadData];
        }];
        [sheet show];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *data = self.dataSource[indexPath.section];
        [data removeObjectAtIndex:indexPath.row];
        if (indexPath.section == 0) {
            [ZEUtility deleteDeckUserDefaultsAtIndex:indexPath.row];
        } else {
            NSMutableArray *likedDecks = [[[NSUserDefaults standardUserDefaults] objectForKey:MyLikesUserDefaultsKey] mutableCopy];
            [likedDecks removeObjectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:likedDecks forKey:MyLikesUserDefaultsKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

@end
