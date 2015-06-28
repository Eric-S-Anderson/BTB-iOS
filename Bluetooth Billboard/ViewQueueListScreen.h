//
//  ViewQueueListScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen will display a list of queued posts to
//      the moderator.

#import <UIKit/UIKit.h>
#import "ViewQueueScreen.h"
#import "DynamoInterface.h"
#import "HTMLParser.h"

@interface ViewQueueListScreen : UIViewController <UITableViewDelegate, UITableViewDataSource>

@end
