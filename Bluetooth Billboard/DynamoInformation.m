//
//  DynamoInformation.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "DynamoInformation.h"

@implementation DynamoInformation

NSString *TableName;    //current table name
NSString *HashKey;      //current hash key

+(NSString *)getTableName{
    //return table name
    return TableName;
}

+(NSString *)getHashKey{
    //return hash key
    return HashKey;
}

+(void)setTableName:(NSString*)Name{
    //set table name
    TableName = Name;
}

+(void)setHashKey:(NSString*)Key{
    //set hash key
    HashKey = Key;
}

@end
