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


@property (weak, nonatomic) IBOutlet UILabel *lblHost;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextView *txvAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextView *txvInformation;
@property (weak, nonatomic) IBOutlet UIScrollView *scvDetails;
@property (weak, nonatomic) IBOutlet UISwitch *swtDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnBlockHost;
@property (weak, nonatomic) IBOutlet UIButton *btnBlockType;
- (IBAction)touchUpBlockHost:(id)sender;
- (IBAction)touchUpBlockType:(id)sender;
- (IBAction)touchUpSave:(id)sender;
- (IBAction)changeDetails:(id)sender;

@end

@implementation ViewPostScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.post != nil){
        self.lblHost.text = self.post.Host;
        self.txvAddress.text = self.post.Address;
        if (self.post.Phone != NULL){
            self.txtPhone.text = [NSString stringWithFormat:@"%@",self.post.Phone];
        }
        self.txtEmail.text = self.post.Email;
        self.txvInformation.text = self.post.Information;

        NSString *blkHost = [@"Block Host\n" stringByAppendingString:self.post.Host];
        NSString *blkType = [@"Block Type\n" stringByAppendingString:self.post.Post_Type];
    
        [self.btnBlockHost setTitle:(blkHost) forState:UIControlStateNormal];
        [self.btnBlockType setTitle:(blkType) forState:UIControlStateNormal];
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

- (IBAction)touchUpBlockHost:(id)sender {
    
    bool foundIT = false;
    NSMutableArray *banHosts = [[NSMutableArray alloc] init];
    NSString *blockHost = [NSString stringWithString:self.post.Host];
    banHosts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"]mutableCopy];
    for (unsigned int i = 0; i < banHosts.count; i++){
        if ([banHosts objectAtIndex:i] == blockHost){
            foundIT = true;
        }
    }
    if (!foundIT){
        [banHosts addObject:blockHost];
        NSLog(@"Host %@ has been banned", blockHost);
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Host Banned"
                                                            message:@"You have sucessfully banned this host. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [banAlert show];
    }else{
        NSLog(@"Host was already banned");
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Host Already Banned"
                                                           message:@"This host was already banned. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [banAlert show];
    }
    [[NSUserDefaults standardUserDefaults] setObject:banHosts forKey:@"blockedHosts"];
}

- (IBAction)touchUpBlockType:(id)sender {
    
    bool foundIT = false;
    NSMutableArray *banType = [[NSMutableArray alloc] init];
    NSString *blockType = [NSString stringWithString:self.post.Post_Type];
    banType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"]mutableCopy];
    for (unsigned int i = 0; i < banType.count; i++){
        if ([banType objectAtIndex:i] == blockType){
            foundIT = true;
        }
    }
    if (!foundIT){
        [banType addObject:blockType];
        NSLog(@"Type %@ has been banned", blockType);
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Type Banned"
                                                           message:@"You have sucessfully banned this type. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [banAlert show];
    }else{
        NSLog(@"Type was already banned");
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Type Already Banned"
                                                           message:@"This type was already banned. You can undo this by selecting 'Ban Lists' from the tab bar."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [banAlert show];
    }
    [[NSUserDefaults standardUserDefaults] setObject:banType forKey:@"blockedTypes"];
}

- (IBAction)touchUpSave:(id)sender {
    
    NSString *pstID = [NSString stringWithFormat:@"%@", self.post.Post_ID];
    NSString *brdID = [DynamoInterface getCurrentBoard];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *lngID = [formatter numberFromString:[brdID stringByAppendingString:pstID]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", lngID];
    [request setPredicate:predicate];
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0) {
        NSManagedObject *savedPost;
        savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedPost" inManagedObjectContext:context];
        [savedPost setValue:lngID forKey:@"postID"];
        [savedPost setValue:self.post.Phone forKey:@"phone"];
        [savedPost setValue:self.post.End_Date forKey:@"end_Date"];
        [savedPost setValue:self.post.Host forKey:@"host"];
        [savedPost setValue:self.post.Email forKey:@"email"];
        [savedPost setValue:self.post.Address forKey:@"address"];
        [savedPost setValue:self.post.Information forKey:@"information"];
        [savedPost setValue:self.post.Post_Type forKey:@"post_Type"];
        [savedPost setValue:self.post.Post_Status forKey:@"post_Status"];
        [context save:&error];
        NSLog(@"Post saved");
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Saved"
                                                           message:@"You have sucessfully saved this post.  To view this post again, click the 'Saved Posts' icon on your tab bar."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [saveAlert show];
    }else{
        NSLog(@"Post has already been saved.");
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Already Saved"
                                                            message:@"You had already saved this post.  To view this post again, click the 'Saved Posts' icon on your tab bar."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [saveAlert show];
    }
    
}

- (IBAction)changeDetails:(id)sender {
    if (self.swtDetails.on){
        self.scvDetails.hidden = false;
    }else{
        self.scvDetails.hidden = true;
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
