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

    NSNumber *checkLong;
    NSString *formatString;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    checkLong = [formatter numberFromString:numberString];
    if (numberString.length <= 10 && numberString.length >= 13){
        if (checkLong != nil){
            return [self initWithNumber:checkLong];
        }else{
            formatString = [[numberString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
            if (checkLong!= nil){
                return [self initWithNumber:checkLong];
            }else{
                return nil;
            }
        }
    }else{
        return nil;
    }
    return self;
}

-(id)initWithNumber:(NSNumber*)numberValue{
    
    NSMutableString *formatString;
    
    if (numberValue.longValue <= 9999999999 && numberValue.longValue > 999999999){
        self.value = numberValue;
        self.unformattedNumber = [NSString stringWithFormat:@"%@",numberValue];
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
    self.value = nil;
    return self;
}


@end
