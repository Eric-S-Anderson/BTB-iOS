//
//  ViewQueueScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewQueueScreen.h"

@interface ViewQueueScreen ()

@property (weak, nonatomic) IBOutlet UILabel *lblHost;              //host name
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;         //phone number
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;         //e-mail address
@property (weak, nonatomic) IBOutlet UITextView *txvAddress;        //address
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;    //post information
@property (weak, nonatomic) IBOutlet UIScrollView *scvDetails;      //scrollview that holds details
@property (weak, nonatomic) IBOutlet UISwitch *swtDetails;          //switch that enables the scrollview
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;           //accept post button
@property (weak, nonatomic) IBOutlet UIButton *btnDeny;             //deny post button
- (IBAction)touchUpAccept:(id)sender;           //called when the accept button is pressed
- (IBAction)touchUpDeny:(id)sender;             //called when the deny button is pressed
- (IBAction)changeDetails:(id)sender;           //called when the details switch is changed
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;   //activity indicator

@end

@implementation ViewQueueScreen

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    [self.aivWaiting stopAnimating];
    //populate ui fields with the post information
    if (self.post != nil){  //check if post is empty
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
            [self.view addSubview:wbvInformation];          //add webview to the view controller
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

- (IBAction)touchUpAccept:(id)sender {
    //called when the accept button is pressed
    self.post.Post_Status = @"Posted";  //set post status
    //save post with new status
    [DynamoInterface savePost:self.post];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];    //show activity indicator while database is being queried
    //populate mail composer
    NSString *mesApproval = @"Your post has been approved!\n\n";
    MFMailComposeViewController *sendMe = [[MFMailComposeViewController alloc] init];
    [sendMe setMailComposeDelegate:self];
    //open mail composer if possible
    if ([MFMailComposeViewController canSendMail] && ![self.post.Email isEqualToString:@" "]) {
        [sendMe setToRecipients:[NSArray arrayWithObject:self.post.Email]];
        [sendMe setMessageBody:mesApproval isHTML:false];
        [sendMe setSubject:@"Your post has been approved!"];
        [self presentViewController:sendMe animated:YES completion:NULL];   //present the mail controller
    }
    
    self.lblHost.text = @"";        //reset text fields
    self.txvAddress.text = @"";
    self.txtPhone.text = @"";
    self.txtEmail.text = @"";
    self.txvInformation.text = @"";
}

- (IBAction)touchUpDeny:(id)sender {
    //called when the deny button is pressed
    self.post.Post_Status = @"Denied";  //set post status
    //save post with new status
    [DynamoInterface savePost:self.post];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];    //show activity indicator while database is being queried
    //populate mail composer
    NSString *mesDenial = @"Your post has been denied!\n\n";
    MFMailComposeViewController *sendMe = [[MFMailComposeViewController alloc] init];
    [sendMe setMailComposeDelegate:self];
    //open mail composer if possible
    if ([MFMailComposeViewController canSendMail] && ![self.post.Email isEqualToString:@" "]) {
        [sendMe setToRecipients:[NSArray arrayWithObject:self.post.Email]];
        [sendMe setMessageBody:mesDenial isHTML:false];
        [sendMe setSubject:@"Your post has been denied!"];
        [self presentViewController:sendMe animated:YES completion:NULL];   //present the mail controller
    }
    
    self.lblHost.text = @"";        //reset text fields
    self.txvAddress.text = @"";
    self.txtPhone.text = @"";
    self.txtEmail.text = @"";
    self.txvInformation.text = @"";
}

- (IBAction)changeDetails:(id)sender {
    //show or hide the scrollview containing extra post details
    if (self.swtDetails.on){
        self.scvDetails.hidden = false;
    }else{
        self.scvDetails.hidden = true;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    //called when mail composer finishes
    if(error) { //report mail composer error
        NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    }
    switch (result){    //report mail composer results
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];   //dismiss the mail controller
    return;
}
@end
