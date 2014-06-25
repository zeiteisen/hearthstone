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

@interface ZEMyDecksViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ZEMyDecksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
    } else {
        PFObject *deckObject = data[indexPath.row];
        title = deckObject[@"title"];
        heroName = deckObject[@"hero"];
    }
    ZEMyDecksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data = self.dataSource[indexPath.section];
    ZEViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
    if (indexPath.section == 0) {
        NSDictionary *deck = data[indexPath.row];
        vc.hero = deck[@"hero"];
        vc.selectedDeckNumber = indexPath.row;
        vc.viewDeckMode = YES;
        vc.editable = YES;
    } else {
        PFObject *likedDeck = data[indexPath.row];
        vc.hero = likedDeck[@"hero"];
        vc.viewDeckMode = YES;
        vc.editable = YES;
        vc.deckObject = likedDeck;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *data = self.dataSource[indexPath.section];
        [data removeObjectAtIndex:indexPath.row];
        if (indexPath.section == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:USER_DECKS_KEY];
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
