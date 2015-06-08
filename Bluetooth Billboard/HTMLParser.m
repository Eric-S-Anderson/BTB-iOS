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
    
    self.fullMessage = originalMessage;
    self.textOnlyMessage = [originalMessage stripHtml];
    if (![self.fullMessage isEqualToString:self.textOnlyMessage]){
        self.HTML = true;
    }else{
        self.HTML = false;
    }
    
    return self;
}

-(id)init{
    
    self.HTML = false;
    self.fullMessage = nil;
    self.textOnlyMessage = nil;
    return self;
}

@end
