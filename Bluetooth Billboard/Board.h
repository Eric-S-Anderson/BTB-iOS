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

@interface Board : NSObject

@property NSString *Ident;
@property NSString *Name;
@property NSString *Group;
@property NSString *Description;
@property NSMutableArray *Posts;
@property NSString *StatusFilter;

-(void)populate:(NSString*)ident statFilter:(NSString*)filter;
+(int)getQueryStatus;

@end
