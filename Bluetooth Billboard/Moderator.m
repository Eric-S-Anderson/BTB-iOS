//
//  Moderator.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/30/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "Moderator.h"

@implementation Moderator

+(NSString *)dynamoDBTableName{
    
    return [DynamoInformation getTableName];
}

+(NSString *)hashKeyAttribute{
    
    return [DynamoInformation getHashKey];
}

@end
