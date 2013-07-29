//
//  NewItemViewController.m
//  bearded-dangerzone
//
//  Created by Nicolas Ameghino on 7/28/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "NewItemViewController.h"

#import "AccountItemsViewController.h"

#import "Account.h"
#import "Item.h"

@interface NewItemViewController ()
@property (strong, nonatomic) IBOutlet UIButton *addExpenseButton;
@property (strong, nonatomic) IBOutlet UIButton *addIncomeButton;
@property (strong, nonatomic) IBOutlet UITextField *itemValueTextField;
@property (strong, nonatomic) IBOutlet UITextField *itemDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *itemTagsTextField;
@property (strong, nonatomic) IBOutlet UIButton *selectAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *selectVenueButton;
@property (strong, nonatomic) IBOutlet UIButton *snapReceiptButton;
@property (strong, nonatomic) IBOutlet UIButton *moreOptionsButton;

@property (nonatomic, strong) Account *account;

@end

static NSDateFormatter* dateFormatter;
@implementation NewItemViewController

+(void)load {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
}

-(void) setNextResponder:(id) sender {
    NSArray *responderList = @[self.itemValueTextField, self.itemDateTextField, self.itemTagsTextField];
    for (int i=0; i < [responderList count]; ++i) {
        UIResponder *r = responderList[i];
        if ([r isFirstResponder]) {
            NSUInteger nextIndex = (i+1) % [responderList count];
            UIResponder *n = responderList[nextIndex];
            [r resignFirstResponder];
            [n becomeFirstResponder];
            return;
        }
    }
}

-(void) dismissKeyboard:(id) sender {
    NSArray *responderList = @[self.itemValueTextField, self.itemDateTextField, self.itemTagsTextField];
    [responderList each:^(id sender) {
        [sender resignFirstResponder];
    }];
}

static UIView* inputAccessoryToolbar;
-(UIView*) accessoryToolbar {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"next"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(setNextResponder:)];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"done"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismissKeyboard:)];
        toolbar.items = @[nextItem, spacer, doneItem];
        [toolbar sizeToFit];
        inputAccessoryToolbar = toolbar;
    });
    return inputAccessoryToolbar;
}

-(void) setup {
    Account *a = [Account loadDefaultSave] ? : [[Account alloc] init];
    self.account = a;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;

}

-(void) resetForm:(id) sender {
    self.itemTagsTextField.text = @"";
    self.itemValueTextField.text = @"";
    self.itemDateTextField.text = [dateFormatter stringFromDate:[NSDate date]];
}

-(void) addItemWithType:(ItemType) type {
    Item *item = [[Item alloc] init];
    item.type = type;
    item.date = [dateFormatter dateFromString:self.itemDateTextField.text];
    item.value = [NSNumber numberWithFloat:[self.itemValueTextField.text floatValue]];
    item.tags = [[self.itemTagsTextField.text componentsSeparatedByString:@","] map:^id(id obj) {
        return [[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]lowercaseString];
    }];
    [self.account addItem:item];
    [UIAlertView showAlertViewWithTitle:@"item added"
                                message:[NSString stringWithFormat:@"balance: $ %.02f", [self.account calculateBalance]]
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil
                                handler:NULL];
    [self resetForm:nil];
    [self dismissKeyboard:nil];
}

-(void) addExpense:(id) sender { [self addItemWithType:kItemTypeExpense]; }
-(void) addIncome:(id) sender { [self addItemWithType:kItemTypeIncome]; }

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UITextField* tf in @[self.itemValueTextField, self.itemDateTextField, self.itemTagsTextField]) {
        tf.inputAccessoryView = [self accessoryToolbar];
    }
    
    [self.addExpenseButton addTarget:self
                              action:@selector(addExpense:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [self.addIncomeButton addTarget:self
                              action:@selector(addIncome:)
                    forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated {
    [self resetForm:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showItemsListSegue"]) {
        UINavigationController *nav = [segue destinationViewController];
        AccountItemsViewController *aivc = nav.viewControllers[0];
        aivc.account = self.account;
        return;
    }
}

@end
