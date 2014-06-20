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
#import "ZEPublishTableViewController.h"
#import "AHKActionSheet.h"
#import "iRate.h"

@interface ZEViewController () <UITableViewDataSource, UITableViewDelegate, ZECardTableViewCellDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *deckData;
@property (nonatomic, strong) NSCountedSet *countedDeckData;
@property (nonatomic, strong) NSMutableArray *deckDataWithoutDuplicates;
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
    self.chartView.x = CGRectGetMidX(self.view.bounds) - 3;
    [self.chartView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL viewDeckMode = self.viewDeckMode;
    
    self.deckData = [NSMutableArray array];
    self.countedDeckData = [NSCountedSet setWithCapacity:30];
    self.deckDataWithoutDuplicates = [NSMutableArray array];
    
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
    self.deckCountLabel.textAlignment = NSTextAlignmentCenter;
    self.deckCountLabel.backgroundColor = [UIColor grayColor];
    self.pickedTableView.scrollsToTop = NO;
    self.pickedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pickedTableDataSource = [[ZEPickedTableDataSource alloc] init];
    self.pickedTableDataSource.countedDataSource = self.countedDeckData;
    self.pickedTableDataSource.deckDataWithoutDuplicates = self.deckDataWithoutDuplicates;
    self.pickedTableView.dataSource = self.pickedTableDataSource;
    self.pickedTableView.delegate = self;
    
    self.chartView = [[JBBarChartView alloc] initWithFrame:CGRectMake(0, 0, 150, self.navigationController.navigationBar.height)];
    self.chartView.maximumValue = 10;
    self.chartView.minimumValue = 0;
    self.chartView.delegate = self;
    self.chartView.dataSource = self;
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"eg. taunt, onyxia", nil);
    
    [self scrollToTop];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // load
    NSArray *cardsToLoad;
    if (self.deckObject) {
        cardsToLoad = self.deckObject[@"deck"];
    } else if (self.selectedDeckNumber != -1) {
        NSDictionary *deckToLoad = [self getUserDeck];
        cardsToLoad = deckToLoad[@"deck"];
    }
    if (cardsToLoad) {
        for (NSString *cardName in cardsToLoad) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", cardName];
            NSArray *searchResults = [self.cards filteredArrayUsingPredicate:predicate];
            if (searchResults.count > 0) {
                [self.deckData addObject:searchResults[0]];
            }
        }
        [self updateDeckDataArrays];
        if (self.deckObject) {
            self.cards = self.deckDataWithoutDuplicates;
        }
    }
    [self.pickedTableView reloadData];
    [self updateDeckCountLabel];
    if (viewDeckMode) {
        [self setViewDeckMode:YES];
    } else {
        [self setViewDeckMode:NO];
    }
    [self updatePublishButton];
}

- (NSDictionary *)getUserDeck {
    NSArray *userDecks = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY];
    return userDecks[self.selectedDeckNumber];
}

- (NSInteger)calcDustCost {
    NSInteger cost = 0;
    for (NSDictionary *card in self.deckData) {
        NSString *quality = card[@"quality"];
        NSString *set = card[@"set"];
        if (![set isEqualToString:@"basic"]) {
            if ([quality isEqualToString:@"legendary"]) {
                cost += 1600;
            }
            if ([quality isEqualToString:@"epic"]) {
                cost += 400;
            }
            if ([quality isEqualToString:@"rare"]) {
                cost += 100;
            }
            if ([quality isEqualToString:@"common"]) {
                cost += 40;
            }
        }
    }
    return cost;
}

- (NSInteger)countCategory:(NSString *)category {
    NSInteger count = 0;
    for (NSDictionary *card in self.deckData) {
        if ([card[@"category"] isEqualToString:category]) {
            count++;
        }
    }
    return count;
}

- (void)saveDeck {
    NSMutableArray *savedDecks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY] mutableCopy];
    if (savedDecks == nil) {
        savedDecks = [NSMutableArray array];
    }
    
    NSMutableDictionary *saveData = [NSMutableDictionary dictionary];
    NSMutableArray *savedDeckData = [NSMutableArray array];
    if (self.selectedDeckNumber != -1) {
        saveData = [savedDecks[self.selectedDeckNumber] mutableCopy];
    }

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
    [saveData setObject:@([self calcDustCost]) forKey:@"dust"];
    [saveData setObject:@([self countCategory:@"minion"]) forKey:@"minions"];
    [saveData setObject:@([self countCategory:@"spell"]) forKey:@"spells"];
    [saveData setObject:@([self countCategory:@"weapon"]) forKey:@"weapons"];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:savedDecks forKey:USER_DECKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setViewDeckMode:(BOOL)viewDeckMode {
    _viewDeckMode = viewDeckMode;
    if (viewDeckMode || self.deckObject) {
        self.deckCountLabel.backgroundColor = [UIColor grayColor];
        self.dataSource = self.deckDataWithoutDuplicates;
    } else {
        self.deckCountLabel.backgroundColor = [UIColor redColor];
        self.dataSource = self.cards;
    }
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

- (void)updateDeckDataArrays {
    self.countedDeckData = [NSCountedSet setWithArray:self.deckData];
    self.deckDataWithoutDuplicates = [[self.countedDeckData allObjects] mutableCopy];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"mana" ascending:YES];
    [self.deckDataWithoutDuplicates sortUsingDescriptors:@[sort]];
    self.pickedTableDataSource.countedDataSource = self.countedDeckData;
    self.pickedTableDataSource.deckDataWithoutDuplicates = self.deckDataWithoutDuplicates;
}

- (void)updateRemoveButtonWithCard:(NSDictionary *)card onCell:(ZECardTableViewCell *)cell {
    if ([self.deckData containsObject:card] && self.deckObject == nil) {
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
    self.deckCountLabel.text = [NSString stringWithFormat:@"%lu/30", (unsigned long)self.deckData.count];
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
    ZECardTableViewCell *cardCell = (ZECardTableViewCell *)[self.tableView cellForRowAtIndexPath:centerTableCellIndexPath];
    NSDictionary *pickedCard = cardCell.cardData;
    if ([self.deckDataWithoutDuplicates containsObject:pickedCard]) {
        NSInteger index = [self.deckDataWithoutDuplicates indexOfObject:pickedCard];
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
    if (self.viewDeckMode || self.deckObject) {
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

- (void)updatePublishButton {
    if (self.deckObject) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"More", nil);
        if ([self shouldShowMoreButton]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    } else if (self.selectedDeckNumber == -1) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSDictionary *userDeck = [self getUserDeck];
        if (userDeck[@"objectId"]) {
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Update", nil);
        } else {
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Publish", nil);
        }
    }
}

- (BOOL)liked {
    return [self myLikes:[self persistentLikes] containsObjectId:self.deckObject.objectId];
}

- (BOOL)hasDescription {
    NSString *description = self.deckObject[@"description"];
    NSArray *cardDescriptions = self.deckObject[@"cardDescriptions"];
    BOOL hasDescriptions = NO;
    if (description.length != 0) {
        hasDescriptions = YES;
    }
    if (cardDescriptions.count > 0) {
        hasDescriptions = YES;
    }
    return hasDescriptions;
}

- (BOOL)shouldShowMoreButton {
    BOOL shouldShow = NO;
    if (![self liked]) {
        shouldShow = YES;
    }
    if ([self hasDescription]) {
        shouldShow = YES;
    }
    return shouldShow;
}

- (NSMutableArray *)persistentLikes {
    NSMutableArray *myLikes = [[[NSUserDefaults standardUserDefaults] objectForKey:MyLikesUserDefaultsKey] mutableCopy];
    if (myLikes == nil) {
        myLikes = [NSMutableArray array];
    }
    return myLikes;
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
    NSInteger count = [self.countedDeckData countForObject:card];
    if (count > 1) {
        cell.countView.hidden = NO;
         cell.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.countedDeckData countForObject:card]];
    } else {
        cell.countView.hidden = YES;
    }
    [self updateRemoveButtonWithCard:card onCell:cell];
    [self updateFadedStateOnCell:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    
    if (tableView == self.tableView) {
        if (self.deckObject) {
            return;
        }
        
        // add card to the picked list
        NSDictionary *card = self.dataSource[indexPath.row];
        NSUInteger countInDeck = [self deckContainsAmountOfCards:card];
        NSUInteger maxCardsAllowed = [self maxAllowedInDeckOfCard:card];
        if (countInDeck < maxCardsAllowed && self.deckData.count < 30) {
            [self.deckData addObject:card];
            
            NSInteger count = self.deckDataWithoutDuplicates.count;
            [self updateDeckDataArrays];
            
            if (self.deckDataWithoutDuplicates.count == count) {
                [self.pickedTableView reloadData];
            } else {
                NSInteger index = [self.deckDataWithoutDuplicates indexOfObject:card];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.pickedTableView beginUpdates];
                [self.pickedTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [self.pickedTableView endUpdates];
            }
            
            [self.tableView reloadData];
            [self.chartView reloadData];
            ZECardTableViewCell *cardCell = (ZECardTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cardCell.removeButton.hidden = NO;
            [self updateFadedStateOnCell:cardCell];
            [self updateDeckCountLabel];
            [self saveDeck];
            [self updatePublishButton];
        }
    } else if (tableView == self.pickedTableView) {
        // show the picked card
        [self setViewDeckMode:YES];
        NSDictionary *card = self.deckDataWithoutDuplicates[indexPath.row];
        NSInteger firstOccurance = [self.dataSource indexOfObject:card];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:firstOccurance inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        [self filterCardsWithMana:indexPath.row];
        if (self.dataSource.count > 0) {
            [self scrollToTop];
        }
        [self removePickedSelection];
    }
}

- (BOOL)myLikes:(NSArray *)myLikes containsObjectId:(NSString *)objectId {
    for (NSData *deckData in myLikes) {
        PFObject *deck = [NSKeyedUnarchiver unarchiveObjectWithData:deckData];
        if ([deck.objectId isEqualToString:objectId]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - ZECardTableViewCellDelegate

- (void)cardCellDidTouchedRemove:(ZECardTableViewCell *)cell {
    if (self.deckObject) {
        return;
    }
    
    // update picked table
    NSInteger index = [self.deckData indexOfObject:cell.cardData];
    [self.deckData removeObjectAtIndex:index];
    NSInteger count = self.deckDataWithoutDuplicates.count; // grap count before the array is updated
    index = [self.deckDataWithoutDuplicates indexOfObject:cell.cardData]; // grap the index of the cell before the array is updated
    [self updateDeckDataArrays];
    if (count == self.deckDataWithoutDuplicates.count) {
        [self.pickedTableView reloadData];
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.pickedTableView beginUpdates];
        [self.pickedTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.pickedTableView endUpdates];
    }
    
    // update main table
    if (self.viewDeckMode) {
        NSInteger countVisibleCards = self.dataSource.count;
        self.dataSource = self.deckDataWithoutDuplicates;
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
    [self updatePublishButton];
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

#pragma mark - Actions 

- (IBAction)publishTouched:(id)sender {
    if (self.deckObject) {
        AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
        if (![self liked]) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Like and save", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                [self.deckObject incrementKey:@"likes"];
                [self.deckObject saveInBackground];
                
                NSData *deckData = [NSKeyedArchiver archivedDataWithRootObject:self.deckObject];
                NSMutableArray *myLikes = [self persistentLikes];
                [myLikes addObject:deckData];
                [[NSUserDefaults standardUserDefaults] setObject:myLikes forKey:MyLikesUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if ([[iRate sharedInstance] shouldPromptForRating]) {
                    [[iRate sharedInstance] promptIfNetworkAvailable];
                }
                [self updatePublishButton];
                NSString *installationId = self.deckObject[@"installation"];
                if (installationId.length != 0) {
                    PFQuery *query = [PFInstallation query];
                    [query whereKey:@"installationId" equalTo:installationId];
                    PFPush *push = [PFPush new];
                    [push setQuery:query];
                    [push setMessage:[NSString stringWithFormat:@"Someone liked: %@", self.deckObject[@"title"]]];
                    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"push error %@", error);
                        }
                    }];
                }
            }];
        }
        if ([self hasDescription]) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Read Description", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                ZEPublishTableViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PublishTableViewController"];
                vc.deckObject = self.deckObject;
                [self.navigationController pushViewController:vc animated:YES];
                [self updatePublishButton];
            }];
        }
        [actionSheet show];
    } else {
        ZEPublishTableViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PublishTableViewController"];
        vc.selectedDeckNumber = self.selectedDeckNumber;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
