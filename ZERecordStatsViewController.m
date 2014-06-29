//
//  ZERecordStatsViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 26.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZERecordStatsViewController.h"

@interface ZERecordStatsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *winControl;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *classButtons;
@end

@implementation ZERecordStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIButton *button in self.classButtons) {
        [button addTarget:self action:@selector(classTouched:) forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 0.5;
    }
    [self.winControl setSelectedSegmentIndex:-1];
}

- (UIButton *)pickedClassButton {
    for (UIButton *button in self.classButtons) {
        if (button.selected) {
            return button;
        }
    }
    return nil;
}

- (void)setButtonSelected:(UIButton *)button {
    for (UIButton *button in self.classButtons) {
        button.alpha = 0.5;
        button.selected = NO;
    }
    button.alpha = 1;
    button.selected = YES;
}

- (void)classTouched:(UIButton *)sender {
    [self setButtonSelected:sender];
}

- (IBAction)saveTouched:(id)sender {
    UIButton *pickedClassButton = [self pickedClassButton];
    if (pickedClassButton == nil) {
        [ZEUtility showAlertWithTitle:NSLocalizedString(@"Hint", nil) message:NSLocalizedString(@"Please pick a class", nil)];
        return;
    }
    if (self.winControl.selectedSegmentIndex == -1) {
        [ZEUtility showAlertWithTitle:NSLocalizedString(@"Hint", nil) message:NSLocalizedString(@"Please set win or loss", nil)];
        return;
    }
    if (self.winControl.selectedSegmentIndex == 0) {
        NSLog(@"win");
    } else {
        NSLog(@"loss");
    }
    NSLog(@"picked opponent %@", pickedClassButton.titleLabel.text);
    
    NSString *opponent = pickedClassButton.titleLabel.text;
    BOOL win = YES;
    if (self.winControl.selectedSegmentIndex != 0) {
        win = NO;
    }
    
    NSMutableDictionary *deck = [ZEUtility readDeckFromUserDefaultsAtIndex:self.selectedDeckNumber];
    NSMutableArray *stats = [deck[@"stats"] mutableCopy];
    // initialize stats
    if (deck[@"stats"] == nil) {
        stats = [NSMutableArray array];
        NSArray *classNames = [ZEUtility classNames];
        for (NSString *className in classNames) {
            NSMutableDictionary *stat = [NSMutableDictionary dictionary];
            stat[@"class"] = className;
            stat[@"wins"] = @0;
            stat[@"losses"] = @0;
            [stats addObject:stat];
        }
        [deck setObject:stats forKey:@"stats"];
    }

    // update data
    NSInteger changeIndex = [self indexOfClass:opponent fromStatsArray:stats];
    NSMutableDictionary *mStats = [stats[changeIndex] mutableCopy];
    if (win) {
        NSInteger wins = [mStats[@"wins"] integerValue];
        wins++;
        mStats[@"wins"] = @(wins);
    } else {
        NSInteger losses = [mStats[@"losses"] integerValue];
        losses++;
        mStats[@"losses"] = @(losses);
    }
    [stats replaceObjectAtIndex:changeIndex withObject:mStats];
    deck[@"stats"] = stats;
    
    [ZEUtility updateDeckUserDefaults:deck atIndex:self.selectedDeckNumber];
    [ZEUtility showAlertWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Successfully saved", nil)];
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

- (NSInteger)indexOfClass:(NSString *)class fromStatsArray:(NSArray *)stats {
    for (NSDictionary *stat in stats) {
        if ([stat[@"class"] isEqualToString:class]) {
            return [stats indexOfObject:stat];
        }
    }
    NSAssert(YES, @"could not find the class in the stats array, impossibru!");
    return -1;
}

@end
