//
//  Board.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "Post.h"

@interface Board : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property int Board_ID;
@property NSString *Board_Name;
@property NSString *Organization;
@property int Group_ID;
@property NSString *Instructions;
@property int Moderator_ID;
@property NSMutableArray *Posts;


-(void)getBoardData:(int)ident;
-(void)populate:(NSString*)ident statFilter:(NSString*)filter;
+(int)getQueryStatus;

@end
