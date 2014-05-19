//
//  ZEPickedTableDataSource.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPickedTableDataSource.h"

@implementation ZEPickedTableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PickedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    NSDictionary *card = self.dataSource[indexPath.row];
//    NSNumber *mana = card[@"mana"];
    cell.textLabel.text = card[@"name"];
    cell.textLabel.frame = cell.bounds;
    return cell;
}

@end
