//
//  ViewQueueScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewQueueScreen.h"

@interface ViewQueueScreen ()
@property (weak, nonatomic) IBOutlet UITextField *txtHost;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnDeny;
- (IBAction)touchUpAccept:(id)sender;
- (IBAction)touchUpDeny:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;

@end

@implementation ViewQueueScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.aivWaiting stopAnimating];
    
    if (self.post != nil){
        self.txtHost.text = self.post.Host;
        self.txtAddress.text = self.post.Address;
        self.txtPhone.text = [NSString stringWithFormat:@"%@",self.post.Phone];
        self.txtEmail.text = self.post.Email;
        self.txtDate.text = [NSString stringWithFormat:@"%@",self.post.End_Date];
        self.txvInformation.text = self.post.Information;
    }
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

- (IBAction)touchUpAccept:(id)sender {
    
    self.post.Post_Status = @"Posted";
    
    [DynamoInterface savePost:self.post];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];
    
    NSString *mesApproval = @"Your post has been approved!\n\n";
    
    MFMailComposeViewController *sendMe = [[MFMailComposeViewController alloc] init];
    [sendMe setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        [sendMe setToRecipients:[NSArray arrayWithObject:self.post.Email]];
        [sendMe setMessageBody:mesApproval isHTML:false];
        [sendMe setSubject:@"Your post has been approved!"];
        [self presentViewController:sendMe animated:YES completion:NULL];
    }
    
    self.txtHost.text = @"";
    self.txtAddress.text = @"";
    self.txtPhone.text = @"";
    self.txtEmail.text = @"";
    self.txtDate.text = @"";
    self.txvInformation.text = @"";
}

- (IBAction)touchUpDeny:(id)sender {
    
    self.post.Post_Status = @"Denied";
    
    [DynamoInterface savePost:self.post];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];
    
    NSString *mesDenial = @"Your post has been denied!\n\n";
    
    MFMailComposeViewController *sendMe = [[MFMailComposeViewController alloc] init];
    [sendMe setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        [sendMe setToRecipients:[NSArray arrayWithObject:self.post.Email]];
        [sendMe setMessageBody:mesDenial isHTML:false];
        [sendMe setSubject:@"Your post has been denied!"];
        [self presentViewController:sendMe animated:YES completion:NULL];
    }
    
    self.txtHost.text = @"";
    self.txtAddress.text = @"";
    self.txtPhone.text = @"";
    self.txtEmail.text = @"";
    self.txtDate.text = @"";
    self.txvInformation.text = @"";
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    if(error) {
        NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    }
    switch (result)
    {
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
    [self dismissViewControllerAnimated:YES completion:NULL];

    return;
}
@end
