//
//  ViewBoardListScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen will display a list of boards that have been
//      found using the app delegates beacon scanning.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DynamoInterface.h"
#import "ViewPostListScreen.h"
#import "DeviceInterface.h"

@interface ViewBoardListScreen : UIViewController <UITableViewDelegate, UITableViewDataSource>

@end
