//
//  ViewSavedPostScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/14/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DynamoInterface.h"
#import "HTMLParser.h"

@interface ViewSavedPostScreen : UIViewController <UIWebViewDelegate>

@property Post *post;

@end
