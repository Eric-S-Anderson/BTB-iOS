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

-(id)init{
    
    self.Post_ID = -1;
    self.End_Date = -1;
    self.Phone = -1;
    self.Host = nil;
    self.Address = nil;
    self.Post_Status = nil;
    self.Post_Type = nil;
    self.Email = nil;
    self.Information = nil;
    return self;
}

@end