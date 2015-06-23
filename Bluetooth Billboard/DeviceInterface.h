//
//  DeviceInterface.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 6/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Board.h"
#import "Post.h"
#import "AppDelegate.h"
#import "DynamoInterface.h"

@interface DeviceInterface : NSObject

+(void)saveBoard:(Board*)saveMe;
+(void)savePost:(Post*)saveMe;
+(void)deleteBoard:(Board*)endMe;
+(void)deletePost:(Post*)endMe;
+(NSMutableArray*)getBoards;
+(NSMutableArray*)getPosts;

@end
