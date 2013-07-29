//
//  Item.h
//  bearded-dangerzone
//
//  Created by Nicolas Ameghino on 7/28/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kItemTypeExpense,
    kItemTypeIncome
} ItemType;



@interface Item : NSObject <NSCoding>

@property(nonatomic, strong) NSNumber* value;
@property(nonatomic, strong) NSDate* date;
@property(nonatomic, strong) NSArray* tags;
@property(nonatomic, strong) UIImage* receiptImage;

//TODO: replace with proper subclasses or whatever
@property(nonatomic, assign) ItemType type;

-(NSDictionary*) descriptions;

@end
