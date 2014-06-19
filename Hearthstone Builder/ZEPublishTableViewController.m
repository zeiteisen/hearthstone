//
//  ZEPublishTableViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 25.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPublishTableViewController.h"
#import "UINavigationController+Progress.h"
#import "ZEPublishTitleTableViewCell.h"
#import "ZEPublishCardTableViewCell.h"

@interface ZEPublishTableViewController () <UITextFieldDelegate, ZEPublishCardTableViewCellDelegate>
@property (nonatomic, strong) NSMutableDictionary *deck;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ZEPublishTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.dataSource = [NSMutableArray array];
    NSMutableArray *titleData = [NSMutableArray array];
    NSMutableArray *cardData = [NSMutableArray array];
    [self.dataSource addObject:titleData];
    [self.dataSource addObject:cardData];
    
    // make titleData
    NSMutableDictionary *titleDict = [NSMutableDictionary dictionary];
    NSArray *decks = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY];
    self.deck = [decks[self.selectedDeckNumber] mutableCopy];
    NSString *title = self.deck[@"title"];
    NSString *hero = self.deck[@"hero"];
    if (title.length != 0 && ![title isEqualToString:hero]) {
        [titleDict setObject:title forKey:@"title"];
    } else {
        [titleDict setObject:NSLocalizedString(@"Your fancy deck name", nil) forKey:@"titlePlaceholder"];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [titleDict setObject:self.deck[@"dust"] forKey:@"dust"];
    [titleDict setObject:self.deck[@"minions"] forKey:@"minions"];
    [titleDict setObject:self.deck[@"spells"] forKey:@"spells"];
    [titleDict setObject:self.deck[@"weapons"] forKey:@"weapons"];
    [titleData addObject:titleDict];
    
    // make cardData
    NSArray *cardNames = [ZEUtility removeDuplicatesFrom:self.deck[@"deck"]];
    NSArray *cardDescriptions = self.deck[@"cardDescriptions"];
    for (NSString *cardName in cardNames) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:cardName forKey:@"name"];
        [dict setObject:[self getCardDescriptionFromCardName:cardName descriptions:cardDescriptions] forKey:@"description"];
        [cardData addObject:dict];
    }
    
    [self checkDeckCountToEnableUploadButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (NSString *)getCardDescriptionFromCardName:(NSString *)compareName descriptions:(NSArray *)descriptions {
    for (NSDictionary *dict in descriptions) {
        NSString *cardName = dict[@"name"];
        if ([cardName isEqualToString:compareName]) {
            return dict[@"description"];
        }
    }
    return @"";
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSString *title = self.deck[@"title"];
    if (title.length == 0) {
        self.deck[@"title"] = self.deck[@"hero"];
    }
    [self saveDeck];
}

- (void)saveDeck {
    NSArray *descriptions = self.dataSource[1];
    [self.deck setObject:descriptions forKey:@"cardDescriptions"];
    NSMutableArray *decks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY] mutableCopy];
    [decks replaceObjectAtIndex:self.selectedDeckNumber withObject:self.deck];
    [[NSUserDefaults standardUserDefaults] setObject:decks forKey:USER_DECKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkDeckCountToEnableUploadButton {
    NSArray *deckCardNames = self.deck[@"deck"];
    if (deckCardNames.count < 30) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - ZEPublishCardTableViewCellDelegate

- (void)publishCardTableViewDidEndEditing:(ZEPublishCardTableViewCell *)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSArray *data = self.dataSource[indexPath.section];
    NSMutableDictionary *dict = data[indexPath.row];
    [dict setObject:sender.descriptionTextView.text forKey:@"description"];
    [sender.descriptionTextView resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)titleTextFieldDidChange:(UITextField *)sender {
    if (sender.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [self checkDeckCountToEnableUploadButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.deck setValue:textField.text forKey:@"title"];
    [textField resignFirstResponder];
}

#pragma mark - TableViewDelegate & DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 142.;
    } else {
        return 165.;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataSource[section];
    return array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *titleIdentifier = @"TitleCell";
    static NSString *cardIdentifier = @"CardCell";
    NSArray *data = self.dataSource[indexPath.section];
    UITableViewCell<ZEUpdateCellProtocol> *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:titleIdentifier];
        ZEPublishTitleTableViewCell *foo = (ZEPublishTitleTableViewCell *)cell;
        foo.titleTextField.delegate = self;
        [foo.titleTextField addTarget:self action:@selector(titleTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cardIdentifier];
        ZEPublishCardTableViewCell *foo = (ZEPublishCardTableViewCell *)cell;
        foo.delegate = self;
    }
    [cell updateWithDict:data[indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Required", nil);
    } else {
        return NSLocalizedString(@"Optional", nil);
    }
}

#pragma mark - Actions

- (IBAction)publishTouched:(id)sender {
    PFObject *deckObject = [PFObject objectWithClassName:@"Deck"];
    if (self.deck[@"objectId"]) {
        deckObject = [PFObject objectWithoutDataWithClassName:@"Deck" objectId:self.deck[@"objectId"]];
    }
//    [deckObject setObject:self.titleTextField.text forKey:@"title"];
//    [deckObject setObject:self.descriptionTextView.text forKey:@"description"];
//    [deckObject setObject:self.deck[@"hero"] forKey:@"hero"];
//    [deckObject setObject:self.deck[@"deck"] forKey:@"deck"];
//    [deckObject setObject:self.deck[@"dust"] forKey:@"dust"];
//    [deckObject setObject:@1 forKey:@"views"];
//    [deckObject setObject:self.deck[@"weapons"] forKey:@"weapons"];
//    [deckObject setObject:self.deck[@"spells"] forKey:@"spells"];
//    [deckObject setObject:self.deck[@"minions"] forKey:@"minions"];
//    [self.navigationController hb_showProgress];
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    [deckObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//        [self.navigationController hb_hideProgress];
//        if (error) {
//            [ZEUtility showAlertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription];
//        } else {
//            [ZEUtility showAlertWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Upload succeeded", nil)];
//            [self.deck setObject:deckObject.objectId forKey:@"objectId"];
//            NSArray *array = [self.navigationController viewControllers];
//            [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
//            [self saveDeck];
//        }
//    }];
//    [self saveDeck];
}

@end
