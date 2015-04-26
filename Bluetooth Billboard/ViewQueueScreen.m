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

@end

@implementation ViewQueueScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    self.txtHost.text = @"";
    self.txtAddress.text = @"";
    self.txtPhone.text = @"";
    self.txtEmail.text = @"";
    self.txtDate.text = @"";
    self.txvInformation.text = @"";
}
@end
