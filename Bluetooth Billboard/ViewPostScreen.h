//
//  ViewPostScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Post.h"
#import "AppDelegate.h"
#import "DynamoInterface.h"
#import "HTMLParser.h"
#import "DeviceInterface.h"

@interface ViewPostScreen : UIViewController <UIWebViewDelegate>

@property Post *post;


@end
