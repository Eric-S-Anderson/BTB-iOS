//
//  Post.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 3/26/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>
#import "DynamoInformation.h"

@interface Post : AWSDynamoDBObjectModel 

@property NSNumber *Post_ID;
@property NSNumber *Phone;
@property NSNumber *End_Date;
@property NSString *Host;
@property NSString *Email;
@property NSString *Address;
@property NSString *Information;
@property NSString *Post_Type;
@property NSString *Post_Status;

@end

