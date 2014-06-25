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

+ (NSDictionary *)toastOptionsWithText:(NSString *)saveText {
    NSDictionary *options = @{
                              kCRToastTextKey : saveText,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor grayColor],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionBottom),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastFontKey : [ZEUtility myStandardFont],
                              kCRToastTimeIntervalKey : @(0.3),
                              kCRToastTextColorKey : [UIColor blackColor]
                              };
    return options;
}

@end
