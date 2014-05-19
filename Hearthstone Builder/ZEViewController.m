//
//  ZEViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 12.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEViewController.h"
#import "ZECardTableViewCell.h"
#import "ZEFilterTableDataSource.h"
#import "ZEPickedTableDataSource.h"

@interface ZEViewController () <UITableViewDataSource, UITableViewDelegate, ZECardTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *deckData;
@property (nonatomic, strong) NSArray *cards;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UITableView *pickedTableView;
@property (nonatomic, strong) ZEFilterTableDataSource *filterTableDataSource;
@property (nonatomic, strong) ZEPickedTableDataSource *pickedTableDataSource;
@end

@implementation ZEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // test
    self.hero = @"mage";
    
    self.deckData = [NSMutableArray arrayWithCapacity:30];
    self.cards = [ZEDataManager sharedInstance].cards;
    NSPredicate *classPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        NSString *hero = evaluatedObject[@"hero"];
        if ([hero isEqualToString:@"mage"] || [hero isEqualToString:@"neutral"]) {
            return YES;
        }
        return NO;
    }];
    self.cards = [self.cards filteredArrayUsingPredicate:classPredicate];
    [self filterCardsWithMana:0];
    [self.tableView reloadData];
    self.tableView.scrollsToTop = YES;
    
    self.filterTableView.scrollsToTop = NO;
    self.filterTableDataSource = [[ZEFilterTableDataSource alloc] init];
    self.filterTableView.dataSource = self.filterTableDataSource;
    self.filterTableView.delegate = self;
    [self.filterTableView reloadData];
    
    self.pickedTableView.scrollsToTop = NO;
    self.pickedTableDataSource = [[ZEPickedTableDataSource alloc] init];
    self.pickedTableDataSource.dataSource = self.deckData;
    self.pickedTableView.dataSource = self.pickedTableDataSource;
}

- (void)filterCardsWithMana:(NSInteger)mana {
    if (mana > 7) {
        self.dataSource = self.cards;
        [self.tableView reloadData];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        NSNumber *number = evaluatedObject[@"mana"];
        if (number.integerValue == mana) {
            return YES;
        }
        if (mana == 7) {
            if (number.integerValue >= mana) {
                return YES;
            }
        }
        return NO;
    }];
    self.dataSource = [self.cards filteredArrayUsingPredicate:predicate];
    NSMutableArray *heroCards = [NSMutableArray array];
    NSMutableArray *nonHeroCards = [NSMutableArray array];
    for (NSDictionary *card in self.dataSource) {
        if ([card[@"hero"] isEqualToString:self.hero]) {
            [heroCards addObject:card];
        } else {
            [nonHeroCards addObject:card];
        }
    }
    NSMutableArray *sortedArray = [NSMutableArray array];
    [sortedArray addObjectsFromArray:heroCards];
    [sortedArray addObjectsFromArray:nonHeroCards];
    self.dataSource = sortedArray;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZECardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.delegate = self;
    NSDictionary *card = self.dataSource[indexPath.row];
    cell.cardData = card;
    cell.nameLabel.text = card[@"flavour_text"];
    NSString *cardName = [NSString stringWithFormat:@"%@.jpg", card[@"name"]];
    cell.image.image = [UIImage imageNamed:cardName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        // add card to the picked list
        NSDictionary *card = self.dataSource[indexPath.row];
        [self.deckData addObject:card];
        [self.pickedTableView reloadData];
    } else if (tableView == self.pickedTableView) {
        // remove card from the picked list
    } else {
        // filter list
        [self filterCardsWithMana:indexPath.row];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
}

#pragma mark - ZECardTableViewCellDelegate

- (void)cardCellDidTouchedRemove:(ZECardTableViewCell *)cell {
    NSInteger index = [self.deckData indexOfObject:cell.cardData];
    [self.deckData removeObjectAtIndex:index];
}

- (void)cardCellDidTouchedAdd:(ZECardTableViewCell *)cell {
    [self.deckData addObject:cell.cardData];
}

@end
