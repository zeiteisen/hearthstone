//
//  ZEUpdateCellProtocol.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.06.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZEUpdateCellProtocol <NSObject>

- (void)updateWithDict:(NSDictionary *)dict;
- (void)editingMode:(BOOL)editingMode;

@end
