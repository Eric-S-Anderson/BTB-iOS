//
//  Moderator.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/30/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>
#import "DynamoInformation.h"

@interface Moderator : AWSDynamoDBObjectModel

@property NSString *Moderator_ID;       //identification number (unique)
@property NSString *Username;           //user name
@property NSString *Password;           //password

@end
