//
//  AccountItemsViewController.h
//  bearded-dangerzone
//
//  Created by Nicolas Ameghino on 7/29/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "Item.h"

@interface AccountItemsViewController : UITableViewController
@property(nonatomic, weak) Account *account;
@end
