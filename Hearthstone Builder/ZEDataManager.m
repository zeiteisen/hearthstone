//
//  ZEDataManager.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 19.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEDataManager.h"

@implementation ZEDataManager

+ (ZEDataManager *)sharedInstance {
    static ZEDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZEDataManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *cardDataPath = [[NSBundle mainBundle] pathForResource:@"Cards" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:cardDataPath];
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        self.cards = dict[@"results"];
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        self.cards = [self.cards sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        if (error) {
            NSLog(@"error %@", error);
        }
    }
    return self;
}

@end
