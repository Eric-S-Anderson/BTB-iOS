//
//  PostScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "PostScreen.h"

@interface PostScreen ()

@property (weak, nonatomic) IBOutlet UITextField *txtHost;              //host name
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;           //address
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;             //phone number
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;             //e-mail address
@property (weak, nonatomic) IBOutlet UITextField *txtDate;              //end date
@property (weak, nonatomic) IBOutlet UITextField *txtPostType;          //post type
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;               //submit button
@property (weak, nonatomic) IBOutlet UIPickerView *pkvPostType;         //picker view
@property (weak, nonatomic) IBOutlet UIDatePicker *dpvDate;             //date picker view
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;        //post information
@property (weak, nonatomic) IBOutlet UISwitch *swtVerify;               //not a robot switch
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;       //activity indicator
@property NSArray *types;               //array of possible post types
- (IBAction)touchUpType:(id)sender;     //called when post type text field is pressed
- (IBAction)touchUpDate:(id)sender;     //called when date text field is pressed
- (IBAction)touchSubmit:(id)sender;     //called when submit button is pressed

@end

@implementation PostScreen

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //assign delegates
    self.txtAddress.delegate = self;
    self.txtDate.delegate = self;
    self.txtEmail.delegate = self;
    self.txtHost.delegate = self;
    self.txtPhone.delegate = self;
    self.txtPostType.delegate = self;
    self.txvInformation.delegate = self;
    //make sure activity indicator is not showing
    [self.aivWaiting stopAnimating];
    //initialize type array
    self.types = [[NSArray alloc] initWithObjects:@"Event", @"Announcement", @"Employment", @"Coupon", @"Sales", @"Services", @"Other", nil];
    //type picker gesture initialization
    self.pkvPostType.userInteractionEnabled = YES;
    self.pkvPostType.multipleTouchEnabled = YES;
    UITapGestureRecognizer *tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(tappedPicker:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.delegate = self;
    //add gesture to picker
    [self.pkvPostType addGestureRecognizer:tapGesture];
    //date picker gesture initialization
    self.dpvDate.userInteractionEnabled = YES;
    self.dpvDate.multipleTouchEnabled = YES;
    UITapGestureRecognizer *tapDateGesture =[[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(tappedDate:)];
    tapDateGesture.numberOfTapsRequired = 1;
    tapDateGesture.numberOfTouchesRequired = 1;
    tapDateGesture.delegate = self;
    //add gesture to date picker
    [self.dpvDate addGestureRecognizer:tapDateGesture];
    //add click off text view gesture
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    //return number of components in picker view
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    //return number of rows in picker view
    return [self.types count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    //populate picker with type array
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
    self.txtPostType.enabled = true;   //re-enables text field
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
    self.txtDate.enabled = true;   //re-enables text field
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
    //verify and submit the post
    if (!self.swtVerify.on){    //robot switch not pressed
        //display alert box that robots cannot submit posts
        UIAlertView *botAlert = [[UIAlertView alloc] initWithTitle:@"Robot"
                                                           message:@"No Robots Allowed!"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [botAlert show];
    }else if ([self.txtHost.text isEqualToString:@""]){     //no host name entered
        //display alert box that host name is required
        UIAlertView *invAlert = [[UIAlertView alloc] initWithTitle:@"No Host Name"
                                                           message:@"You must provide a host name."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [invAlert show];
        [self.txtHost becomeFirstResponder];
    }else if ([self.txtPostType.text isEqualToString:@""]){ //no post type entered
        //display alert box that the post type is required
        UIAlertView *invAlert = [[UIAlertView alloc] initWithTitle:@"No Type Chosen"
                                                           message:@"You must choose a post type."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [invAlert show];
        [self.txtPostType becomeFirstResponder];
    }else if ([self.txvInformation.text isEqualToString:@""]){  //no post information entered
        //display alert box that the post information is required
        UIAlertView *invAlert = [[UIAlertView alloc] initWithTitle:@"No Information"
                                                           message:@"You must add some information."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [invAlert show];
        [self.txvInformation becomeFirstResponder];
    }else{      //post is submittable
        Post *post = [Post new];
        //assign post information
        post.Host = self.txtHost.text;
        post.Address = self.txtAddress.text;
        PhoneNumber *postPhone = [[PhoneNumber alloc] initWithString:self.txtPhone.text];
        post.Phone = postPhone.value;
        post.Email = self.txtEmail.text;
        if ([self.txtDate.text isEqualToString:@""]){   //date was not entered
            //set date to 90 days from today
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:90];
            NSDate *endDay = [gregorian dateByAddingComponents:offsetComponents
                                                                toDate:today options:0];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMddyyyy"];
            post.End_Date = [NSNumber numberWithInteger:[[dateFormat stringFromDate:endDay] integerValue]];
        }else{  //date was entered
            post.End_Date = [NSNumber numberWithInteger:[self.txtDate.text integerValue]];
        }
        post.Post_Type = self.txtPostType.text;
        post.Information = self.txvInformation.text;
        post.Post_ID = [NSNumber numberWithInteger:arc4random_uniform(99999999)];  //auto-id
        Post *checker = [Post new];
        checker = [DynamoInterface getSinglePost:[post.Post_ID intValue]];  //check if id is already in use
        while (checker.Post_ID != nil){
            //get new id if a post with  that id was found
            post.Post_ID = [NSNumber numberWithInteger:arc4random_uniform(99999999)];
            checker = [DynamoInterface getSinglePost:[post.Post_ID intValue]];
        }
        post.Post_Status = @"Queued";
        //submit post to the database
        [DynamoInterface savePost:post];
        while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];
            self.aivWaiting.hidden = false;}
        [self.aivWaiting stopAnimating];    //show activity indicator while querying database
        //give response to the user
        if ([DynamoInterface getQueryStatus] == 0){     //sucessful post submission
            //display an alert box notifying the user of of sucessful post submission
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Submitted"
                                                                message:@"Your post has been submitted for review.  A moderator will approve or deny your post, and notify you via the e-mail address you have entered."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }else{  //post not submitted
            //display an alert box notifying the user that the post was not submitted
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Not Submitted"
                                                                message:@"Could not connect to the database.  Please verify your internet conenction or try again later."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }
        //segue back to the view post list screen
        [self performSegueWithIdentifier: @"submitSegue" sender: self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //called when preview button is pressed
    if ([segue.identifier isEqualToString:@"previewPostSegue"]) {
        //create a populate post from view controller input
        Post *post = [Post new];
        //assign post information
        post.Host = self.txtHost.text;
        post.Address = self.txtAddress.text;
        PhoneNumber *postPhone = [[PhoneNumber alloc] initWithString:self.txtPhone.text];
        post.Phone = postPhone.value;
        post.Email = self.txtEmail.text;
        if ([self.txtDate.text isEqualToString:@""]){   //date was not entered
            //set date to 90 days from today
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *gregorian = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:90];
            NSDate *endDay = [gregorian dateByAddingComponents:offsetComponents
                                                        toDate:today options:0];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMddyyyy"];
            post.End_Date = [NSNumber numberWithInteger:[[dateFormat stringFromDate:endDay] integerValue]];
        }else{  //date was entered
            post.End_Date = [NSNumber numberWithInteger:[self.txtDate.text integerValue]];
        }
        post.Post_Type = self.txtPostType.text;
        post.Information = self.txvInformation.text;
        post.Post_ID = [NSNumber numberWithInteger:arc4random_uniform(99999999)];  //auto-id
        Post *checker = [Post new];
        checker = [DynamoInterface getSinglePost:[post.Post_ID intValue]];  //check if id is already in use
        while (checker.Post_ID != nil){
            //get new id if a post with  that id was found
            post.Post_ID = [NSNumber numberWithInteger:arc4random_uniform(99999999)];
            checker = [DynamoInterface getSinglePost:[post.Post_ID intValue]];
        }
        post.Post_Status = @"Queued";
        //create preview post screen view controller
        PreviewPostScreen *destViewController = segue.destinationViewController;
        destViewController.post = post;     //pass post to preview post view controller
    }
}

@end
