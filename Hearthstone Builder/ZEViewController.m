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
    [self.chartView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    self.pickedTableView.scrollsToTop = NO;
    self.pickedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pickedTableDataSource = [[ZEPickedTableDataSource alloc] init];
    self.pickedTableDataSource.dataSource = self.deckData;
    self.pickedTableView.dataSource = self.pickedTableDataSource;
    self.pickedTableView.delegate = self;
    
    self.chartView = [[JBBarChartView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    self.chartView.x = CGRectGetMidX(self.view.bounds);
    self.chartView.delegate = self;
    self.chartView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    [self scrollToTop];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)filterCardsWithText:(NSString *)text {
    [self removePickedSelection];
    [self removeFilterSelection];
    text = [text lowercaseString];
    NSMutableArray *searchResult = [NSMutableArray array];
    for (NSDictionary *card in self.cards) {
        NSString *name = [card[@"name"] lowercaseString];
        CGFloat result = [name scoreAgainst:text];
        if (result > .2) {
            NSDictionary *evaluatedObject = @{@"value": @(result), @"card": card};
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    
    if (tableView == self.tableView) {
        // add card to the picked list
        NSDictionary *card = self.dataSource[indexPath.row];
        [self.deckData addObject:card];
        [self.pickedTableView reloadData];
        [self.chartView reloadData];
        ZECardTableViewCell *cardCell = (ZECardTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cardCell.removeButton.hidden = NO;
    } else if (tableView == self.pickedTableView) {
        // show the picked card
        self.dataSource = self.deckData;
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self removeFilterSelection];
    } else {
        [self filterCardsWithMana:indexPath.row];
        [self scrollToTop];
        [self removePickedSelection];
    }
}

#pragma mark - ZECardTableViewCellDelegate

- (void)cardCellDidTouchedRemove:(ZECardTableViewCell *)cell {
    NSInteger index = [self.deckData indexOfObject:cell.cardData];
    [self.deckData removeObjectAtIndex:index];
    [self.pickedTableView reloadData];
    [self updateRemoveButtonWithCard:cell.cardData onCell:cell];
    [self.chartView reloadData];
    [self.tableView reloadData];
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
