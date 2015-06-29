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

@property NSNumber *Post_ID;        //identification number (unique to board)
@property NSNumber *Phone;          //phone number (optional)
@property NSNumber *End_Date;       //end date (default = 90 days from today)
@property NSString *Host;           //host name
@property NSString *Email;          //e-mail address (optional)
@property NSString *Address;        //address (optional)
@property NSString *Information;    //post information, actual message
@property NSString *Post_Type;      //type of post (predefined set)
@property NSString *Post_Status;    //status of post (posted, queued, denied)

@end

