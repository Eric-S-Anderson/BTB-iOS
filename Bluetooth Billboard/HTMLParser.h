//
//  HTMLParser.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 6/8/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This class is used to help determine whether or not a
//      string has html coding in it or not.

#import <Foundation/Foundation.h>
#import "NSString_stripHtml.h"

@interface HTMLParser : NSObject

@property BOOL HTML;
@property NSString *textOnlyMessage;
@property NSString *fullMessage;

-(id)initWithString:(NSString*)originalMessage;
-(id)init;

@end
