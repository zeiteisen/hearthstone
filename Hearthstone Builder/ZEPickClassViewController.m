//
//  ZEPickClassViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 20.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPickClassViewController.h"
#import "ZEViewController.h"

@interface ZEPickClassViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ZEPickClassViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataSource = @[@"warrior", @"shaman", @"rogue", @"paladin", @"hunter", @"druid", @"warlock", @"mage", @"priest"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZEViewController *viewController = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
    viewController.hero = self.dataSource[indexPath.row];
    viewController.selectedDeckNumber = -1; // new deck
    viewController.viewDeckMode = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
