//
//  ModeratorLoginScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ModeratorLoginScreen.h"

@interface ModeratorLoginScreen ()

@property (weak, nonatomic) IBOutlet UITextField *txtUser;      //username
@property (weak, nonatomic) IBOutlet UITextField *txtPass;      //password
@property (weak, nonatomic) IBOutlet UISwitch *swtVerify;       //not a robot switch
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;        //login button
@property (weak, nonatomic) IBOutlet UILabel *lblFailedAttempts;    //displays failed login attempts
- (IBAction)touchUpLogin:(id)sender;

@end

@implementation ModeratorLoginScreen

int failed = 0;                                             //number of failed login attempts
NSString *failStart = @"You have failed to login ";         //failed login messages
NSString *failMEnd = @" times.";
NSString *failSEnd = @" time.";
NSString *tooMany = @"This login is no longer available.";

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //make sure failed login label is initialized and hidden
    self.lblFailedAttempts.text = failStart;
    self.lblFailedAttempts.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchUpLogin:(id)sender {
    //called when the login button is pressed
    
    /*********************Login Override********************/
    
    if ([self.txtUser.text isEqualToString:@"Admin"] && [self.txtPass.text isEqualToString:@"12345"]){
        [DynamoInterface removeOutdated];
        [self performSegueWithIdentifier:@"moderatorLoginSegue" sender:self.txtUser.text];
    }else{
    
    /**********************End Override*********************/
        
        NSLog(@"Failed attempts: %d", failed);
        //check if credentials are proper and the switch is pressed
        if ([DynamoInterface verifyCredentials:self.txtUser.text pWord:self.txtPass.text] && self.swtVerify.on){
            [DynamoInterface removeOutdated];   //remove outdated posts from the board
            //login confirmed, segue to view queue list screen
            [self performSegueWithIdentifier:@"moderatorLoginSegue" sender:self.txtUser.text];
        }else{
            if (!self.swtVerify.on){        //robot switch not pressed
                //display alert that robots are not allowed
                UIAlertView *botAlert = [[UIAlertView alloc] initWithTitle:@"Robot"
                                                                   message:@"No Robots Allowed!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [botAlert show];
            }else{      //bad login credentials
                //display alert that login credentials were invalid
                UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Login"
                                                                    message:@"The password or username you have entered is incorrect."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [saveAlert show];
            }
            failed++;       //increment number of failed attempts
            if (failed == 1){   //display failed attempts messages
                self.lblFailedAttempts.text = [failStart stringByAppendingString:[[NSString stringWithFormat:@"%d",failed] stringByAppendingString:failSEnd]];
            }else if (failed < 5){
                self.lblFailedAttempts.text = [failStart stringByAppendingString:[[NSString stringWithFormat:@"%d",failed] stringByAppendingString:failMEnd]];
            }else{      //disbale login button after 5 failures
                self.lblFailedAttempts.text = tooMany;
                self.btnLogin.enabled = false;
                self.btnLogin.hidden = true;
            }
            self.txtUser.text = @"";    //reset text fields
            self.txtPass.text = @"";
            self.lblFailedAttempts.hidden = false;
        }
        /****part of override***/
    }
    /****end part****/
    
}

@end
