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
    return self.deckDataWithoutDuplicates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PickedCell";
    ZEPickedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.label.font = [UIFont fontWithName:cell.label.font.fontName size:8];
    NSDictionary *card = self.deckDataWithoutDuplicates[indexPath.row];
    NSString *cardName = card[@"name"];
    if ([self.countedDataSource countForObject:card] > 1) {
        cell.label.text = [NSString stringWithFormat:@"%@ x2", cardName];
    } else {
        cell.label.text = cardName;
    }
    NSString *set = card[@"set"];
    if ([set isEqualToString:@"basic"]) {
        cell.label.textColor = [ZEUtility basicColor];
    } else {
        cell.label.textColor = [ZEUtility colorForQuality:card[@"quality"]];
    }
    return cell;
}

@end
