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
    
    return [DynamoInformation getTableName];
}

+(NSString *)hashKeyAttribute{
    
    return [DynamoInformation getHashKey];
}

@end
