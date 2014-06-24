//
//  ZEDrawSimulatorViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 23.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEDrawSimulatorViewController.h"
#import "ZECardCollectionViewCell.h"

@interface ZEDrawSimulatorViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ZEDrawSimulatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"deck %@", self.deck);
    [self.collectionView reloadData];
    // Do any additional setup after loading the view.
}

#pragma mark - Actions

- (IBAction)drawTouched:(id)sender {
}

- (IBAction)restartTouched:(id)sender {
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.deck.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    ZECardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *card = self.deck[indexPath.row];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", card[@"name"]];
    UIImage *image = [UIImage imageNamed:imageName];
    cell.imageView.image = image;
    return cell;
}

@end
