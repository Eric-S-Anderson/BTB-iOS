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

@property NSNumber *Board_ID;
@property NSString *Board_Name;
@property NSString *Organization;
@property NSNumber *Group_ID;
@property NSString *Instructions;
@property NSNumber *Moderator_ID;
@property NSMutableArray *Posts;

@end
