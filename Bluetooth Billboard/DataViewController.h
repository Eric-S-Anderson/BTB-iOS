//
//  DataViewController.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 3/25/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DataViewController : UIViewController

@property (strong,nonatomic) IBOutlet UILabel *dataLabel;
@property (strong,nonatomic) id dataObject;
@property CBCentralManager *myCentralManager;

@end

