//
//  PostScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "PostScreen.h"


@interface PostScreen ()
@property (weak, nonatomic) IBOutlet UITextField *txtHost;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UITextField *txtPostType;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIView *imgPost;
@property (weak, nonatomic) IBOutlet UIPickerView *pkvPostType;
@property (weak, nonatomic) IBOutlet UIDatePicker *dpvDate;
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;
@property (weak, nonatomic) IBOutlet UISwitch *swtVerify;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;
@property NSArray *types;
- (IBAction)touchUpType:(id)sender;
- (IBAction)touchUpDate:(id)sender;
- (IBAction)touchSubmit:(id)sender;

@end

@implementation PostScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.aivWaiting stopAnimating];
    
    //picker data
    self.types = [[NSArray alloc] initWithObjects:@"Event", @"Announcement", @"Employment", @"Coupon", @"Sales", @"Services", @"Other", nil];
    
    //picker gesture initialization
    self.pkvPostType.userInteractionEnabled = YES;
    self.pkvPostType.multipleTouchEnabled = YES;
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tappedPicker:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.delegate = self;
    [self.pkvPostType addGestureRecognizer:tapGesture];
    
    //date picker gesture initialization
    self.dpvDate.userInteractionEnabled = YES;
    self.dpvDate.multipleTouchEnabled = YES;
    UITapGestureRecognizer *tapDateGesture =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tappedDate:)];
    tapDateGesture.numberOfTapsRequired = 1;
    tapDateGesture.numberOfTouchesRequired = 1;
    tapDateGesture.delegate = self;
    [self.dpvDate addGestureRecognizer:tapDateGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return [self.types count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [self.types objectAtIndex:row];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    //confirms gestures
    return YES;
}

-(void)tappedPicker:(UIGestureRecognizer *)sender{
    //called when the picker is tapped
    self.txtPostType.hidden = !self.txtPostType.hidden;  //hide text, pop picker
    self.pkvPostType.hidden = !self.pkvPostType.hidden;
    NSInteger currentRow = [self.pkvPostType selectedRowInComponent:0];   //get selected row
    self.txtPostType.text = [self.types objectAtIndex:currentRow];      //set text field
    self.txtPostType.enabled = false;  //ends editing
    self.txtPostType.enabled = true;   //re-enables

}

-(void)tappedDate:(UIGestureRecognizer *)sender{
    //called when the date picker is tapped
    self.txtDate.hidden = !self.txtDate.hidden;  //hide text,  pop date picker
    self.dpvDate.hidden = !self.dpvDate.hidden;
    NSDate *chosenDate = [self.dpvDate date];       //get selected date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMddyyyy"];        //format date to string
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *stringFromDate = [formatter stringFromDate:chosenDate];
    self.txtDate.text = stringFromDate;
    self.txtDate.enabled = false;  //ends editing
    self.txtDate.enabled = true;   //re-enables
    
}

- (IBAction)touchUpType:(id)sender {
    //called when the postype textfield is selected
    self.txtPostType.hidden = !self.txtPostType.hidden;  //hide text, pop picker
    self.pkvPostType.hidden = !self.pkvPostType.hidden;
    
}

- (IBAction)touchUpDate:(id)sender {
    //called when the date textfield is selected
    self.txtDate.hidden = !self.txtDate.hidden;     //hide text, pop date picker
    self.dpvDate.hidden = !self.dpvDate.hidden;
}

- (IBAction)touchSubmit:(id)sender {
    
    if (!self.swtVerify.on){
        UIAlertView *botAlert = [[UIAlertView alloc] initWithTitle:@"Robot"
                                                           message:@"No Robots Allowed!"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [botAlert show];
    }else{
        Post *post = [Post new];
        post.Host = self.txtHost.text;
        post.Address = self.txtAddress.text;
        PhoneNumber *postPhone = [[PhoneNumber alloc] initWithString:self.txtPhone.text];
        post.Phone = postPhone.value;
        post.Email = self.txtEmail.text;
        post.End_Date = [NSNumber numberWithInteger:[self.txtDate.text integerValue]];
        post.Post_Type = self.txtPostType.text;
        post.Information = self.txvInformation.text;
        post.Post_ID = [NSNumber numberWithInteger:arc4random_uniform(99999999)];  //easy auto-id
        post.Post_Status = @"Queued";

        [DynamoInterface savePost:post];
        while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];self.aivWaiting.hidden = false;}
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"previewPostSegue"]) {
        
        PreviewPostScreen *destViewController = segue.destinationViewController;
        
        //create a populate post from viewcontroller input
        Post *post = [Post new];
        post.Host = self.txtHost.text;
        post.Address = self.txtAddress.text;
        PhoneNumber *postPhone = [[PhoneNumber alloc] initWithString:self.txtPhone.text];
        post.Phone = postPhone.value;
        post.Email = self.txtEmail.text;
        post.End_Date = [NSNumber numberWithInteger:[self.txtDate.text integerValue]];
        post.Post_Type = self.txtPostType.text;
        post.Information = self.txvInformation.text;
        post.Post_ID = [NSNumber numberWithInteger:arc4random_uniform(99999999)];  //easy auto-id
        post.Post_Status = @"Queued";
        
        destViewController.post = post;
    }
}

@end
