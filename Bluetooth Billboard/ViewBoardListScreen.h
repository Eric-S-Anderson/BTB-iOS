//
//  ViewBoardListScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "Board.h"

@interface ViewBoardListScreen : UIViewController <CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property CBCentralManager *myCentralManager;

@end
