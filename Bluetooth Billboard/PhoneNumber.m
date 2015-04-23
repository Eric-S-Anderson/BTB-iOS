//
//  PhoneNumber.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "PhoneNumber.h"

@implementation PhoneNumber


-(id)initWithString:(NSString*)numberString{

    long checkLong;
    NSString *formatString;
    
    if (numberString.length <= 10 && numberString.length >= 13){
        if ((checkLong = [numberString longLongValue]) != 0){
            return [self initWithLong:checkLong];
        }else{
            formatString = [[numberString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
            if ((checkLong = [formatString longLongValue]) != 0){
                return [self initWithLong:checkLong];
            }else{
                return nil;
            }
        }
    }else{
        return nil;
    }
    return self;
}

-(id)initWithLong:(long)numberValue{
    
    NSMutableString *formatString;
    
    if (numberValue <= 9999999999 && numberValue > 999999999){
        self.value = numberValue;
        self.unformattedNumber = [NSString stringWithFormat:@"%ld",numberValue];
        formatString = [NSMutableString stringWithString:self.unformattedNumber];
        [formatString insertString:@"(" atIndex:0];
        [formatString insertString:@")" atIndex:3];
        [formatString insertString:@"-" atIndex:7];
        self.formattedNumber = formatString;
        return self;
    }else{
        return nil;
    }
}

-(id)init{
    
    self.formattedNumber = nil;
    self.unformattedNumber = nil;
    self.value = -1;
    return self;
}


@end
