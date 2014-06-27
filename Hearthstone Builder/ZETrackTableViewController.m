//
//  ZETrackTableViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 26.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZETrackTableViewController.h"
#import "ZETrackTableViewCell.h"
#import "ZERecordStatsViewController.h"

@interface ZETrackTableViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *inDeck;
@property (nonatomic, strong) NSArray *outDeck;
@property (nonatomic, strong) NSCountedSet *inSet;
@property (nonatomic, strong) NSCountedSet *outSet;
@end

@implementation ZETrackTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *deck = [ZEUtility readDeckFromUserDefaultsAtIndex:self.selectedDeckNumber];
    NSArray *cards = deck[@"deck"];
    NSArray *cardData = [ZEUtility cardDataFromCardNames:cards fromDataBase:[ZEDataManager sharedInstance].cards];
    self.inSet = [NSCountedSet setWithArray:cardData];
    self.outSet = [NSCountedSet set];
    [self updateDataSource];
    [self updateDrawChance];
}

- (NSArray *)sortArray:(NSArray *)array {
    NSSortDescriptor *manaSort = [NSSortDescriptor sortDescriptorWithKey:@"mana" ascending:YES];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
     return [array sortedArrayUsingDescriptors:@[manaSort, nameSort]];
}

- (void)updateDataSource {
    self.inDeck = [self sortArray:[self.inSet allObjects]];
    self.outDeck = [self sortArray:[self.outSet allObjects]];
    self.dataSource = @[self.inDeck, self.outDeck];
}

- (void)updateDrawChance {
    NSInteger count = [self countCardsInSet];
    CGFloat probability = 100.;
    if (count > 0) {
        probability = (1.0 / count) * 100;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %.02f%%", NSLocalizedString(@"Draw Chance: ", nil), probability];
}

- (NSInteger)countCardsInSet {
    NSInteger count = 0;
    for (NSDictionary *dict in self.inDeck) {
        count += [self.inSet countForObject:dict];
    }
    return count;
}

- (NSInteger)countCardsOutSet {
    NSInteger count = 0;
    for (NSDictionary *dict in self.outDeck) {
        count += [self.outSet countForObject:dict];
    }
    return count;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSCountedSet *data = self.dataSource[section];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    NSArray *data = self.dataSource[indexPath.section];
    ZETrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *card = data[indexPath.row];
    cell.nameLabel.text = card[@"name"];
    cell.manaLabel.text = [NSString stringWithFormat:@"%@", card[@"mana"]];
    cell.nameLabel.textColor = [ZEUtility colorForQuality:card[@"quality"]];
    NSInteger count = 0;
    if (indexPath.section == 0) {
        count = [self.inSet countForObject:card];
    } else {
        count = [self.outSet countForObject:card];
    }
    cell.countLabel.text = [NSString stringWithFormat:@"%i", count];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"%@ (%i)", NSLocalizedString(@"Available Cards", nil), [self countCardsInSet]];
    } else {
        return [NSString stringWithFormat:@"%@ (%i)", NSLocalizedString(@"Discarded Cards", nil), [self countCardsOutSet]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSDictionary *card = self.inDeck[indexPath.row];
        [self.inSet removeObject:card];
        [self.outSet addObject:card];
    } else {
        NSDictionary *card = self.outDeck[indexPath.row];
        [self.outSet removeObject:card];
        [self.inSet addObject:card];
    }
    [self updateDataSource];
    [self updateDrawChance];
    [tableView reloadData];
}

#pragma mark - Actions

- (IBAction)saveTouched:(id)sender {
    ZERecordStatsViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"RecordStatsViewController"];
    vc.selectedDeckNumber = self.selectedDeckNumber;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
