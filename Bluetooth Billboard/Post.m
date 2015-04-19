//
//  Post.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 3/26/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@implementation Post

NSString *TableName;
NSString *HashKey;
NSString *currentBoard = @"213411";

+(void)setTableName:(NSString*)Name{
    TableName = Name;
}

+(void)setHashKey:(NSString*)Key{
    HashKey = Key;
}

+(NSString *)dynamoDBTableName{
    
    return TableName;
}

+(NSString *)hashKeyAttribute {
    
    return HashKey;
}

+(void)setCurrentBoard:(NSString*)newBoard{
    currentBoard = newBoard;
    NSLog(@"Current board set to %@", currentBoard);
}

+(NSString *)getCurrentBoard{
    return currentBoard;
}

-(BOOL)isConnected{
    //return whether device has an internet connection
    NSURL *connectivityTester = [NSURL URLWithString:@"http://www.google.com"];
    NSData *resultData = [NSData dataWithContentsOfURL:connectivityTester];
    if (resultData){
        NSLog(@"Device is connected to the internet");
        return true;
    }else{
        NSLog(@"Device is not connected to the internet");
        return false;
    }
}

-(void)populate:(int)ident{
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    
   AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    NSNumber *recasted = [NSNumber numberWithInt:(ident)];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    
    [[dynamoDBObjectMapper load:[Post class] hashKey:recasted rangeKey:nil]
     continueWithBlock:^id(BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             Post *post = task.result;
             //Do something with the result.
             self.Host = post.Host;
             self.Post_ID = post.Post_ID;
             //self.Board_ID = post.Board_ID;
             self.Phone = post.Phone;
             self.End_Date = post.End_Date;
             self.Email = post.Email;
             self.Address = post.Address;
             self.Information = post.Information;
             self.Post_Type = post.Post_Type;
             self.Post_Status = post.Post_Status;
         }
         return nil;
     }];

}
    
    

@end