//
//  AccountItemsViewController.m
//  bearded-dangerzone
//
//  Created by Nicolas Ameghino on 7/29/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "AccountItemsViewController.h"

@interface AccountItemsViewController ()

@end

@implementation AccountItemsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:NSClassFromString(@"UITableViewCell")
           forCellReuseIdentifier:@"AccountItemCell"];
    self.navigationItem.title = @"Item list";
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"done"
                                     style:UIBarButtonItemStylePlain
                                   handler:^(id sender) {
                                       [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
                                   }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.account.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Item* item = self.account.items[indexPath.row];
    
    NSDictionary *textStrings = [item descriptions];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", textStrings[@"textLabel"], textStrings[@"detailTextLabel"]];
    
    switch (item.type) {
        case kItemTypeExpense:
            cell.textLabel.textColor = [UIColor redColor];
            break;
        case kItemTypeIncome:
            cell.textLabel.textColor = [UIColor greenColor];
            break;
        default:
            cell.textLabel.textColor = [UIColor blackColor];
            break;
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { return YES; }

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        [self.account.items removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"balance: $ %.02f", [self.account calculateBalance]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Item *item = self.account.items[indexPath.row];
    if (item.receiptImage == nil) {
        UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"no image"];
        [alertView show];
        double delayInSeconds = 0.75f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        });
        return;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.userInteractionEnabled = YES;
    imageView.image = item.receiptImage;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
    
    [imageView addGestureRecognizer:tgr];
    UIViewController *imageViewController = [[UIViewController alloc] init];
    imageViewController.view = imageView;
    
    [self presentViewController:imageViewController animated:YES completion:NULL];

    
}

@end
