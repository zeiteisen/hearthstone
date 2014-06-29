//
//  ZEUtility.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 20.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEUtility.h"
#import "CRToast.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation ZEUtility

+ (id)instanciateViewControllerFromStoryboardIdentifier:(NSString *)identifier; {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    return [storyBoard instantiateViewControllerWithIdentifier:identifier];
}

+ (UIFont *)myStandardFont {
    return [UIFont fontWithName:@"BelweBT-Bold" size:17];
}

+ (NSMutableArray *)removeDuplicatesFrom:(NSArray *)duplicates {
    NSSet *set = [NSSet setWithArray:duplicates];
    return [[set allObjects] mutableCopy];
}

+ (UIColor *)colorForQuality:(NSString *)quality {
    if ([quality isEqualToString:@"legendary"]) {
        return [ZEUtility legendaryColor];
    } else if ([quality isEqualToString:@"epic"]) {
         return [ZEUtility epicColor];
    } else if ([quality isEqualToString:@"rare"]) {
        return [ZEUtility rareColor];
    } else if ([quality isEqualToString:@"common"]) {
        return [ZEUtility commonColor];
    } else {
        return [ZEUtility basicColor];
    }
}

+ (UIColor *)legendaryColor {
    return UIColorFromRGB(0xe9591f);
}

+ (UIColor *)epicColor {
    return UIColorFromRGB(0x9b24e9);
}

+ (UIColor *)rareColor {
    return UIColorFromRGB(0x1879f3);
}

+ (UIColor *)commonColor {
    return UIColorFromRGB(0x19a329);
}

+ (UIColor *)basicColor {
    return [UIColor blackColor];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
    [alert show];
}

+ (BOOL)remoteNotificationEnabled {
#ifdef __IPHONE_8_0
    UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    return notificationSettings.types != UIUserNotificationTypeNone;
#else
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    return types != UIRemoteNotificationTypeNone;
#endif
}

+ (void)registerForRemoteNotifications {
#ifdef __IPHONE_8_0
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
#endif
}

static BOOL toastVisible = NO;
+ (void)showToastWithText:(NSString *)text duration:(CGFloat)duration {
    if (!toastVisible) {
        NSDictionary *options = @{
                                  kCRToastTextKey : text,
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [UIColor grayColor],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionBottom),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                  kCRToastFontKey : [ZEUtility myStandardFont],
                                  kCRToastTimeIntervalKey : @(duration),
                                  kCRToastTextColorKey : [UIColor blackColor]
                                  };
        toastVisible = YES;
        [CRToastManager showNotificationWithOptions:options completionBlock:^{
            toastVisible = NO;
        }];
    }
}

+ (NSMutableArray *)cardDataFromCardNames:(NSArray *)cardNames fromDataBase:(NSArray *)allCards {
    NSMutableArray *cardData = [NSMutableArray array];
    for (NSString *cardName in cardNames) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", cardName];
        NSArray *searchResults = [allCards filteredArrayUsingPredicate:predicate];
        
        if (searchResults.count > 0) {
            [cardData addObject:searchResults[0]];
        }
    }
    return cardData;
}

+ (NSUInteger)createDeckToUserDefaults:(NSDictionary *)deck {
    NSMutableArray *decks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY] mutableCopy];
    if (decks == nil) {
        decks = [NSMutableArray array];
    }
    [decks addObject:deck];
    [[NSUserDefaults standardUserDefaults] setObject:decks forKey:USER_DECKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return decks.count - 1;
}

+ (NSMutableDictionary *)readDeckFromUserDefaultsAtIndex:(NSInteger)index {
    NSArray *decks = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY];
    NSAssert(decks.count > index, @"Userdefaults does not contain a deck at this index");
    return [decks[index] mutableCopy];
}

+ (void)updateDeckUserDefaults:(NSDictionary *)deck atIndex:(NSInteger)index {
    NSMutableArray *decks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY] mutableCopy];
    if (decks == nil) {
        [ZEUtility createDeckToUserDefaults:deck];
    } else {
        NSAssert(decks.count > index, @"Userdefaults does not contain a deck at this index");
        [decks replaceObjectAtIndex:index withObject:deck];
        [[NSUserDefaults standardUserDefaults] setObject:decks forKey:USER_DECKS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)deleteDeckUserDefaultsAtIndex:(NSInteger)index {
    NSMutableArray *decks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY] mutableCopy];
    NSAssert(decks.count > index, @"Userdefaults does not contain a deck at this index");
    [decks removeObjectAtIndex:index];
    [[NSUserDefaults standardUserDefaults] setObject:decks forKey:USER_DECKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)classNames {
    return @[@"warrior", @"shaman", @"rogue", @"paladin", @"hunter", @"druid", @"warlock", @"mage", @"priest"];
}

@end
