//
//  ViewPostScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewPostScreen.h"
#import "Post.h"

@interface ViewPostScreen ()

@property (weak, nonatomic) IBOutlet UILabel *lblHost;              //host name
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;         //phone number
@property (weak, nonatomic) IBOutlet UITextView *txvAddress;        //address
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;         //e-mail address
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;    //post information
@property (weak, nonatomic) IBOutlet UIScrollView *scvDetails;      //scrollview that holds post details
@property (weak, nonatomic) IBOutlet UISwitch *swtDetails;          //switch that toggles scrollview
@property (weak, nonatomic) IBOutlet UIButton *btnBlockHost;        //block host button
@property (weak, nonatomic) IBOutlet UIButton *btnBlockType;        //block type button
- (IBAction)touchUpBlockHost:(id)sender;        //called when block host button is pressed
- (IBAction)touchUpBlockType:(id)sender;        //called when block type button is pressed
- (IBAction)touchUpSave:(id)sender;             //called when save button is pressed
- (IBAction)changeDetails:(id)sender;           //called when details switch is toggled

@end

@implementation ViewPostScreen

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //populate ui fields with the post information
    if (self.post != nil){      //check if post is empty
        self.lblHost.text = self.post.Host;
        self.txvAddress.text = self.post.Address;
        if (self.post.Phone != NULL){
            self.txtPhone.text = [NSString stringWithFormat:@"%@",self.post.Phone];
        }
        self.txtEmail.text = self.post.Email;
        //check if the post details contain HTML
        HTMLParser *info = [[HTMLParser alloc] initWithString:self.post.Information];
        if (info.HTML){
            //if the post details have HTML, create a webview for displaying it
            UIWebView *wbvInformation = [[UIWebView alloc] initWithFrame:self.txvInformation.frame];
            wbvInformation.delegate=self;
            [wbvInformation loadHTMLString:self.post.Information baseURL:nil];
            [self.view addSubview:wbvInformation];      //add webview to the view controller
            [self.view bringSubviewToFront:self.scvDetails];    //bring webview to the front
        }else{
            self.txvInformation.text = self.post.Information;   //no HTML, display details in plain text
        }
        //set button titles to reflect current post information
        NSString *blkHost = [@"Block Host\n" stringByAppendingString:self.post.Host];
        NSString *blkType = [@"Block Type\n" stringByAppendingString:self.post.Post_Type];
        [self.btnBlockHost setTitle:(blkHost) forState:UIControlStateNormal];
        [self.btnBlockType setTitle:(blkType) forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    //called everytime the page appears
    [super viewDidAppear:animated];
    //set the size of the scrollview to allow scrolling
    self.scvDetails.contentSize = CGSizeMake(240, 250);
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    //ensure that links in the webview will open safari instead of navigating inside this application
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchUpBlockHost:(id)sender {
    //blocks the host from being listed in the view post list screen
    bool foundIT = false;
    NSMutableArray *banHosts = [[NSMutableArray alloc] init];
    NSString *blockHost = [NSString stringWithString:self.post.Host];
    //load currently blocked hosts
    banHosts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"]mutableCopy];
    //check if host is already blocked
    for (unsigned int i = 0; i < banHosts.count; i++){
        if ([banHosts objectAtIndex:i] == blockHost){
            foundIT = true;     //host is already blocked
        }
    }
    if (!foundIT){  //host not already blocked
        //add host to the block list
        [banHosts addObject:blockHost];
        NSLog(@"Host %@ has been banned", blockHost);
        //display alert box notifying the user that the host is now blocked
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Host Banned"
                                                            message:@"You have sucessfully banned this host. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [banAlert show];
    }else{      //host already blocked
        NSLog(@"Host was already banned");
        //display alert box notifying the user that the host was already blocked
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Host Already Banned"
                                                           message:@"This host was already banned. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [banAlert show];
    }
    //save block list
    [[NSUserDefaults standardUserDefaults] setObject:banHosts forKey:@"blockedHosts"];
}

- (IBAction)touchUpBlockType:(id)sender {
    //blocks the type from being listed in the view post list screen
    bool foundIT = false;
    NSMutableArray *banType = [[NSMutableArray alloc] init];
    NSString *blockType = [NSString stringWithString:self.post.Post_Type];
    //load currently blocked types
    banType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"]mutableCopy];
    //check if type is already blocked
    for (unsigned int i = 0; i < banType.count; i++){
        if ([banType objectAtIndex:i] == blockType){
            foundIT = true;     //type is already blocked
        }
    }
    if (!foundIT){  //type not already blocked
        //add type to the block list
        [banType addObject:blockType];
        NSLog(@"Type %@ has been banned", blockType);
        //display alert box notifying the user that the type is now blocked
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Type Banned"
                                                           message:@"You have sucessfully banned this type. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [banAlert show];
    }else{      //type already blocked
        NSLog(@"Type was already banned");
        //display alert box notifying the user that the type was already blocked
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Type Already Banned"
                                                           message:@"This type was already banned. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [banAlert show];
    }
    //save block list
    [[NSUserDefaults standardUserDefaults] setObject:banType forKey:@"blockedTypes"];
}

- (IBAction)touchUpSave:(id)sender {
    //save the post being viewed
    [DeviceInterface savePost:self.post];
}

- (IBAction)changeDetails:(id)sender {
    //show or hide the scrollview containing extra post details
    if (self.swtDetails.on){
        self.scvDetails.hidden = false;
    }else{
        self.scvDetails.hidden = true;
    }
}

@end
