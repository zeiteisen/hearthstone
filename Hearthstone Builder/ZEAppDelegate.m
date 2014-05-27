//
//  ZEAppDelegate.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 12.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEAppDelegate.h"
#import "Chartboost.h"

@interface ZEAppDelegate () <ChartboostDelegate>

@end

@implementation ZEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"z7byvGtx1x90ufW3Ee2bJQKMv7AVr8HEMMepLPtH"
                  clientKey:@"GaGNnHc5akAJUikiySh9IIhTAqjSzwyA9E19hn1t"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFUser enableAutomaticUser];
    [[UILabel appearance] setFont:[ZEUtility myStandardFont]];
    NSDictionary *settings = @{
                               NSFontAttributeName: [ZEUtility myStandardFont],
                               };
    [[UIBarButtonItem appearance] setTitleTextAttributes:settings forState:UIControlStateNormal];
    
    return YES;
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
    
    // Begin a user session. Must not be dependent on user actions or any prior network requests.
    // Must be called every time your app becomes active.
    [Chartboost startWithAppId:@"5384461ec26ee46801e11ff4" appSignature:@"d2bc16f712a2343ee958d4f41676a609a5e595bc" delegate:self];
    [[Chartboost sharedChartboost] cacheInterstitial:CBLocationLevelStart];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - ChartboostDelegate

- (void)didDismissInterstitial:(CBLocation)location {
    [[Chartboost sharedChartboost] cacheInterstitial:CBLocationLevelStart];
}

@end
