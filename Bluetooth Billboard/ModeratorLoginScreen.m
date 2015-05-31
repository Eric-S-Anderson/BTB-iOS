//
//  ModeratorLoginScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ModeratorLoginScreen.h"

@interface ModeratorLoginScreen ()
@property (weak, nonatomic) IBOutlet UITextField *txtUser;
@property (weak, nonatomic) IBOutlet UITextField *txtPass;
@property (weak, nonatomic) IBOutlet UISwitch *swtVerify;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UILabel *lblFailedAttempts;
- (IBAction)touchUpLogin:(id)sender;

@end

@implementation ModeratorLoginScreen

int failed = 0;
NSString *failStart = @"You have failed to login ";
NSString *failMEnd = @" times.";
NSString *failSEnd = @" time.";
NSString *tooMany = @"This login is no longer available.";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblFailedAttempts.text = failStart;
    self.lblFailedAttempts.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchUpLogin:(id)sender {
    
    /*********************Login Override********************/
    
    if ([self.txtUser.text isEqualToString:@"Admin"] && [self.txtPass.text isEqualToString:@"12345"]){
        [DynamoInterface removeOutdated];
        [self performSegueWithIdentifier:@"moderatorLoginSegue" sender:self.txtUser.text];
    }
    
    /**********************End Override*********************/
    NSLog(@"Failed attempts: %d", failed);
    if ([DynamoInterface verifyCredentials:self.txtUser.text pWord:self.txtPass.text] && self.swtVerify.on){
        [DynamoInterface removeOutdated];
        [self performSegueWithIdentifier:@"moderatorLoginSegue" sender:self.txtUser.text];
    }else{
        if (!self.swtVerify.on){
            UIAlertView *botAlert = [[UIAlertView alloc] initWithTitle:@"Robot"
                                                            message:@"No Robots Allowed!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [botAlert show];
        }else{
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Login"
                                                            message:@"The password or username you have entered is incorrect."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [saveAlert show];
        }
        failed++;
        if (failed == 1){
            self.lblFailedAttempts.text = [failStart stringByAppendingString:[[NSString stringWithFormat:@"%d",failed] stringByAppendingString:failSEnd]];
        }else if (failed < 5){
            self.lblFailedAttempts.text = [failStart stringByAppendingString:[[NSString stringWithFormat:@"%d",failed] stringByAppendingString:failMEnd]];
        }else{
            self.lblFailedAttempts.text = tooMany;
            self.btnLogin.enabled = false;
            self.btnLogin.hidden = true;
        }
        self.txtUser.text = @"";
        self.txtPass.text = @"";
        self.lblFailedAttempts.hidden = false;
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/


@end
