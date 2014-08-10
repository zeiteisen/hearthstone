//
//  ZENavigationController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 10.08.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZENavigationController.h"
#import <MessageUI/MessageUI.h>

@interface ZENavigationController ()

@end

@implementation ZENavigationController

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultSent) {
        [ZEUtility showToastWithText:NSLocalizedString(@"Email Sent", nil) duration:3];
    } else if (result == MFMailComposeResultFailed) {
        [ZEUtility showToastWithText:NSLocalizedString(@"Error while sending email", nil) duration:3];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
