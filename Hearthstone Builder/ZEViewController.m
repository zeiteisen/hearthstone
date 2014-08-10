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
#import "ZEDrawSimulatorViewController.h"
#import <Social/Social.h>

// todo: sort by card set
// todo: highlight sorted list

@interface ZEViewController () <UITableViewDataSource, UITableViewDelegate, ZECardTableViewCellDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *toggleClassButton;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *deckData;
@property (nonatomic, strong) NSCountedSet *countedDeckData;
@property (nonatomic, strong) NSMutableArray *deckDataWithoutDuplicates;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, strong) NSArray *allPickableCards;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UITableView *pickedTableView;
@property (nonatomic, strong) ZEFilterTableDataSource *filterTableDataSource;
@property (nonatomic, strong) ZEPickedTableDataSource *pickedTableDataSource;
@property (nonatomic, strong) JBBarChartView *chartView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContraint;
@property (nonatomic, strong) IBOutlet UILabel *deckCountLabel;
@property (nonatomic, strong) NSMutableArray *deckSave;
@property (nonatomic, assign) BOOL filteredByClass;
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

- (void)filterOnlyClass {
    self.filteredByClass = YES;
    [self filterAndSortAllPickableCardsWithType:self.hero];
}

- (void)filterOnlyNeutral {
    self.filteredByClass = NO;
    [self filterAndSortAllPickableCardsWithType:@"neutral"];
}

- (void)filterAndSortAllPickableCardsWithType:(NSString *)type {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        NSString *hero = evaluatedObject[@"hero"];
        if ([hero isEqualToString:type]) {
            return YES;
        }
        return NO;
    }];
    self.cards = [self.allPickableCards filteredArrayUsingPredicate:predicate];
}

- (NSString *)classImageName {
    return [NSString stringWithFormat:@"ico_%@", self.hero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL viewDeckMode = self.viewDeckMode;
    
    self.deckData = [NSMutableArray array];
    self.countedDeckData = [NSCountedSet setWithCapacity:30];
    self.deckDataWithoutDuplicates = [NSMutableArray array];
    
    
    self.allPickableCards = [ZEDataManager sharedInstance].cards;
    NSPredicate *classPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        NSString *hero = evaluatedObject[@"hero"];
        if ([hero isEqualToString:self.hero] || [hero isEqualToString:@"neutral"]) {
            return YES;
        }
        return NO;
    }];
    self.allPickableCards = [self.allPickableCards filteredArrayUsingPredicate:classPredicate];
    NSArray *sortedArray;
    sortedArray = [self.allPickableCards sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *cardA, NSDictionary *cardB) {
        NSNumber *manaA = cardA[@"mana"];
        NSNumber *manaB = cardB[@"mana"];
        return [manaA compare:manaB];
    }];
    self.allPickableCards = sortedArray;
    
    
    [self filterOnlyClass];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // load
    NSArray *cardNamesToLoad;
    if (self.deckObject) {
        cardNamesToLoad = self.deckObject[@"deck"];
    } else if (self.selectedDeckNumber != -1) {
        NSDictionary *deckToLoad = [self getUserDeck];
        cardNamesToLoad = deckToLoad[@"deck"];
    }
    if (cardNamesToLoad) {
        self.deckData = [ZEUtility cardDataFromCardNames:cardNamesToLoad fromDataBase:self.allPickableCards];
        [self updateDeckDataArrays];
        if (self.deckObject) {
            self.allPickableCards = self.deckDataWithoutDuplicates;
            self.cards = self.allPickableCards;
        }
    }
    [self.pickedTableView reloadData];
    [self updateDeckCountLabel];
    if (viewDeckMode) {
        [self setViewDeckMode:YES];
    } else {
        [self setViewDeckMode:NO];
    }
    if (self.deckData.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [self filterCardsWithMana:8 withDataSource:self.cards];
    NSString *classImageName = [self classImageName];
    [self.toggleClassButton setImage:[UIImage imageNamed:classImageName] forState:UIControlStateNormal];
    [self.toggleClassButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    if (self.deckObject == nil) {
        [self selectFilterAllCardsCell];
    }
    
    [self scrollToTop];
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

- (NSString *)getObjectId {
    if (self.deckObject.objectId) {
        return self.deckObject.objectId;
    } else if (self.selectedDeckNumber != -1) {
        NSDictionary *deck = [ZEUtility readDeckFromUserDefaultsAtIndex:self.selectedDeckNumber];
        NSString *theId = deck[@"objectId"];
        if (theId.length > 0) {
            return theId;
        }
    }
    return nil;
}

- (void)saveDeck {
    if (self.deckObject) { // for safety.
        return;
    }
    
    NSMutableDictionary *saveDeck;
    if (self.selectedDeckNumber != -1) {
        saveDeck = [ZEUtility readDeckFromUserDefaultsAtIndex:self.selectedDeckNumber];
    } else {
        saveDeck = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray *saveCardNames = [NSMutableArray array];
    for (NSDictionary *card in self.deckData) {
        NSString *name = card[@"name"];
        [saveCardNames addObject:name];
    }
    [saveDeck setObject:saveCardNames forKey:@"deck"];
    [saveDeck setObject:self.hero forKey:@"hero"];
    [saveDeck setObject:@([self calcDustCost]) forKey:@"dust"];
    [saveDeck setObject:@([self countCategory:@"minion"]) forKey:@"minions"];
    [saveDeck setObject:@([self countCategory:@"spell"]) forKey:@"spells"];
    [saveDeck setObject:@([self countCategory:@"weapon"]) forKey:@"weapons"];
    
    if (self.selectedDeckNumber == -1) {
        self.selectedDeckNumber = [ZEUtility createDeckToUserDefaults:saveDeck];
    } else {
        [ZEUtility updateDeckUserDefaults:saveDeck atIndex:self.selectedDeckNumber];
    }
    [ZEUtility showToastWithText:NSLocalizedString(@"Deck saved", nil) duration:0.3];
}

- (void)setViewDeckMode:(BOOL)viewDeckMode {
    _viewDeckMode = viewDeckMode;
    if (viewDeckMode || !self.editable) {
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
    for (NSDictionary *card in self.allPickableCards) {
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

- (void)filterCardsWithMana:(NSInteger)mana withDataSource:(NSArray *)dataSource {
    self.viewDeckMode = NO;
    self.searchBar.text = @"";
    if (mana > 7) {
        self.dataSource = dataSource;
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
    self.dataSource = [dataSource filteredArrayUsingPredicate:predicate];
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
    if ([self.deckData containsObject:card] && self.editable) {
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
    if (self.viewDeckMode || !self.editable) {
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

- (BOOL)deckComplete {
    return  self.deckData.count >= 30;
}

- (BOOL)shouldShowMoreButton {
    BOOL shouldShow = NO;
    if (![self liked]) {
        shouldShow = YES;
    }
    if ([self hasDescription]) {
        shouldShow = YES;
    }
    if ([self deckComplete]) {
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

- (void)shareOnNetwork:(NSString *)type {
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:type];
    NSString *title = self.deckObject[@"title"];
    if (title.length == 0 && self.selectedDeckNumber != -1) {
        NSDictionary *deck = [ZEUtility readDeckFromUserDefaultsAtIndex:self.selectedDeckNumber];
        title = deck[@"title"];
    }
    
    NSString *urlString;
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    if ([type isEqualToString:SLServiceTypeTwitter]) {
        urlString = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/decks-for-hearthstone/id882681595"];
        NSString *shortenedTitle = [title substringToIndex:MIN(100, title.length)];
        NSString *other = NSLocalizedString(@"#Hearthstone", nil);
        [composeViewController setInitialText:[NSString stringWithFormat:@"%@ %@", shortenedTitle, other]];
    } else {
        NSString *objectId = [self getObjectId];
        urlString = [NSString stringWithFormat:@"http://dfh.parseapp.com/links?extras=%@", objectId];
        NSString *other = NSLocalizedString(@"Decks for Hearthstone iOS", nil);
        [composeViewController setInitialText:[NSString stringWithFormat:@"%@ @ %@", title, other]];
    }
    [composeViewController addURL:[NSURL URLWithString:urlString]];
    composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result){
            case SLComposeViewControllerResultCancelled: {
                [ZEUtility showToastWithText:NSLocalizedString(@"Share Cancelled", nil) duration:1];
                break;
            }
            default: {
                [ZEUtility showToastWithText:NSLocalizedString(@"Share Succeeded", nil) duration:2];
                break;
            }
        }
    };
    [self presentViewController:composeViewController animated:YES completion:nil];
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
        if (!self.editable) {
            return;
        }
        
        // add card to the picked list
        NSDictionary *card = self.dataSource[indexPath.row];
        NSUInteger countInDeck = [self deckContainsAmountOfCards:card];
        NSUInteger maxCardsAllowed = [self maxAllowedInDeckOfCard:card];
        if (countInDeck < maxCardsAllowed && self.deckData.count < 30) {
            [self.deckData addObject:card];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
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
        }
    } else if (tableView == self.pickedTableView) {
        // show the picked card
        [self setViewDeckMode:YES];
        [self deselectAllFilterCells];
        NSDictionary *card = self.deckDataWithoutDuplicates[indexPath.row];
        NSInteger firstOccurance = [self.dataSource indexOfObject:card];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:firstOccurance inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else { // filter
        if (indexPath.row == 0) { // show all
            [self filterCardsWithMana:8 withDataSource:self.cards];
        } else { // show by mana cost
            [self filterCardsWithMana:indexPath.row-1 withDataSource:self.cards];
            if (self.dataSource.count > 0) {
                [self scrollToTop];
            }
        }
        
        [self deselectAllFilterCells];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = !cell.selected;
        
        
        [self removePickedSelection];
    }
}

- (void)deselectAllFilterCells {
    NSArray *visibleCells = [self.filterTableView visibleCells];
    for (UITableViewCell *cell in visibleCells) {
        cell.selected = NO;
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

- (void)selectFilterAllCardsCell {
    NSIndexPath *allFilterIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.filterTableView cellForRowAtIndexPath:allFilterIndexPath];
    [cell setSelected:YES animated:YES];
}

#pragma mark - ZECardTableViewCellDelegate

- (void)cardCellDidTouchedRemove:(ZECardTableViewCell *)cell {
    if (!self.editable) {
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
    [self filterCardsWithMana:index withDataSource:self.allPickableCards];
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
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
    if ([self deckComplete]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Draw Card Simulator", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
            ZEDrawSimulatorViewController *drawSimulator = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"DrawSimulatorViewController"];
            drawSimulator.deck = self.deckData;
            [self.navigationController pushViewController:drawSimulator animated:YES];
        }];
    }
    NSString *objectId = [self getObjectId];
    if ([self deckComplete] && objectId.length > 0) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Post Deck on Facebook", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                [self shareOnNetwork:SLServiceTypeFacebook];
            }];
        }
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Tweet the Deck", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
                [self shareOnNetwork:SLServiceTypeTwitter];
            }];
        }
    }
    
    if (![self liked] && !self.editable) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Like and Save to My Decks", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
            [self.deckObject incrementKey:@"likes"];
            [self.deckObject saveInBackground];
            
            NSData *deckData = [NSKeyedArchiver archivedDataWithRootObject:self.deckObject];
            NSMutableArray *myLikes = [self persistentLikes];
            [myLikes addObject:deckData];
            [[NSUserDefaults standardUserDefaults] setObject:myLikes forKey:MyLikesUserDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // show success toast
            [ZEUtility showToastWithText:NSLocalizedString(@"Deck saved to My Decks", nil) duration:2.0];
            
            if (![iRate sharedInstance].declinedThisVersion && ![iRate sharedInstance].ratedThisVersion) {
                [[iRate sharedInstance] promptIfNetworkAvailable];
            }
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
    if (([self hasDescription] && !self.editable) || (self.deckObject && [self hasDescription] && self.selectedDeckNumber == 0)) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Read Description", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
            ZEPublishTableViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PublishTableViewController"];
            vc.deckObject = self.deckObject;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    } else if (self.editable && !(![self hasDescription] && self.deckObject)) { // wenn keine description da ist aber das deck aus dem liked array kommt, dann zeige nichts an
        NSString *title;
        NSDictionary *userDeck = [self getUserDeck];
        if (userDeck[@"objectId"]) {
            title = NSLocalizedString(@"Update the Deck on the Server", nil);
        } else {
            title = NSLocalizedString(@"Set Deckname or Publish", nil);
        }
        [actionSheet addButtonWithTitle:title type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
            ZEPublishTableViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PublishTableViewController"];
            vc.selectedDeckNumber = self.selectedDeckNumber;
            [self.navigationController pushViewController:vc animated:YES];

        }];
    }
    [actionSheet show];
}

- (IBAction)toggleClass:(UIButton *)sender {
    [self deselectAllFilterCells];
    [self selectFilterAllCardsCell];
    if (self.filteredByClass) {
        [self filterOnlyNeutral];
        [sender setImage:[UIImage imageNamed:@"ico_neutral"] forState:UIControlStateNormal];
    } else {
        [self filterOnlyClass];
        NSString *imageName = [self classImageName];
        [sender setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    [self filterCardsWithMana:8 withDataSource:self.cards];
}

@end
