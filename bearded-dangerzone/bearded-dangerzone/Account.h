//
//  Account.h
//  bearded-dangerzone
//
//  Created by Nicolas Ameghino on 7/29/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Account : NSObject <NSCoding>
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSMutableArray *items;


+(Account*) loadDefaultSave;

-(void) addItem:(Item*) item;
-(float) calculateBalance;
-(NSSet*) tags;

@end
