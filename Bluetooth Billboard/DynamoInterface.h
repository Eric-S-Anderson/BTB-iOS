//
//  DynamoInterface.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "Board.h"
#import "Post.h"
#import "Moderator.h"
#import "AppDelegate.h"

@interface DynamoInterface : NSObject


+(void)setTableName:(NSString*)Name;
+(void)setHashKey:(NSString*)Key;
+(void)setCurrentBoard:(NSString*)newBoard;
+(Board*)getCurrentBoardInfo;
+(NSString*)getCurrentBoard;
+(int)getQueryStatus;
+(BOOL)getConnection;
+(BOOL)isConnected;
+(NSMutableArray*)getAllBoardInformation:(NSMutableArray*)emptyList;
+(Board*)getSingleBoardInformation:(int)ident;
+(Post*)getSinglePost:(int)ident;
+(Board*)getFilteredPosts:(NSString *)ident statFilter:(NSString*)filter;
+(void)savePost:(Post*)toBeSaved;
+(void)deletePost:(Post*)toBeDeleted;
+(void)removeOutdated;
+(BOOL)verifyCredentials:(NSString *)User pWord:(NSString *)Pass;

@end
