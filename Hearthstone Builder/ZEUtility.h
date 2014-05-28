//
//  ZEUtility.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 20.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZEUtility : NSObject

+ (id)instanciateViewControllerFromStoryboardIdentifier:(NSString *)identifier;
+ (UIFont *)myStandardFont;
+ (NSMutableArray *)removeDuplicatesFrom:(NSArray *)duplicates;

@end
