//
//  PreviewPostScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/4/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "PreviewPostScreen.h"

@interface PreviewPostScreen ()
@property (weak, nonatomic) IBOutlet UILabel *lblHost;
@property (weak, nonatomic) IBOutlet UITextView *txvAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;
@property (weak, nonatomic) IBOutlet UIScrollView *scvDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UISwitch *swtVerify;
@property (weak, nonatomic) IBOutlet UISwitch *swtDetails;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;
- (IBAction)touchUpSubmit:(id)sender;
- (IBAction)changeContact:(id)sender;

@end

@implementation PreviewPostScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.aivWaiting stopAnimating];
    
    //populate ui fields with the passed post
    if (self.post != nil){
        self.lblHost.text = self.post.Host;
        self.txvAddress.text = self.post.Address;
        if (self.post.Phone != NULL){
        self.txtPhone.text = [NSString stringWithFormat:@"%@",self.post.Phone];
        }
        self.txtEmail.text = self.post.Email;
        self.txvInformation.text = self.post.Information;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.scvDetails.contentSize = CGSizeMake(240, 250);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)touchUpSubmit:(id)sender {
    
    //submit the already populated post to the db
    
    if (!self.swtVerify.on){
        UIAlertView *botAlert = [[UIAlertView alloc] initWithTitle:@"Robot"
                                                           message:@"No Robots Allowed!"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [botAlert show];
    }else{
        [DynamoInterface savePost:self.post];
        while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
        [self.aivWaiting stopAnimating];
        if ([DynamoInterface getQueryStatus] == 0){
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Submitted"
                                                                message:@"Your post has been submitted for review.  A moderator will approve or deny your post, and notify you via the e-mail address you have entered."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }else{
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
    if (self.swtDetails.on){
        self.scvDetails.hidden = false;
    }else{
        self.scvDetails.hidden = true;
    }
}
@end
