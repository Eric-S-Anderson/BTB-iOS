//
//  PostScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen allows the user to submit a post to the database.

#import <UIKit/UIKit.h>
#import <stdlib.h>
#import "DynamoInterface.h"
#import "PreviewPostScreen.h"
#import "PhoneNumber.h"

@interface PostScreen : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, 
UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>

@end
