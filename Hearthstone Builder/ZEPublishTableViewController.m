//
//  ZEPublishTableViewController.m
//  Hearthstone Builder
//
//  Created by Hanno Bruns on 25.05.14.
//  Copyright (c) 2014 zeiteisens. All rights reserved.
//

#import "ZEPublishTableViewController.h"

@interface ZEPublishTableViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) NSMutableDictionary *deck;
@property (weak, nonatomic) IBOutlet UILabel *dustCount;
@property (weak, nonatomic) IBOutlet UILabel *minionsCount;
@property (weak, nonatomic) IBOutlet UILabel *spellsCount;
@property (weak, nonatomic) IBOutlet UILabel *weaponsCount;
@end

@implementation ZEPublishTableViewController

- (void)viewDidLoad
{
    NSArray *decks = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY];
    self.deck = [decks[self.selectedDeckNumber] mutableCopy];
    if (self.deck[@"title"]) {
        self.titleTextField.text = self.deck[@"title"];
    }
    if (self.deck[@"description"]) {
        self.descriptionTextView.text = self.deck[@"description"];
    }
    self.titleTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    self.titleTextField.font = [ZEUtility myStandardFont];
    self.descriptionTextView.font = [ZEUtility myStandardFont];
    
    self.dustCount.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Dust: ", nil), [self.deck[@"dust"] stringValue]];
    self.minionsCount.text = [NSString stringWithFormat:@"%@ %@", [self.deck[@"minions"] stringValue], NSLocalizedString(@"Minions", nil)];
    self.spellsCount.text = [NSString stringWithFormat:@"%@ %@", [self.deck[@"spells"] stringValue], NSLocalizedString(@"Spells", nil)];
    self.weaponsCount.text = [NSString stringWithFormat:@"%@ %@", [self.deck[@"weapons"] stringValue], NSLocalizedString(@"Weapons", nil)];
    
    [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self saveDeck];
}

- (void)saveDeck {
    NSMutableArray *decks = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DECKS_KEY] mutableCopy];
    [decks replaceObjectAtIndex:self.selectedDeckNumber withObject:self.deck];
    [[NSUserDefaults standardUserDefaults] setObject:decks forKey:USER_DECKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.deck setValue:textView.text forKey:@"description"];
    [textView resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.deck setValue:textField.text forKey:@"title"];
    [textField resignFirstResponder];
}

#pragma mark - Actions

- (IBAction)publishTouched:(id)sender {
    PFObject *deckObject = [PFObject objectWithClassName:@"Deck"];
    if (self.deck[@"objectId"]) {
        deckObject = [PFObject objectWithoutDataWithClassName:@"Deck" objectId:self.deck[@"objectId"]];
    }
    [deckObject setObject:self.titleTextField.text forKey:@"title"];
    [deckObject setObject:self.descriptionTextView.text forKey:@"description"];
    [deckObject setObject:self.deck[@"hero"] forKey:@"hero"];
    [deckObject setObject:self.deck[@"deck"] forKey:@"deck"];
    [deckObject setObject:self.deck[@"dust"] forKey:@"dust"];
    [deckObject setObject:self.deck[@"weapons"] forKey:@"weapons"];
    [deckObject setObject:self.deck[@"spells"] forKey:@"spells"];
    [deckObject setObject:self.deck[@"minions"] forKey:@"minions"];
    [deckObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.deck setObject:deckObject.objectId forKey:@"objectId"];
        [self saveDeck];
    }];
}

@end