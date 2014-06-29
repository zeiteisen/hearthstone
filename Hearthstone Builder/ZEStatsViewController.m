//
//  ZEStatsViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 26.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEStatsViewController.h"
#import "XYPieChart.h"

@interface ZEStatsViewController () <XYPieChartDataSource, XYPieChartDelegate>
@property (weak, nonatomic) IBOutlet XYPieChart *winsPieChart;
@property (nonatomic, strong) NSArray *winLossDataSource;
@end

@implementation ZEStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.winLossDataSource = [self calcWinLoss];
    self.winsPieChart.delegate = self;
    self.winsPieChart.dataSource = self;
    [self.winsPieChart setStartPieAngle:M_PI_2];	//optional
    [self.winsPieChart setAnimationSpeed:1.0];	//optional
    [self.winsPieChart setLabelFont:[ZEUtility myStandardFont]];	//optional
    [self.winsPieChart setLabelColor:[UIColor blackColor]];	//optional, defaults to white
    [self.winsPieChart setShowPercentage:NO];	//optional
    [self.winsPieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];	//optional
    [self.winsPieChart reloadData];
}

- (NSArray *)calcWinLoss {
    NSArray *stats = self.deckFromUserDefaults[@"stats"];
    NSInteger wins = 0;
    NSInteger losses = 0;
    for (NSDictionary *stat in stats) {
        NSNumber *w = stat[@"wins"];
        NSNumber *l = stat[@"losses"];
        wins += w.integerValue;
        losses += l.integerValue;
    }
    return @[@(wins), @(losses)];
}

#pragma mark - XYPieChartDelegate

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    if (pieChart == self.winsPieChart) {
        return self.winLossDataSource.count;
    }
    return 0;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    if (pieChart == self.winsPieChart) {
        NSNumber *number = self.winLossDataSource[index];
        return number.floatValue;
    }
    return 50.;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    if (pieChart == self.winsPieChart) {
        if (index == 0) {
            return [UIColor greenColor];
        } else {
            return [UIColor redColor];
        }
    }
    return [UIColor blueColor];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    if (pieChart == self.winsPieChart) {
        if (index == 0) {
            return NSLocalizedString(@"Wins", nil);
        } else {
            return NSLocalizedString(@"Losses", nil);
        }
    }
    return @"";
}

@end
