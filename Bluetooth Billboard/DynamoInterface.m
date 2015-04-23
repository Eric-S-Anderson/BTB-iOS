//
//  DynamoInterface.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "DynamoInterface.h"

@implementation DynamoInterface

int queryStatus;
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

+(NSString *)hashKeyAttribute{
    
    return HashKey;
}

+(void)setCurrentBoard:(NSString*)newBoard{
    currentBoard = newBoard;
    NSLog(@"Current board set to %@", currentBoard);
}

+(NSString *)getCurrentBoard{
    return currentBoard;
}

+(int)getQueryStatus{
    //return status code for the query
    return queryStatus;
}

+(BOOL)isConnected{
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

+(NSMutableArray*)getAllBoardInformation:(NSMutableArray*)emptyList{
    
    //aws credentials
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //aws scan expression
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @10;
    
    TableName = @"Board";    //set table name and key
    HashKey = @"Board_ID";
    
    queryStatus = -1;           //reset query status
    
    if (self.isConnected){
        [[dynamoDBObjectMapper scan:[Board class] expression:scanExpression]
         continueWithSuccessBlock:^id(BFTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 queryStatus = 1;   //error code
             }
             if (task.exception) {
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
                 queryStatus = 2;   //exception code
             }
             if (task.result) {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (Board *buffer in paginatedOutput.items) {
                     [emptyList addObject:buffer];   //store each result
                 }
                 queryStatus = 0;   //success code
                 NSLog(@"Scan Sucessful");
             }
             return nil;
         }];
    }else{
        queryStatus = 3;
    }
    return emptyList;
}

+(Board*)getSingleBoardInformation:(int)ident{
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    Board *fillBoard = [Board new];
    
    TableName = @"Board";    //set table name and key
    HashKey = @"Board_ID";
    
    NSNumber *recasted = [NSNumber numberWithInt:(ident)];
    fillBoard.Posts = [[NSMutableArray alloc] init];     //initialize storage array
    queryStatus = -1;           //reset query status
    
    if (self.isConnected){
        [[dynamoDBObjectMapper load:[Board class] hashKey:recasted rangeKey:nil]
         continueWithBlock:^id(BFTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 queryStatus = 1;   //error code
             }
             if (task.exception) {
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
                 queryStatus = 2;   //exception code
             }
             if (task.result) {
                 Board *bufferBoard = task.result;
                 fillBoard.Instructions = bufferBoard.Instructions;
                 fillBoard.Board_ID = bufferBoard.Board_ID;
                 fillBoard.Board_Name = bufferBoard.Board_Name;
                 fillBoard.Group_ID = bufferBoard.Group_ID;
                 fillBoard.Organization = bufferBoard.Organization;
                 fillBoard.Moderator_ID = bufferBoard.Moderator_ID;
                 queryStatus = 0;   //success code
                 NSLog(@"Query Sucessful");
             }
             return nil;
         }];
    }else{
        queryStatus = 3;
    }
    return fillBoard;
}

+(Board*)getFilteredPosts:(NSString *)ident statFilter:(NSString*)filter{
    //aws credentials
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //aws scan expression
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @10;
    
    if (filter != nil){
        //set the scan expression's filter if there is one
        AWSDynamoDBCondition *condition = [AWSDynamoDBCondition new];
        AWSDynamoDBAttributeValue *attribute = [AWSDynamoDBAttributeValue new];
        attribute.S = filter;
        condition.attributeValueList = @[attribute];
        condition.comparisonOperator = AWSDynamoDBComparisonOperatorEQ;
        scanExpression.scanFilter = @{@"Post_Status": condition};
    }
    
    NSString *brdBlank = @"Board";      //create proper board name
    NSString *fullBoardID = [brdBlank stringByAppendingString:(ident)];
    TableName = fullBoardID;    //set table name and key
    HashKey = @"Post_ID";
    
    Board *fillBoard = [Board new];
    
    fillBoard.Posts = [[NSMutableArray alloc] init];     //initialize storage array
    queryStatus = -1;           //reset query status
    
    if (self.isConnected){
        [[dynamoDBObjectMapper scan:[Post class] expression:scanExpression]
         continueWithSuccessBlock:^id(BFTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 queryStatus = 1;   //error code
             }
             if (task.exception) {
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
                 queryStatus = 2;   //exception code
             }
             if (task.result) {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (Post *post in paginatedOutput.items) {
                     [fillBoard.Posts addObject:post];   //store each result
                 }
                 queryStatus = 0;   //success code
                 NSLog(@"Scan Sucessful");
             }
             return nil;
         }];
    }else{
        queryStatus = 3;
    }
    return fillBoard;
}

+(void)savePost:(Post*)toBeSaved{
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper save:toBeSaved]
     continueWithBlock:^id(BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             //Do something with the result.
         }
         return nil;
     }];
}

@end