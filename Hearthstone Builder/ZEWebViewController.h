//
//  ZEWebViewController.h
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 30.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZEWebViewController : UIViewController
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end
