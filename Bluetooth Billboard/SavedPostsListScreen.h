//
//  SavedPostsListScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen will display a list of previously saved posts
//      to the user.

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Post.h"
#import "ViewSavedPostScreen.h"
#import "HTMLParser.h"
#import "DeviceInterface.h"

@interface SavedPostsListScreen : UIViewController <UITableViewDelegate, UITableViewDataSource>

@end
