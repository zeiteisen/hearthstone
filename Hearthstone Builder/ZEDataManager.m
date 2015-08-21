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
        NSArray *basicCards = dict[@"Basic"];
        NSArray *classic = dict[@"Classic"];
        NSArray *gvgCards = dict[@"Goblins vs Gnomes"];
        NSArray *naxxramas = dict[@"Curse of Naxxramas"];
        NSArray *blackrockCards = dict[@"Blackrock Mountain"];
        NSArray *tgtCards = dict[@"The Grand Tournament"];
        NSMutableArray *merge = [NSMutableArray array];
        [merge addObjectsFromArray:basicCards];
        [merge addObjectsFromArray:classic];
        [merge addObjectsFromArray:naxxramas];
        [merge addObjectsFromArray:gvgCards];
        [merge addObjectsFromArray:blackrockCards];
        [merge addObjectsFromArray:tgtCards];
        NSMutableArray *onlyCollectibles = [NSMutableArray array];
        
        for (NSDictionary *card in merge) {
            if (card[@"collectible"] != nil) {
                NSNumber *collectible = card[@"collectible"];
                NSString *type = card[@"type"];
                if (collectible.boolValue) {
                    if (type != nil && ![type isEqualToString:@"Hero"]) {
                        [onlyCollectibles addObject:card];
                    }
                }
            }
        }
        self.cards = onlyCollectibles;
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        self.cards = [self.cards sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        if (error) {
            NSLog(@"error %@", error);
        }
    }
    return self;
}

@end
