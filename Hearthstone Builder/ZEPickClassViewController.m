//
//  ZEPickClassViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 20.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPickClassViewController.h"
#import "ZEViewController.h"
#import "ZEOtherDecksTableViewController.h"
#import "ZEPickClassTableViewCell.h"

@interface ZEPickClassViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ZEPickClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataSource = [ZEUtility classNames];
    self.navigationItem.title = NSLocalizedString(@"Pick Class", nil);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    ZEPickClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.label.font = [ZEUtility myStandardFont];
    cell.label.text = self.dataSource[indexPath.row];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", self.dataSource[indexPath.row]];
    cell.image.image = [UIImage imageNamed:imageName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.newDeckMode) {
        ZEViewController *viewController = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
        viewController.hero = self.dataSource[indexPath.row];
        viewController.selectedDeckNumber = -1; // new deck
        viewController.viewDeckMode = NO;
        viewController.editable = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        ZEOtherDecksTableViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"OtherDecksTableViewController"];
        vc.hero = self.dataSource[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
