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
@property (weak, nonatomic) IBOutlet UITextField *txtHost;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;
@property (weak, nonatomic) IBOutlet UIButton *btnBlockHost;
@property (weak, nonatomic) IBOutlet UIButton *btnBlockType;

@end

@implementation ViewPostScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.txtHost.text = self.post.Host;
    self.txtAddress.text = self.post.Address;
    self.txtPhone.text = [NSString stringWithFormat:@"%d",self.post.Phone];
    self.txtEmail.text = self.post.Email;
    self.txtDate.text = [NSString stringWithFormat:@"%d",self.post.End_Date];
    self.txvInformation.text = self.post.Information;
    
    NSString *blkHost = [@"Block Host\n" stringByAppendingString:self.post.Host];
    NSString *blkType = [@"Block Type\n" stringByAppendingString:self.post.Post_Type];
    
    [self.btnBlockHost setTitle:(blkHost) forState:UIControlStateNormal];
    [self.btnBlockType setTitle:(blkType) forState:UIControlStateNormal];
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

@end
