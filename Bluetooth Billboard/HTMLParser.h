//
//  HTMLParser.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 6/8/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString_stripHtml.h"

@interface HTMLParser : NSObject

@property BOOL HTML;
@property NSString *textOnlyMessage;
@property NSString *fullMessage;

-(id)initWithString:(NSString*)originalMessage;
-(id)init;

@end
