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
+ (BOOL)remoteNotificationEnabled;
+ (void)registerForRemoteNotifications;
+ (void)showToastWithText:(NSString *)text duration:(CGFloat)duration;
+ (UIColor *)colorForQuality:(NSString *)quality;
+ (NSMutableArray *)cardDataFromCardNames:(NSArray *)cardNames fromDataBase:(NSArray *)allCards;
+ (NSArray *)classNames;

// CRUD userdefaults
+ (NSUInteger)createDeckToUserDefaults:(NSDictionary *)deck;
+ (NSMutableDictionary *)readDeckFromUserDefaultsAtIndex:(NSInteger)index;
+ (void)updateDeckUserDefaults:(NSDictionary *)deck atIndex:(NSInteger)index;
+ (void)deleteDeckUserDefaultsAtIndex:(NSInteger)index;

@end
