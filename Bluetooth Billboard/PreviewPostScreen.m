//
//  PreviewPostScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/4/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "PreviewPostScreen.h"

@interface PreviewPostScreen ()

@property (weak, nonatomic) IBOutlet UILabel *lblHost;                  //host name
@property (weak, nonatomic) IBOutlet UITextView *txvAddress;            //address
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;             //phone number
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;             //e-mail address
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;        //post information
@property (weak, nonatomic) IBOutlet UIScrollView *scvDetails;          //scrollview that holds post details
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;               //submit button
@property (weak, nonatomic) IBOutlet UISwitch *swtVerify;               //verification switch
@property (weak, nonatomic) IBOutlet UISwitch *swtDetails;              //switch that toggles scrollview
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;   //activity indicator
- (IBAction)touchUpSubmit:(id)sender;           //called when submit button is pressed
- (IBAction)changeContact:(id)sender;           //called when details switch is changed

@end

@implementation PreviewPostScreen

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    [self.aivWaiting stopAnimating];
    //populate ui fields with the passed post
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

- (IBAction)touchUpSubmit:(id)sender {
    //submit the post to the database
    if (!self.swtVerify.on){    //if robot switch is not toggled
        //display alert box that robots cannot submit posts
        UIAlertView *botAlert = [[UIAlertView alloc] initWithTitle:@"Robot"
                                                           message:@"No Robots Allowed!"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [botAlert show];
    }else{
        //submit post to the database
        [DynamoInterface savePost:self.post];
        while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
        [self.aivWaiting stopAnimating];    //animate activity indicator while the database is querying
        if ([DynamoInterface getQueryStatus] == 0){ //query status complete
            //display sucessful submission alert box to the user
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Submitted"
                                                                message:@"Your post has been submitted for review.  A moderator will approve or deny your post, and notify you via the e-mail address you have entered."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }else{
            //display failure alert box to the user
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Not Submitted"
                                                                message:@"Could not connect to the database.  Please verify your internet conenction or try again later."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }
    }
}

- (IBAction)changeContact:(id)sender {
    //show or hide the scrollview containing extra post details
    if (self.swtDetails.on){
        self.scvDetails.hidden = false;
    }else{
        self.scvDetails.hidden = true;
    }
}
@end
