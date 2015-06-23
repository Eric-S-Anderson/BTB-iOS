//
//  ViewSavedPostScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/14/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewSavedPostScreen.h"

@interface ViewSavedPostScreen ()
@property (weak, nonatomic) IBOutlet UILabel *lblHost;          //label that will display the host name
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;     //text field that will hold a phone number
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;     //text field that will hold an e-mail address
@property (weak, nonatomic) IBOutlet UITextView *txvAddress;    //text view that will hold an address
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;       //button that will delete the post
@property (weak, nonatomic) IBOutlet UIScrollView *scvDetails;  //contains the phone, e-mail and address
@property (weak, nonatomic) IBOutlet UISwitch *swtDetails;      //shows/hides the details scroll view
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;    //text view that holds the post details
- (IBAction)touchUpDelete:(id)sender;           //called when delete button is pushed
- (IBAction)changeDetails:(id)sender;           //called when detail switch is pressed

@end

@implementation ViewSavedPostScreen

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

- (IBAction)touchUpDelete:(id)sender {
    //delete the post being viewed from the device's memory
    [DeviceInterface deletePost:self.post];
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
