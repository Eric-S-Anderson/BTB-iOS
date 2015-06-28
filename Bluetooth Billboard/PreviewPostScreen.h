//
//  PreviewPostScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/4/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//
//  This screen will display the viewable version of a user's
//      post to the user.

#import <UIKit/UIKit.h>
#import "DynamoInterface.h"
#import "HTMLParser.h"

@interface PreviewPostScreen : UIViewController <UIWebViewDelegate>

@property Post *post;   //post that will be view by the user

@end
