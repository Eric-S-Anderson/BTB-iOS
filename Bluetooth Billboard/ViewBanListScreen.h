//
//  ViewBanListScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 5/29/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen will allow the user to view all of the types
//      and hosts that they have previously blocked, and to
//      unblock them if they so desire.

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DynamoInterface.h"

@interface ViewBanListScreen : UIViewController <UITableViewDelegate, UITableViewDataSource>

@end
