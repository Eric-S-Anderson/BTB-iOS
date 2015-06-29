//
//  HTMLParser.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 6/8/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "HTMLParser.h"

@implementation HTMLParser

-(id)initWithString:(NSString*)originalMessage{
    //initialize HTML parsed string with another string
    self.fullMessage = originalMessage;
    self.textOnlyMessage = [originalMessage stripHtml]; //strip out HTML
    //test if there is a difference between the strings
    if (![self.fullMessage isEqualToString:self.textOnlyMessage]){  //there is a difference
        self.HTML = true;
    }else{  //no difference
        self.HTML = false;
    }
    return self;
}

-(id)init{
    //initialize empty HTML string
    self.HTML = false;
    self.fullMessage = nil;
    self.textOnlyMessage = nil;
    return self;
}

@end
