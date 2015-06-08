//
//  ViewQueueScreen.h
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "DynamoInterface.h"
#import "HTMLParser.h"

@interface ViewQueueScreen : UIViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate>

@property Post *post;

@end
