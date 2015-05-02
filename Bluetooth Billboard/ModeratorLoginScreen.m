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
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)touchUpLogin:(id)sender;

@end

@implementation ModeratorLoginScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchUpLogin:(id)sender {
    
    /*********************Login Override********************/
    
    if ([self.txtUser.text isEqualToString:@"Admin"] && [self.txtPass.text isEqualToString:@"12345"]){
        [self performSegueWithIdentifier:@"moderatorLoginSegue" sender:self.txtUser.text];
    }
    
    /**********************End Override*********************/
    
    if ([DynamoInterface verifyCredentials:self.txtUser.text pWord:self.txtPass.text]){
        [self performSegueWithIdentifier:@"moderatorLoginSegue" sender:self.txtUser.text];
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
