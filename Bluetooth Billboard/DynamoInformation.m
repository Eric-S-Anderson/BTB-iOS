//
//  DynamoInformation.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "DynamoInformation.h"

@implementation DynamoInformation

NSString *TableName;
NSString *HashKey;

+(NSString *)getTableName{
    
    return TableName;
}

+(NSString *)getHashKey{
    
    return HashKey;
}

+(void)setTableName:(NSString*)Name{
    TableName = Name;
}

+(void)setHashKey:(NSString*)Key{
    HashKey = Key;
}

@end
