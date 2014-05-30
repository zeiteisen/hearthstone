//
//  ZEWebViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 30.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEWebViewController.h"
#import "UINavigationController+M13ProgressViewBar.h"

@interface ZEWebViewController () <UIWebViewDelegate>

@end

@implementation ZEWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    self.webView.delegate = self;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.navigationController showProgress];
    [self.navigationController setIndeterminate:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.navigationController finishProgress];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.navigationController finishProgress];
    NSLog(@"error %@", error);
}

@end
