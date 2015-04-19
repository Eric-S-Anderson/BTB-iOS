//
//  Post.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 3/26/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#ifndef Bluetooth_Billboard_Post_h
#define Bluetooth_Billboard_Post_h

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "AppDelegate.h"

@interface Post : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property int Post_ID;
@property int Phone;
@property int End_Date;
@property NSString *Host;
@property NSString *Email;
@property NSString *Address;
@property NSString *Information;
@property NSString *Post_Type;
@property NSString *Post_Status;

-(void)populate:(int)ident;
+(void)setTableName:(NSString*)Name;
+(void)setHashKey:(NSString*)Key;
+(void)setCurrentBoard:(NSString*)newBoard;
+(NSString*)getCurrentBoard;
-(BOOL)isConnected;

@end


#endif
