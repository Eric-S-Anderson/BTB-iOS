//
//  ViewSavedPostScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/14/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewSavedPostScreen.h"

@interface ViewSavedPostScreen ()
@property (weak, nonatomic) IBOutlet UILabel *lblHost;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextView *txvAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIScrollView *scvDetails;
@property (weak, nonatomic) IBOutlet UISwitch *swtDetails;
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;
- (IBAction)touchUpDelete:(id)sender;
- (IBAction)changeDetails:(id)sender;

@end

@implementation ViewSavedPostScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

- (IBAction)touchUpDelete:(id)sender {
    //delete the post from the device
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", self.post.Post_ID];
    [request setPredicate:predicate];
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0){
        NSLog(@"Post cannot be deleted");
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Post Corrupted"
                                                            message:@"Data corruption, could not locate post."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [delAlert show];
    }else{
        NSLog(@"Post deleted");
        [context deleteObject:[array objectAtIndex:0]];
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Post Deleted"
                                                            message:@"The post has been deleted from your device."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [delAlert show];
    }
    
}

- (IBAction)changeDetails:(id)sender {
    if (self.swtDetails.on){
        self.scvDetails.hidden = false;
    }else{
        self.scvDetails.hidden = true;
    }
}
@end
