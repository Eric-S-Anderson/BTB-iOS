//
//  ViewPostListScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen displays a list of posts to the user.

#import <UIKit/UIKit.h>
#import "ViewPostScreen.h"
#import "DynamoInterface.h"
#import "AppDelegate.h"
#import "HTMLParser.h"
#import "DeviceInterface.h"

@interface ViewPostListScreen : UIViewController <UITableViewDelegate, UITableViewDataSource>

@end
