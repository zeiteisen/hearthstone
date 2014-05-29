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
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (UIFont *)myStandardFont;
+ (NSMutableArray *)removeDuplicatesFrom:(NSArray *)duplicates;
+ (UIColor *)legendaryColor;
+ (UIColor *)epicColor;
+ (UIColor *)rareColor;
+ (UIColor *)commonColor;
+ (UIColor *)basicColor;

@end
