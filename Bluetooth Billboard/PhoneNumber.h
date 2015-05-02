//
//  PhoneNumber.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneNumber : NSObject

@property NSString *formattedNumber;
@property NSString *unformattedNumber;
@property NSNumber *value;

-(id)initWithString:(NSString*)numberString;
-(id)initWithNumber:(NSNumber*)numberValue;
-(id)init;

@end
