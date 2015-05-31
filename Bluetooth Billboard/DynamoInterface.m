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
NSString *currentBoard;
Board *fullBoard;

+(void)setTableName:(NSString*)Name{
    //set table name
    TableName = Name;
}

+(void)setHashKey:(NSString*)Key{
    //set hash key
    HashKey = Key;
}

+(NSString *)dynamoDBTableName{
    //return table name
    return TableName;
}

+(NSString *)hashKeyAttribute{
    //return hash key for a query/scan
    return HashKey;
}

+(void)setCurrentBoard:(NSString*)newBoard{
    //sets current board and gets info for it
    currentBoard = newBoard;
    NSLog(@"Current board set to %@", currentBoard);
    fullBoard = [DynamoInterface getSingleBoardInformation:[currentBoard intValue]];
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
}

+(Board *)getCurrentBoardInfo{
    //return curent board info
    return fullBoard;
}

+(NSString *)getCurrentBoard{
    //return current board name
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
        //connection to google was made
        NSLog(@"Device is connected to the internet");
        return true;
    }else{
        //connection was not made
        NSLog(@"Device is not connected to the internet");
        return false;
    }
}

+(NSMutableArray*)getAllBoardInformation:(NSMutableArray*)emptyList{
    
    //aws credentials
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    //aws service configuration
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    //aws service manager
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //aws scan expression
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @10;
    
    TableName = @"Board";    //set table name and key
    HashKey = @"Board_ID";
    
    queryStatus = -1;           //reset query status
    NSLog(@"Waiting for database reponse...");
    
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
    
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database

    return emptyList;
}

+(Board*)getSingleBoardInformation:(int)ident{
    
    //aws credentials
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
        initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    //aws service configuration
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    //aws service manager
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    Board *fillBoard = [Board new];
    TableName = @"Board";    //set table name and key
    HashKey = @"Board_ID";
    NSNumber *recasted = [NSNumber numberWithInt:(ident)];
    fillBoard.Posts = [[NSMutableArray alloc] init];     //initialize storage array
    
    queryStatus = -1;           //reset query status
    NSLog(@"Waiting for database reponse...");
    
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
    
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database

    return fillBoard;
}

+(Board*)getFilteredPosts:(NSString *)ident statFilter:(NSString*)filter{
    
    //aws credentials
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    //aws service configuration
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    //aws service manager
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
    NSLog(@"Waiting for database reponse...");
    
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
                 NSLog(@"Scan successful");
             }
             return nil;
         }];
    }else{
        queryStatus = 3;
    }
    
    //while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
    
    return fillBoard;
}

+(void)savePost:(Post*)toBeSaved{
    
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [DynamoInterface setHashKey:@"Post_ID"];
    queryStatus = -1;
    NSLog(@"Waiting for database reponse...");
    
    if (self.isConnected){
        [[dynamoDBObjectMapper save:toBeSaved] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                queryStatus = 1;    //error code
                NSLog(@"The request failed. Error: [%@]", task.error);
            }
            if (task.exception) {
                queryStatus = 2;    //exception code
                NSLog(@"The request failed. Exception: [%@]", task.exception);
            }
            if (task.result) {
                queryStatus = 0;   //success code
                NSLog(@"Save successful");
            }
            return nil;
        }];
    }else{
        queryStatus = 3;
    }
    
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database

}

+(void)deletePost:(Post*)toBeDeleted{
    
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [DynamoInterface setHashKey:@"Post_ID"];
    queryStatus = -1;
    NSLog(@"Waiting for database reponse...");
    
    if (self.isConnected){
        [[dynamoDBObjectMapper remove:toBeDeleted] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                queryStatus = 1;    //error code
                NSLog(@"The request failed. Error: [%@]", task.error);
            }
            if (task.exception) {
                queryStatus = 2;    //exception code
                NSLog(@"The request failed. Exception: [%@]", task.exception);
            }
            if (task.result) {
                queryStatus = 0;   //success code
                NSLog(@"Deletion successful");
            }
            return nil;
        }];
    }else{
        queryStatus = 3;
    }
    
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
}

+(void)removeOutdated{
    
    Board *checkBoard = [Board new];
    NSDate *today = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    checkBoard = [DynamoInterface getFilteredPosts:[DynamoInterface getCurrentBoard] statFilter:nil];
    while ([DynamoInterface getQueryStatus] < 0) {}
    
    for (int i = 0; i < checkBoard.Posts.count; i++){
        
        Post *currentPost = [checkBoard.Posts objectAtIndex:i];
        NSString *dateString = [NSString stringWithFormat:@"%@", currentPost.End_Date];
        if (dateString.length == 7){
            dateString = [@"0" stringByAppendingString:dateString];
        }
        NSDateComponents *dPieces = [[NSDateComponents alloc] init];
        [dPieces setMonth:[[dateString substringWithRange:NSMakeRange (0,2)] intValue]];
        [dPieces setDay:[[dateString substringWithRange:NSMakeRange (2,2)] intValue]];
        [dPieces setYear:[[dateString substringWithRange:NSMakeRange (4,4)] intValue]];
        NSDate *postDate = [[NSCalendar currentCalendar] dateFromComponents:dPieces];
        
        NSUInteger unitFlags = NSCalendarUnitDay;
        
        NSDateComponents *components = [gregorian components:unitFlags
                                                    fromDate:today
                                                      toDate:postDate options:0];
        NSInteger days = [components day];
        
        if (days < 0 || [currentPost.Post_Status isEqualToString:@"Denied"]){
            [DynamoInterface deletePost:currentPost];
        }
    }
}

+(BOOL)verifyCredentials:(NSString *)User pWord:(NSString *)Pass{
    
    BOOL verified = false;
    Moderator *aMod = [Moderator new];
    NSString *recasted = [NSString stringWithFormat:@"%@",fullBoard.Moderator_ID];
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    TableName = @"Moderator";    //set table name and key
    HashKey = @"Moderator_ID";
    queryStatus = -1;
    NSLog(@"Waiting for database reponse...");
    
    if (self.isConnected){
    [[dynamoDBObjectMapper load:[Moderator class] hashKey:recasted rangeKey:nil]
     continueWithBlock:^id(BFTask *task) {
         if (task.error) {
             queryStatus = 1;    //error code
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             queryStatus = 2;    //exception code
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             Moderator *bMod = task.result;
             aMod.Moderator_ID = bMod.Moderator_ID;
             aMod.Username = bMod.Username;
             aMod.Password = bMod.Password;
             queryStatus = 0;   //success code
             NSLog(@"Query successful");
         }
         return nil;
     }];
    }else{
        queryStatus = 3;
    }
    
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
    
    if ([aMod.Username isEqualToString:User] && [aMod.Password isEqualToString:Pass]){
        verified = true;
        NSLog(@"Username and password verified");
    }else{
        verified = false;
        NSLog(@"Invalid username and/or password");
    }
    
    return verified;
}

@end
