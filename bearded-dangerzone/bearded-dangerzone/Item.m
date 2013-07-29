//
//  Item.m
//  bearded-dangerzone
//
//  Created by Nicolas Ameghino on 7/28/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "Item.h"

@implementation Item

-(NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ %3.02f (%@)",
            self.type == kItemTypeIncome ? @"+" : @"-",
            [self.value floatValue],
            [self.tags componentsJoinedByString:@", "]];
}

-(NSDictionary*) descriptions {
    return @{
             @"textLabel": [NSString stringWithFormat:@"%@ %3.02f",
                            self.type == kItemTypeIncome ? @"+" : @"-",
                            [self.value floatValue]],
             @"detailTextLabel": [self.tags componentsJoinedByString:@", "]
    };
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.tags forKey:@"tags"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    [aCoder encodeObject:UIImageJPEGRepresentation(self.receiptImage, 0.8) forKey:@"receiptImage"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.tags = [aDecoder decodeObjectForKey:@"tags"];
        self.type = [[aDecoder decodeObjectForKey:@"type"] intValue];
        self.receiptImage = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"receiptImage"]];
    }
    return self;    
}

@end
