//
//  DynamoInterface.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "DynamoInterface.h"

@implementation DynamoInterface
                                    //status code for database queries  -1 = querying   0 = success
int queryStatus;                        //  1 = error   2 = exception   3 = no internet connection
bool connection = false;        //state of the device's internet connection
NSString *TableName;            //name of the current table being queried
NSString *HashKey;              //name of the hash-key attribute for the table being queried
NSString *currentBoard;         //name of the current board
Board *fullBoard;               //the current board

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

+(BOOL)getConnection{
    //return conection status
    return connection;
}

+(BOOL)isConnected{
    //return whether device has an internet connection
    NSURL *connectivityTester = [NSURL URLWithString:@"http://www.google.com"];
    NSData *resultData = [NSData dataWithContentsOfURL:connectivityTester];
    if (resultData){
        //connection to google was made
        NSLog(@"Device is connected to the internet");
        connection = true;
        return true;
    }else{
        //connection was not made
        NSLog(@"Device is not connected to the internet");
        connection = false;
        //display an alert box to the user informing them that they have no internet connection
        UIAlertView *conAlert = [[UIAlertView alloc] initWithTitle:@"Not Connected"
                                                            message:@"Could not connect to the database.  Please verify your internet conenction or try again later."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [conAlert show];
        return false;
    }
}

+(NSMutableArray*)getAllBoardInformation{
    //returns an array of boards, with fully populated information
    //aws credentials
    AWSCognitoCredentialsProvider *credentials = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    //aws service configuration
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentials];
    //aws service manager
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //aws scan expression
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @10;
    //set table name and key
    TableName = @"Board";
    HashKey = @"Board_ID";
    //initialize array and query status
    NSMutableArray *boardList = [[NSMutableArray alloc] init];
    queryStatus = -1;           //reset query status
    NSLog(@"Waiting for database reponse...");
    //test connection
    if (self.isConnected){  //device is connected
        //initiate scan of board table
        [[dynamoDBObjectMapper scan:[Board class] expression:scanExpression]
         continueWithSuccessBlock:^id(BFTask *task){
             if (task.error){
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 queryStatus = 1;   //error code
             }
             if (task.exception){
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
                 queryStatus = 2;   //exception code
             }
             if (task.result){
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (Board *buffer in paginatedOutput.items) {
                     [boardList addObject:buffer];   //store each result
                 }
                 queryStatus = 0;   //success code
                 NSLog(@"Scan Sucessful");
             }
             return nil;
         }];
    }else{  //device not connected
        queryStatus = 3;
    }
    return boardList;
}

+(Board*)getSingleBoardInformation:(int)ident{
    //returns a populated board
    //aws credentials
    AWSCognitoCredentialsProvider *credentials = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    //aws service configuration
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentials];
    //aws service manager
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //initialize board and query status
    Board *fillBoard = [Board new];
    TableName = @"Board";    //set table name and key
    HashKey = @"Board_ID";
    NSNumber *recasted = [NSNumber numberWithInt:(ident)];
    fillBoard.Posts = [[NSMutableArray alloc] init];     //initialize storage array
    queryStatus = -1;           //reset query status
    NSLog(@"Waiting for database reponse...");
    //test connection
    if (self.isConnected){  //device is connected
        //initiate query
        [[dynamoDBObjectMapper load:[Board class] hashKey:recasted rangeKey:nil]
         continueWithBlock:^id(BFTask *task){
             if (task.error){
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 queryStatus = 1;   //error code
             }
             if (task.exception){
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
                 queryStatus = 2;   //exception code
             }
             if (task.result){
                 //populate board with result
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
    }else{  //device not connected
        queryStatus = 3;
    }
    return fillBoard;
}

+(Post*)getSinglePost:(int)ident{
    //returns a single populated post
    //aws credentials
    AWSCognitoCredentialsProvider *credentials = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    //aws service configuration
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentials];
    //aws service manager
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //initialize post and query status
    Post *checkPost = [Post new];
    HashKey = @"Post_ID";
    NSNumber *recasted = [NSNumber numberWithInt:(ident)];
    queryStatus = -1;           //reset query status
    NSLog(@"Waiting for database reponse...");
    //test connection
    if (self.isConnected){  //device is connected
        //initiate query
        [[dynamoDBObjectMapper load:[Post class] hashKey:recasted rangeKey:nil]
         continueWithBlock:^id(BFTask *task){
             if (task.error){
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 queryStatus = 1;   //error code
             }
             if (task.exception){
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
                 queryStatus = 2;   //exception code
             }
             if (task.result){
                 //populate post from result
                 Post *bufferPost = task.result;
                 checkPost.Post_ID = bufferPost.Post_ID;
                 checkPost.Phone = bufferPost.Phone;
                 checkPost.End_Date = bufferPost.End_Date;
                 checkPost.Host = bufferPost.Host;
                 checkPost.Email = bufferPost.Email;
                 checkPost.Address = bufferPost.Address;
                 checkPost.Information = bufferPost.Information;
                 checkPost.Post_Type = bufferPost.Post_Type;
                 checkPost.Post_Status = bufferPost.Post_Status;
                 queryStatus = 0;   //success code
                 NSLog(@"Query Sucessful");
             }
             return nil;
         }];
    }else{  //device not connected
        queryStatus = 3;
    }
    return checkPost;
}

+(Board*)getFilteredPosts:(NSString *)ident statFilter:(NSString*)filter{
    //return all posts on a board using the filter
    //aws credentials
    AWSCognitoCredentialsProvider *credentials = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    //aws service configuration
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentials];
    //aws service manager
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //aws scan expression
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    //scanExpression.limit = @10;
    //initialize and set filter
    if (filter != nil){
        //set the scan expression's filter if there is one
        AWSDynamoDBCondition *condition = [AWSDynamoDBCondition new];
        AWSDynamoDBAttributeValue *attribute = [AWSDynamoDBAttributeValue new];
        attribute.S = filter;
        condition.attributeValueList = @[attribute];
        condition.comparisonOperator = AWSDynamoDBComparisonOperatorEQ;
        scanExpression.scanFilter = @{@"Post_Status": condition};
    }
    //initialize board and query status
    NSString *brdBlank = @"Board";      //create proper board name
    if ([ident isEqualToString:@"0"]){
        //hard coded tutorial board identification
        ident = @"000000";
    }
    NSString *fullBoardID = [brdBlank stringByAppendingString:(ident)];
    TableName = fullBoardID;    //set table name and key
    HashKey = @"Post_ID";
    Board *fillBoard = [Board new];
    fillBoard.Posts = [[NSMutableArray alloc] init];     //initialize storage array
    queryStatus = -1;           //reset query status
    NSLog(@"Waiting for database reponse...");
    //test connection
    if (self.isConnected){  //device is connected
        //initiate scane
        [[dynamoDBObjectMapper scan:[Post class] expression:scanExpression]
         continueWithSuccessBlock:^id(BFTask *task){
             if (task.error){
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 queryStatus = 1;   //error code
             }
             if (task.exception){
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
                 queryStatus = 2;   //exception code
             }
             if (task.result){
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (Post *post in paginatedOutput.items) {
                     [fillBoard.Posts addObject:post];   //store each result
                 }
                 queryStatus = 0;   //success code
                 NSLog(@"Scan successful");
             }
             return nil;
         }];
    }else{  //device not connected
        queryStatus = 3;
    }
    return fillBoard;
}

+(void)savePost:(Post*)toBeSaved{
    //save a post to the database
    //make sure optional fields are not empty
    if ([toBeSaved.Address isEqualToString:@""]){
        toBeSaved.Address = @" ";
    }
    if ([toBeSaved.Email isEqualToString:@""]){
        toBeSaved.Email = @" ";
    }
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [DynamoInterface setHashKey:@"Post_ID"];
    //set query status
    queryStatus = -1;
    NSLog(@"Waiting for database reponse...");
    //test connection
    if (self.isConnected){  //device is connected
        //initiate save
        [[dynamoDBObjectMapper save:toBeSaved] continueWithBlock:^id(BFTask *task){
            if (task.error){
                queryStatus = 1;    //error code
                NSLog(@"The request failed. Error: [%@]", task.error);
            }
            if (task.exception){
                queryStatus = 2;    //exception code
                NSLog(@"The request failed. Exception: [%@]", task.exception);
            }
            if (task.result){
                queryStatus = 0;   //success code
                NSLog(@"Save successful");
            }
            return nil;
        }];
    }else{  //device not connected
        queryStatus = 3;
    }
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
}

+(void)deletePost:(Post*)toBeDeleted{
    //remove a post from the database
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [DynamoInterface setHashKey:@"Post_ID"];
    //set query status
    queryStatus = -1;
    NSLog(@"Waiting for database reponse...");
    //test connection
    if (self.isConnected){  //device is connected
        //initiate removal
        [[dynamoDBObjectMapper remove:toBeDeleted] continueWithBlock:^id(BFTask *task){
            if (task.error){
                queryStatus = 1;    //error code
                NSLog(@"The request failed. Error: [%@]", task.error);
            }
            if (task.exception){
                queryStatus = 2;    //exception code
                NSLog(@"The request failed. Exception: [%@]", task.exception);
            }
            if (task.result){
                queryStatus = 0;   //success code
                NSLog(@"Deletion successful");
            }
            return nil;
        }];
    }else{  //device not connected
        queryStatus = 3;
    }
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
}

+(void)removeOutdated{
    //removes outdated posts from the current board
    //initialzations
    Board *checkBoard = [Board new];
    NSDate *today = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //get current board posts
    checkBoard = [DynamoInterface getFilteredPosts:[DynamoInterface getCurrentBoard] statFilter:nil];
    while ([DynamoInterface getQueryStatus] < 0) {}
    //check posts
    for (int i = 0; i < checkBoard.Posts.count; i++){
        //delete post if their end date is earlier than today
        Post *currentPost = [checkBoard.Posts objectAtIndex:i];
        NSString *dateString = [NSString stringWithFormat:@"%@", currentPost.End_Date];
        if (dateString.length == 7){    //aws dynamo db removes leading zeroes
            //add the leading zero back into date string
            dateString = [@"0" stringByAppendingString:dateString];
        }
        //reconstitute a NSDate from separate string values
        NSDateComponents *dPieces = [[NSDateComponents alloc] init];
        [dPieces setMonth:[[dateString substringWithRange:NSMakeRange (0,2)] intValue]];
        [dPieces setDay:[[dateString substringWithRange:NSMakeRange (2,2)] intValue]];
        [dPieces setYear:[[dateString substringWithRange:NSMakeRange (4,4)] intValue]];
        NSDate *postDate = [[NSCalendar currentCalendar] dateFromComponents:dPieces];
        //compare end date to today's date, tracking number of days different
        NSUInteger unitFlags = NSCalendarUnitDay;
        NSDateComponents *components = [gregorian components:unitFlags
                                            fromDate:today toDate:postDate options:0];
        NSInteger days = [components day];
        //if end dateis less than zero days from today or the post has been previously denied
        if (days < 0 || [currentPost.Post_Status isEqualToString:@"Denied"]){
            //delete the post from the database
            [DynamoInterface deletePost:currentPost];
        }
    }
}

+(BOOL)verifyCredentials:(NSString *)User pWord:(NSString *)Pass{
    //return boolean indicating moderator verification
    //initializations
    BOOL verified = false;
    Moderator *aMod = [Moderator new];
    //get moderator id from current board
    NSString *recasted = [NSString stringWithFormat:@"%@",fullBoard.Moderator_ID];
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //set table name and query status
    TableName = @"Moderator";    //set table name and key
    HashKey = @"Moderator_ID";
    queryStatus = -1;
    NSLog(@"Waiting for database reponse...");
    //test connection
    if (self.isConnected){  //device is connected
    //initiate query
    [[dynamoDBObjectMapper load:[Moderator class] hashKey:recasted rangeKey:nil]
     continueWithBlock:^id(BFTask *task){
         if (task.error){
             queryStatus = 1;    //error code
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception){
             queryStatus = 2;    //exception code
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result){
             Moderator *bMod = task.result;
             aMod.Moderator_ID = bMod.Moderator_ID;
             aMod.Username = bMod.Username;
             aMod.Password = bMod.Password;
             queryStatus = 0;   //success code
             NSLog(@"Query successful");
         }
         return nil;
     }];
    }else{  //device not connected
        queryStatus = 3;
    }
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
    //test moderator credentials
    if ([aMod.Username isEqualToString:User] && [aMod.Password isEqualToString:Pass]){
        verified = true;    //credentials match
        NSLog(@"Username and password verified");
    }else{
        verified = false;   //credentials dont match
        NSLog(@"Invalid username and/or password");
    }
    return verified;
}

@end
