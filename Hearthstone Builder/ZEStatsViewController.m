//
//  ZEStatsViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 26.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEStatsViewController.h"
#import "XYPieChart.h"
#import "JBBarChartView.h"

@interface ZEStatsViewController () <XYPieChartDataSource, XYPieChartDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet XYPieChart *winsPieChart;
@property (nonatomic, strong) NSArray *winLossDataSource;
@property (weak, nonatomic) IBOutlet JBBarChartView *barChartView;
@property (nonatomic, strong) NSArray *barChartViewDataSource;
@property (weak, nonatomic) IBOutlet UIView *classBarView;
@property (weak, nonatomic) IBOutlet UILabel *classWinsLabel;
@end

@implementation ZEStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.barChartView.backgroundColor = [UIColor whiteColor];
    self.winsPieChart.backgroundColor = [UIColor whiteColor];
    
    self.winLossDataSource = [self calcWinLoss];
    self.barChartViewDataSource = [self calcClassWinsPercentage];
    self.winsPieChart.delegate = self;
    self.winsPieChart.dataSource = self;
    [self.winsPieChart setStartPieAngle:M_PI_2];	//optional
    [self.winsPieChart setAnimationSpeed:1.0];	//optional
    [self.winsPieChart setLabelFont:[ZEUtility myStandardFont]];	//optional
    [self.winsPieChart setLabelColor:[UIColor blackColor]];	//optional, defaults to white
    [self.winsPieChart setShowPercentage:NO];	//optional
    [self.winsPieChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];	//optional
    [self.winsPieChart reloadData];

    self.barChartView.dataSource = self;
    self.barChartView.delegate = self;
    self.barChartView.maximumValue = 100;
    self.barChartView.minimumValue = 0;

    [self.barChartView reloadData];
    
}

- (NSArray *)calcClassWinsPercentage {
    NSArray *stats = self.deckFromUserDefaults[@"stats"];
    NSMutableArray *dataSource = [NSMutableArray array];
    for (NSDictionary *stat in stats) {
        NSNumber *w = stat[@"wins"];
        NSNumber *l = stat[@"losses"];
        CGFloat totalGames = w.integerValue + l.integerValue;
        CGFloat value = 0.;
        if (totalGames > 0) {
            value = (w.floatValue/totalGames) * 100;
        }
        [dataSource addObject:@(value)];
    }
    return dataSource;
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
            NSString *winString = NSLocalizedString(@"Wins", nil);
            return [NSString stringWithFormat:@"%@: %@", winString, self.winLossDataSource[index]];
        } else {
            NSString *lossString = NSLocalizedString(@"Losses", nil);
            return [NSString stringWithFormat:@"%@: %@", lossString, self.winLossDataSource[index]];
        }
    }
    return @"";
}

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView {
    return self.barChartViewDataSource.count;
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index {
    NSNumber *number = self.barChartViewDataSource[index];
    return number.floatValue;
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index {
    NSNumber *number = self.barChartViewDataSource[index];
    NSArray *classNames = [ZEUtility classNames];
    NSString *className = classNames[index];
    self.classWinsLabel.text = [NSString stringWithFormat:@"%@: %li%% wins", className, (long)number.integerValue];
}

@end
