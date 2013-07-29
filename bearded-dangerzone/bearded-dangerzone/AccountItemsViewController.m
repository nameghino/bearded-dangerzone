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

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"balance: $ %.02f", [self.account calculateBalance]];
}

@end
