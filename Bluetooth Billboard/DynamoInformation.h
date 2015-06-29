//
//  DynamoInformation.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This class holds data for the daabase interface class.

#import <Foundation/Foundation.h>

@interface DynamoInformation : NSObject

+(NSString *)getTableName;
+(NSString *)getHashKey;
+(void)setTableName:(NSString*)Name;
+(void)setHashKey:(NSString*)Key;

@end
