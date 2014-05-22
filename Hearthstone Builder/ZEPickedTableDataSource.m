//
//  ZEPickedTableDataSource.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPickedTableDataSource.h"
#import "ZEPickedTableViewCell.h"

@implementation ZEPickedTableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PickedCell";
    ZEPickedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary *card = self.dataSource[indexPath.row];
    cell.label.text = card[@"name"];
    return cell;
}

@end
