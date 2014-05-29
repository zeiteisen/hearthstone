//
//  ZEFilterTableDataSource.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEFilterTableDataSource.h"
#import "ZELeftFilterTableViewCell.h"

@implementation ZEFilterTableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FilterCell";
    ZELeftFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.label.font = [ZEUtility myStandardFont];
    cell.label.font = [UIFont fontWithName:cell.label.font.fontName size:20];
    if (indexPath.row > 7) {
        cell.label.text = @"A";
    } else {
        cell.label.text = [NSString stringWithFormat:@"%li", (long)indexPath.row];
    }
    return cell;
}

@end
