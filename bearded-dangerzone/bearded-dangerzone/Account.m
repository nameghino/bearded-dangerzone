//
//  Account.m
//  bearded-dangerzone
//
//  Created by Nicolas Ameghino on 7/29/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "Account.h"

#define DEFAULT_FILE @"default.account"

@implementation Account

- (id)init
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

-(float) calculateBalance {
    __block float balance = 0.0f;
    [self.items each:^(id sender) {
        Item *item = (Item*) sender;
        balance += item.type == kItemTypeIncome ? [item.value floatValue] : -[item.value floatValue];
    }];
    return balance;
}

-(void) addItem:(Item*) item {
    [self.items addObject:item];
    NSError *error = nil;
    if (![self save:&error]) {
        [UIAlertView showAlertViewWithTitle:@"Error saving"
                                    message:[error localizedDescription]
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil
                                    handler:NULL];
    }
}

-(BOOL) save:(NSError**) error {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSString *docsDir = [Utils applicationDocumentsDirectory];
    NSString *filePath = [docsDir stringByAppendingPathComponent:DEFAULT_FILE];
    BOOL retval = [data writeToFile:filePath atomically:YES];
    if (!retval) {
        char* errorMessage = strerror(errno);
        *error = [NSError errorWithDomain:@"account-domain-error"
                                     code:errno
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithCString:errorMessage
                                                                                          encoding:NSASCIIStringEncoding]}];
    }
    return retval;
    
}

+(Account*) loadDefaultSave {
    NSString *docsDir = [Utils applicationDocumentsDirectory];
    NSString *filePath = [docsDir stringByAppendingPathComponent:DEFAULT_FILE];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    Account *account = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return account;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.items forKey:@"items"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.items = [aDecoder decodeObjectForKey:@"items"];
    }
    return self;
}

@end
