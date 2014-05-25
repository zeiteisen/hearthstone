//
//  ZEMyDecksViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 24.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEMyDecksViewController.h"
#import "ZEViewController.h"
#import "ZEPickClassViewController.h"

@interface ZEMyDecksViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ZEMyDecksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataSource = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY]];
    [self.tableView reloadData];
}

- (IBAction)newDeckTouched:(id)sender {
    ZEPickClassViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PickClassViewController"];
    vc.newDeckMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelgate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary *deck = self.dataSource[indexPath.row];
    if (deck[@"title"]) {
        cell.textLabel.text = deck[@"title"];
    } else {
        cell.textLabel.text = deck[@"hero"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *deck = self.dataSource[indexPath.row];
    ZEViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
    vc.hero = deck[@"hero"];
    vc.selectedDeckNumber = indexPath.row;
    vc.viewDeckMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
