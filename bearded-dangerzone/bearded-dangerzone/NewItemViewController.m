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

static NSString* kItemTagSeparator = @",";

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
@property (nonatomic, strong) UIImage *receiptSnapshot;

@property (nonatomic, strong) NSSet *tags;

@end

static NSDateFormatter* dateFormatter;
static NSDictionary* menuItemsAndMethods;

@implementation NewItemViewController

+(void)load {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    menuItemsAndMethods = @{
                            @"item list": NSStringFromSelector(@selector(showItemList:))
                            };
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
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"done"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(dismissKeyboard:)];
        toolbar.items = @[doneItem];
        [toolbar sizeToFit];
        inputAccessoryToolbar = toolbar;
    });
    return inputAccessoryToolbar;
}

-(void) setup {
    Account *a = [Account loadDefaultSave] ? : [[Account alloc] init];
    self.account = a;
    self.tags = [a tags];
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
    item.tags = [[self.itemTagsTextField.text componentsSeparatedByString:kItemTagSeparator] map:^id(id obj) {
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
    self.tags = [self.account tags];
}

-(void) addExpense:(id) sender { [self addItemWithType:kItemTypeExpense]; }
-(void) addIncome:(id) sender { [self addItemWithType:kItemTypeIncome]; }

-(void) snapReceiptPicture:(id) sender {
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        [UIAlertView showAlertViewWithTitle:@"error"
                                    message:@"no camera"
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil handler:NULL];
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePicker.delegate = self;

    [self presentViewController:imagePicker
                       animated:YES
                     completion:NULL];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIView *accessoryToolbar = [self accessoryToolbar];
    for (UITextField* tf in @[self.itemValueTextField, self.itemDateTextField]) {
        tf.inputAccessoryView = accessoryToolbar;
    }
    
    [self.itemTagsTextField setAutocompleteWithDataSource:self
                                                 delegate:self
                                                customize:^(ACEAutocompleteInputView *inputView) {
                                                    inputView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                                                }];
    
    [self.addExpenseButton addTarget:self
                              action:@selector(addExpense:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [self.addIncomeButton addTarget:self
                              action:@selector(addIncome:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [self.snapReceiptButton addTarget:self
                               action:@selector(snapReceiptPicture:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.itemTagsTextField addTarget:self
                               action:@selector(suggestTags:)
                     forControlEvents:UIControlEventEditingChanged];
    
    [self.moreOptionsButton addTarget:self
                               action:@selector(showActionMenu:)
                     forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self resetForm:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showActionMenu:(id) sender {
    UIActionSheet *menu = [UIActionSheet actionSheetWithTitle:@"menu"];
    [menu setCancelButtonWithTitle:@"cancel" handler:NULL];
    for (NSString *menuKey in [[menuItemsAndMethods allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        [menu addButtonWithTitle:menuKey handler:^{
            SEL selector = NSSelectorFromString(menuItemsAndMethods[menuKey]);
            [self performSelector:selector withObject:nil];
        }];
    }
    [menu showInView:self.view];
}

#pragma mark - Menu actions
-(void) showItemList:(id) sender {
    AccountItemsViewController *aivc = [[AccountItemsViewController alloc] initWithStyle:UITableViewStylePlain];
    aivc.account = self.account;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aivc];
    [self presentViewController:nav animated:YES completion:NULL];
    return;
}

#pragma mark - Image picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.receiptSnapshot = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - tags text field did change
-(void) suggestTags:(id) sender {
}

#pragma mark - ACEAutocompleteDataSource
-(NSUInteger)minimumCharactersToTrigger:(ACEAutocompleteInputView *)inputView { return 0; }

-(void)inputView:(ACEAutocompleteInputView *)inputView itemsFor:(NSString *)query result:(void (^)(NSArray *))resultBlock {
    
    NSString *text = [[query componentsSeparatedByString:@","] lastObject];
    NSSet *suggestedTags = [self.tags select:^BOOL(id obj) {
        NSString *tag = obj;
        return [tag hasPrefix:text];
    }];
    resultBlock([suggestedTags allObjects]);
}

-(CGFloat)inputView:(ACEAutocompleteInputView *)inputView widthForObject:(id)object {
    NSString *string = object;
    CGSize size = [string sizeWithAttributes:@{NSFontAttributeName: inputView.font}];
    return size.width + 40.0f;
}

-(void)inputView:(ACEAutocompleteInputView *)inputView setObject:(id)object forView:(UIView *)view {
    UILabel *label = (UILabel*)[view viewWithTag:102];
    label.text = object;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 12;
    label.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
}

#pragma mark - ACEAutocompleteDelegate
-(void)textField:(UITextField *)textField didSelectObject:(id)object inInputView:(ACEAutocompleteInputView *)inputView {
    NSMutableArray *tags = [[[textField.text componentsSeparatedByString:kItemTagSeparator] map:^id(id obj) {
        return [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }] mutableCopy];
    
    [tags removeLastObject];
    [tags addObject:object];
    
    textField.text = [[tags componentsJoinedByString:kItemTagSeparator] stringByAppendingString:kItemTagSeparator];
}

@end
