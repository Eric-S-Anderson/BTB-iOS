//
//  SearchScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen will display a list of boards that match the
//      current search input.

#import <UIKit/UIKit.h>
#import "DynamoInterface.h"
#import "DeviceInterface.h"

@interface SearchScreen : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@end
