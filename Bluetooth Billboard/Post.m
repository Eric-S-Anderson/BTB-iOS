//
//  Post.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 3/26/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "Post.h"

@implementation Post   

+(NSString *)dynamoDBTableName{
    
    return [DynamoInformation getTableName];
}

+(NSString *)hashKeyAttribute{
    
    return [DynamoInformation getHashKey];
}

@end