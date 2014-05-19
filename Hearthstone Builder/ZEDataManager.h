//
//  ZEDataManager.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZEDataManager : NSObject

+ (ZEDataManager *)sharedInstance;

@property (nonatomic, strong) NSArray *cards;

@end
