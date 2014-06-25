//
//  ZEDrawSimulatorViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 23.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEDrawSimulatorViewController.h"
#import "ZECardCollectionViewCell.h"
#import "NSMutableArray+Shuffle.h"

@interface ZEDrawSimulatorViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIButton *drawButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *internalDeck;
@property (nonatomic, assign) BOOL mulligan;
@end

@implementation ZEDrawSimulatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self start];
}

- (void)start {
    for (ZECardCollectionViewCell *cell in [self.collectionView visibleCells]) {
        cell.imageView.alpha = 1.;
    }
    self.mulligan = YES;
    [self.drawButton setTitle:NSLocalizedString(@"Pick", nil) forState:UIControlStateNormal];
    self.navigationItem.title = NSLocalizedString(@"Mulligan", nil);
    [self.dataSource removeAllObjects];
    self.internalDeck = [NSMutableArray arrayWithArray:self.deck];
    [self.internalDeck shuffle];
    for (int i = 0; i < 3; i++) {
        [self addCard];
    }
    [self.collectionView reloadData];
}

- (void)addCard {
    if (self.internalDeck.count > 0) {
        NSDictionary *card = [self.internalDeck lastObject];
        [self.internalDeck removeLastObject];
        [self.dataSource addObject:card];
    }
}

#pragma mark - Actions

- (IBAction)drawTouched:(UIButton *)sender {
    if (self.mulligan) {
        self.mulligan = NO;
        [self.drawButton setTitle:NSLocalizedString(@"Draw", nil) forState:UIControlStateNormal];
        self.navigationItem.title = NSLocalizedString(@"Draw", nil);
        NSArray *cells = [self.collectionView visibleCells];
        NSMutableArray *replaceIndexPaths = [NSMutableArray array];
        for (ZECardCollectionViewCell *cell in cells) {
            if (cell.imageView.alpha <= .9) {
                NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                cell.imageView.alpha = 1;
                [replaceIndexPaths addObject:indexPath];
                NSDictionary *card = self.dataSource[indexPath.row];
                [self.internalDeck addObject:card];
            }
        }
        [self.internalDeck shuffle];
        
        for (NSIndexPath *indexPath in replaceIndexPaths) {
            NSDictionary *newCard = [self.internalDeck lastObject];
            [self.internalDeck removeLastObject];
            [self.dataSource replaceObjectAtIndex:indexPath.row withObject:newCard];
        }
        [self.collectionView reloadItemsAtIndexPaths:replaceIndexPaths];
        
        
    } else {
        [self addCard];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        if (self.internalDeck.count <= 0) {
            sender.enabled = NO;
        }
    }
}

- (IBAction)restartTouched:(id)sender {
    [self start];
    self.drawButton.enabled = YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    ZECardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *card = self.dataSource[indexPath.row];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", card[@"name"]];
    UIImage *image = [UIImage imageNamed:imageName];
    cell.imageView.image = image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mulligan) {
        ZECardCollectionViewCell *cell = (ZECardCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.imageView.alpha == 1) {
            cell.imageView.alpha = 0.5;
        } else {
            cell.imageView.alpha = 1;
        }
    }
}

@end
