//
//  Board.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This is a data class that holds information about an
//      electronic bulletin board.

#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Post.h"
#import "DynamoInformation.h"

@interface Board : AWSDynamoDBObjectModel

@property NSNumber *Board_ID;       //identification number (unique)
@property NSString *Board_Name;     //name of the board
@property NSString *Organization;   //organization that owns the board
@property NSNumber *Group_ID;       //group number
@property NSString *Instructions;   //instructions for posting on the board
@property NSNumber *Moderator_ID;   //moderator identification number
@property NSMutableArray *Posts;    //posts attached to the board

@end
