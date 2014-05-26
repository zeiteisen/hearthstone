//
//  ZEOtherDecksTableViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 25.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEOtherDecksTableViewController.h"
#import "ZEViewController.h"

@interface ZEOtherDecksTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ZEOtherDecksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"Deck"];
    [query whereKey:@"hero" equalTo:self.hero];
    [query orderByDescending:@"updatedAt"];
    [query selectKeys:@[@"title", @"likes"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.dataSource = [NSMutableArray arrayWithArray:objects];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.font = [ZEUtility myStandardFont];
    PFObject *deck = self.dataSource[indexPath.row];
    cell.textLabel.text = deck[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZEViewController *vc = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
    vc.hero = self.hero;
    vc.viewDeckMode = YES;
    vc.deckObject = self.dataSource[indexPath.row];
    [vc.deckObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"error %@", error);
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

@end
