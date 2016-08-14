//
//  ZEAppDelegate.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 12.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEAppDelegate.h"
#import "iRate.h"
#import "AHKActionSheet.h"
#import <Crashlytics/Crashlytics.h>
#import <iAd/iAd.h>
#import "ZEViewController.h"
#import "UINavigationController+Progress.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ZEAppDelegate ()

@end

@implementation ZEAppDelegate

+ (void)initialize {
    [iRate sharedInstance].appStoreID = 882681595;
    [iRate sharedInstance].message = NSLocalizedString(@"Please take a moment to rate this app. Every feedback is well appreciated", nil);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.onlyPortrait = true;
    [Crashlytics startWithAPIKey:@"40327ff403daba0aa092e0b236cedc55fd536d77"];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"z7byvGtx1x90ufW3Ee2bJQKMv7AVr8HEMMepLPtH"
                  clientKey:@"GaGNnHc5akAJUikiySh9IIhTAqjSzwyA9E19hn1t"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFUser enableAutomaticUser];
    [UIViewController prepareInterstitialAds];
    
    UIFont *font = [ZEUtility myStandardFont];
    [[UILabel appearance] setFont:font];
    NSDictionary *settings = @{NSFontAttributeName: font};
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:settings];
    [[UIBarButtonItem appearance] setTitleTextAttributes:settings forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:settings];
    [[AHKActionSheet appearance] setButtonTextAttributes:settings];
    NSDictionary *cancelButtonSettings = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor redColor]};
    [[AHKActionSheet appearance] setCancelButtonTextAttributes:cancelButtonSettings];
    if ([ZEUtility remoteNotificationEnabled]) {
        [ZEUtility registerForRemoteNotifications];
    }
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did fail to register for remote notifications %@", error);
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"source %@", sourceApplication);
    NSLog(@"url %@", url);
    NSString *surl = url.absoluteString;
    surl = [surl stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    surl = [surl stringByReplacingOccurrencesOfString:@"hsdeck://graph.facebook.com/?al_applink_data=" withString:@""];
    NSData *data = [surl dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *targetURL = json[@"target_url"];
    NSArray *sep = [targetURL componentsSeparatedByString:@"="];
    if (sep.count >= 2) {
        NSString *objectId = sep[1];
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        [navigationController popToRootViewControllerAnimated:NO];
        PFObject *emptyObject = [PFObject objectWithoutDataWithClassName:@"Deck" objectId:objectId];
        [navigationController hb_showProgress];
        [emptyObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [navigationController hb_hideProgress];
            if (error) {
                NSLog(@"error %@", error);
            } else {
                ZEViewController *viewController = [ZEUtility instanciateViewControllerFromStoryboardIdentifier:@"CreateViewController"];
                viewController.hero = object[@"hero"];
                viewController.deckObject = object;
                viewController.editable = NO;
                viewController.viewDeckMode = YES;
                [navigationController pushViewController:viewController animated:YES];
            }
        }];
    }
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.onlyPortrait)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskLandscape;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].keyWindow.tintColor = [UIColor redColor];
    [FBSDKAppEvents activateApp];
    
    // Begin a user session. Must not be dependent on user actions or any prior network requests.
    // Must be called every time your app becomes active.
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
