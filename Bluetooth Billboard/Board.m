//
//  Board.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "Board.h"

@implementation Board

+(NSString *)dynamoDBTableName{
    //return table name
    return [DynamoInformation getTableName];
}

+(NSString *)hashKeyAttribute{
    //return hash key
    return [DynamoInformation getHashKey];
}

@end
