//
//  ViewSavedPostScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/14/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This view controller is responsible for displaying a previously
//      saved post to the user.

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DynamoInterface.h"
#import "HTMLParser.h"
#import "DeviceInterface.h"

@interface ViewSavedPostScreen : UIViewController <UIWebViewDelegate>

@property Post *post;   //post that the user will view

@end
