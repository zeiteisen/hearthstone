//
//  ZEStartViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 24.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEStartViewController.h"
#import "ZEMyDecksViewController.h"
#import "ZEPickClassViewController.h"

@interface ZEStartViewController () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZEStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ZEMyDecksViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"MyDecksViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        ZEPickClassViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"PickClassViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
