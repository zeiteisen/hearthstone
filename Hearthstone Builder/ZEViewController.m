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
#import "JBBarChartView.h"
#import "NSString+Score.h"
#import "UIImage+ImageEffects.h"

@interface ZEViewController () <UITableViewDataSource, UITableViewDelegate, ZECardTableViewCellDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *deckData;
@property (nonatomic, strong) NSArray *cards;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UITableView *pickedTableView;
@property (nonatomic, strong) ZEFilterTableDataSource *filterTableDataSource;
@property (nonatomic, strong) ZEPickedTableDataSource *pickedTableDataSource;
@property (nonatomic, strong) JBBarChartView *chartView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContraint;
@property (nonatomic, strong) IBOutlet UILabel *deckCountLabel;
@property (nonatomic, strong) NSMutableArray *deckSave;
@end

@implementation ZEViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.chartView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.chartView];
    self.chartView.x = CGRectGetMidX(self.view.bounds);
    [self.chartView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL viewDeckMode = self.viewDeckMode;
    
    self.deckData = [NSMutableArray arrayWithCapacity:30];
    self.cards = [ZEDataManager sharedInstance].cards;
    NSPredicate *classPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        NSString *hero = evaluatedObject[@"hero"];
        if ([hero isEqualToString:self.hero] || [hero isEqualToString:@"neutral"]) {
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
    self.filterTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.filterTableView reloadData];
    
    self.deckCountLabel.text = @"0/30";
    self.deckCountLabel.backgroundColor = [UIColor grayColor];
    self.pickedTableView.scrollsToTop = NO;
    self.pickedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pickedTableDataSource = [[ZEPickedTableDataSource alloc] init];
    self.pickedTableDataSource.dataSource = self.deckData;
    self.pickedTableView.dataSource = self.pickedTableDataSource;
    self.pickedTableView.delegate = self;
    
    self.chartView = [[JBBarChartView alloc] initWithFrame:CGRectMake(0, 0, 150, self.navigationController.navigationBar.height)];
    self.chartView.maximumValue = 10;
    self.chartView.minimumValue = 1;
    self.chartView.delegate = self;
    self.chartView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    [self scrollToTop];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.selectedDeckNumber != -1) { // -1 new deck
        // load deck
        NSArray *userDecks = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY];
        NSDictionary *deckToLoad = userDecks[self.selectedDeckNumber];
        for (NSString *cardName in deckToLoad[@"deck"]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", cardName];
            NSArray *searchResults = [self.cards filteredArrayUsingPredicate:predicate];
            if (searchResults.count > 0) {
                [self.deckData addObject:searchResults[0]];
            }
        }
    }
    
    [self updateDeckCountLabel];
    if (viewDeckMode) {
        [self setViewDeckMode:YES];
    }
}

- (void)saveDeck {
    NSMutableArray *savedDecks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY] mutableCopy];
    if (savedDecks == nil) {
        savedDecks = [NSMutableArray array];
    }
    NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
    NSMutableArray *savedDeckData = [NSMutableArray array];

    [saveData setObject:self.hero forKey:@"hero"];
    for (NSDictionary *card in self.deckData) {
        NSString *name = card[@"name"];
        [savedDeckData addObject:name];
    }
    [saveData setObject:savedDeckData forKey:@"deck"];
    
    if (self.selectedDeckNumber == -1) {
        self.selectedDeckNumber = savedDecks.count;
        [savedDecks addObject:saveData];
    } else {
        [savedDecks replaceObjectAtIndex:self.selectedDeckNumber withObject:saveData];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:savedDecks forKey:USER_DECKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setViewDeckMode:(BOOL)viewDeckMode {
    _viewDeckMode = viewDeckMode;
    if (viewDeckMode) {
        self.deckCountLabel.backgroundColor = [UIColor greenColor];
    } else {
        self.deckCountLabel.backgroundColor = [UIColor grayColor];
    }
    [self setDataSourceToDeckDataWithoutDuplicates];
    [self.tableView reloadData];
    [self removeFilterSelection];
}

- (void)filterCardsWithText:(NSString *)text {
    self.viewDeckMode = NO;
    [self removePickedSelection];
    [self removeFilterSelection];
    text = [text lowercaseString];
    NSMutableArray *searchResult = [NSMutableArray array];
    for (NSDictionary *card in self.cards) {
        // search for name
        NSString *name = [card[@"name"] lowercaseString];
        CGFloat nameResult = [name scoreAgainst:text];
        
        // search for effect
        NSArray *effectList = card[@"effect_list"];
        CGFloat effectResult = 0;
        for (NSDictionary *effect in effectList) {
            NSString *effectName = effect[@"effect"];
            CGFloat newEffectResult = [effectName scoreAgainst:text];
            if (newEffectResult > effectResult) {
                effectResult = newEffectResult;
            }
        }
        
        // search for race
        NSString *race = card[@"race"];
        CGFloat raceResult = [race scoreAgainst:text];
        
        // search for quality
        NSString *quality = card[@"quality"];
        CGFloat qualitiyResult = [quality scoreAgainst:text];
        
        CGFloat resultList[4] = {nameResult, effectResult, raceResult, qualitiyResult};
        CGFloat score = 0;
        for (int i = 0; i < 4; i++) {
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

- (void)filterCardsWithMana:(NSInteger)mana {
    self.viewDeckMode = NO;
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

- (void)updateRemoveButtonWithCard:(NSDictionary *)card onCell:(ZECardTableViewCell *)cell {
    if ([self.deckData containsObject:card]) {
        cell.removeButton.hidden = NO;
    } else {
        cell.removeButton.hidden = YES;
    }
}

- (NSUInteger)deckContainsAmountOfCards:(NSDictionary *)searchCard {
    NSUInteger count = 0;
    for (NSDictionary *card in self.deckData) {
        if (card == searchCard) {
            count++;
        }
    }
    return count;
}

- (void)updateDeckCountLabel {
    self.deckCountLabel.text = [NSString stringWithFormat:@"%i/30", self.deckData.count];
}

- (void)scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)removeFilterSelection {
    NSIndexPath *selectedFilterIndexPath = [self.filterTableView indexPathForSelectedRow];
    [self.filterTableView deselectRowAtIndexPath:selectedFilterIndexPath animated:YES];
}

- (void)removePickedSelection {
    NSIndexPath *selectedPickedIndexPath = [self.pickedTableView indexPathForSelectedRow];
    [self.pickedTableView deselectRowAtIndexPath:selectedPickedIndexPath animated:YES];
}

- (NSIndexPath *)centerTableCellIndexPath {
    return [self.tableView indexPathForRowAtPoint:CGPointMake(CGRectGetMidX(self.tableView.bounds), CGRectGetMidY(self.tableView.bounds))];
}

- (void)highlightPickedCard {
    NSIndexPath *centerTableCellIndexPath = [self centerTableCellIndexPath];
    ZECardTableViewCell *cardCell = (ZECardTableViewCell *)[self.tableView cellForRowAtIndexPath:centerTableCellIndexPath];;
    NSDictionary *pickedCard = cardCell.cardData;
    if ([self.deckData containsObject:pickedCard]) {
        NSInteger index = [self.deckData indexOfObject:pickedCard];
        [self.pickedTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (NSUInteger)maxAllowedInDeckOfCard:(NSDictionary *)card {
    NSUInteger maxCardsAllowed = 2;
    if ([card[@"quality"] isEqualToString:@"legendary"]) {
        maxCardsAllowed = 1;
    }
    return maxCardsAllowed;
}

- (void)updateFadedStateOnCell:(ZECardTableViewCell *)cell {
    if (self.viewDeckMode) {
        cell.faded = NO;
    } else {
        NSUInteger countInDeck = [self deckContainsAmountOfCards:cell.cardData];
        NSUInteger maxCardsAllowed = [self maxAllowedInDeckOfCard:cell.cardData];
        if (countInDeck >= maxCardsAllowed) {
            cell.faded = YES;
        } else{
            cell.faded = NO;
        }
    }
}

- (void)setDataSourceToDeckDataWithoutDuplicates {
    NSSet *set = [NSSet setWithArray:self.deckData];
    self.dataSource = [[set allObjects] mutableCopy];
}

#pragma mark - UITableViewDataSource

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self highlightPickedCard];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self highlightPickedCard];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZECardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.delegate = self;
    NSDictionary *card = self.dataSource[indexPath.row];
    cell.cardData = card;
    NSString *cardName = [NSString stringWithFormat:@"%@.jpg", card[@"name"]];
    cell.image.image = [UIImage imageNamed:cardName];
    [self updateRemoveButtonWithCard:card onCell:cell];
    [self updateFadedStateOnCell:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    
    if (tableView == self.tableView) {
        // add card to the picked list
        NSDictionary *card = self.dataSource[indexPath.row];
        NSUInteger countInDeck = [self deckContainsAmountOfCards:card];
        NSUInteger maxCardsAllowed = [self maxAllowedInDeckOfCard:card];
        if (countInDeck < maxCardsAllowed && self.deckData.count < 30) {
            [self.deckData addObject:card];
            [self.pickedTableView reloadData];
            [self.tableView reloadData];
            [self.chartView reloadData];
            ZECardTableViewCell *cardCell = (ZECardTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cardCell.removeButton.hidden = NO;
            [self updateFadedStateOnCell:cardCell];
            [self updateDeckCountLabel];
            [self saveDeck];
        }
    } else if (tableView == self.pickedTableView) {
        // show the picked card
        [self setViewDeckMode:YES];
        NSDictionary *card = self.deckData[indexPath.row];
        NSInteger firstOccurance = [self.dataSource indexOfObject:card];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:firstOccurance inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        [self filterCardsWithMana:indexPath.row];
        [self scrollToTop];
        [self removePickedSelection];
    }
}

#pragma mark - ZECardTableViewCellDelegate

- (void)cardCellDidTouchedRemove:(ZECardTableViewCell *)cell {
    // update picked table
    NSInteger index = [self.deckData indexOfObject:cell.cardData];
    [self.deckData removeObjectAtIndex:index];
    [self.pickedTableView reloadData];
    
    // update main table
    if (self.viewDeckMode) {
        NSInteger countVisibleCards = self.dataSource.count;
        [self setDataSourceToDeckDataWithoutDuplicates];
        if (countVisibleCards > self.dataSource.count) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
    [self.tableView reloadData];
    
    [self updateFadedStateOnCell:cell];
    [self updateRemoveButtonWithCard:cell.cardData onCell:cell];
    [self.chartView reloadData];
    [self highlightPickedCard];
    [self updateDeckCountLabel];
    [self saveDeck];
}

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView {
    return 8;
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index {
    CGFloat count = 0;
    for (NSDictionary *card in self.deckData) {
        NSNumber *mana = card[@"mana"];
        if (index == 7) {
            if (mana.integerValue >= index) {
                count++;
            }
        }
        else if (mana.integerValue == index) {
            count++;
        }
    }
    return count;
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index {
    [self filterCardsWithMana:index];
}

- (NSUInteger)barPaddingForBarChartView:(JBBarChartView *)barChartView {
    return 0;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self filterCardsWithText:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterCardsWithText:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.bottomContraint.constant = keyboardFrameBeginRect.size.height;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomContraint.constant = 0;
}

@end
