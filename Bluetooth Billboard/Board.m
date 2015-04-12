//
//  Board.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "Board.h"

@implementation Board

int queryStatus;
NSString *TableName;
NSString *HashKey;
NSString *currentBoard;

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

+(int)getQueryStatus{
    //return status code for the query
    return queryStatus;
}

-(void)getBoardData:(int)ident{
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    TableName = @"Board";    //set table name and key
    HashKey = @"Board_ID";

    NSNumber *recasted = [NSNumber numberWithInt:(ident)];
    self.Posts = [[NSMutableArray alloc] init];     //initialize storage array
    queryStatus = -1;           //reset query status
    
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
             self.Instructions = bufferBoard.Instructions;
             self.Board_ID = bufferBoard.Board_ID;
             self.Board_Name = bufferBoard.Board_Name;
             self.Group_ID = bufferBoard.Group_ID;
             self.Organization = bufferBoard.Organization;
             self.Moderator_ID = bufferBoard.Moderator_ID;
             queryStatus = 0;   //success code
         }
         return nil;
     }];
}

-(void)populate:(NSString *)ident statFilter:(NSString*)filter{
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
    [Post setTableName:fullBoardID];    //set table name and key
    [Post setHashKey:@"Post_ID"];
    self.Posts = [[NSMutableArray alloc] init];     //initialize storage array
    queryStatus = -1;           //reset query status
    
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
                 [self.Posts addObject:post];   //store each result
             }
             queryStatus = 0;   //success code
         }
         return nil;
     }];
    
    
}


@end
