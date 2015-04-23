//
//  Board.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Post.h"
#import "DynamoInformation.h"

@interface Board : AWSDynamoDBObjectModel

@property int Board_ID;
@property NSString *Board_Name;
@property NSString *Organization;
@property int Group_ID;
@property NSString *Instructions;
@property int Moderator_ID;
@property NSMutableArray *Posts;

@end
