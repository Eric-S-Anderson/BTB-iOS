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
- (IBAction)touchUpBlockHost:(id)sender;
- (IBAction)touchUpBlockType:(id)sender;
- (IBAction)touchUpSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtTest;
- (IBAction)touchUpTest:(id)sender;

@end

@implementation ViewPostScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.post != nil){
        self.txtHost.text = self.post.Host;
        self.txtAddress.text = self.post.Address;
        self.txtPhone.text = [NSString stringWithFormat:@"%ld",self.post.Phone];
        self.txtEmail.text = self.post.Email;
        self.txtDate.text = [NSString stringWithFormat:@"%d",self.post.End_Date];
        self.txvInformation.text = self.post.Information;
    
        NSString *blkHost = [@"Block Host\n" stringByAppendingString:self.post.Host];
        NSString *blkType = [@"Block Type\n" stringByAppendingString:self.post.Post_Type];
    
        [self.btnBlockHost setTitle:(blkHost) forState:UIControlStateNormal];
        [self.btnBlockType setTitle:(blkType) forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchUpBlockHost:(id)sender {
    
    NSMutableArray *banHosts = [[NSMutableArray alloc] init];
    NSString *blockHost = [NSString stringWithString:self.post.Host];
    banHosts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"]mutableCopy];
    [banHosts addObject:blockHost];
    [[NSUserDefaults standardUserDefaults] setObject:banHosts forKey:@"blockedHosts"];
    NSLog(@"Host '%@' has been blocked.", self.post.Host);
}

- (IBAction)touchUpBlockType:(id)sender {
    
    NSMutableArray *banType = [[NSMutableArray alloc] init];
    NSString *blockType = [NSString stringWithString:self.post.Post_Type];
    banType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"]mutableCopy];
    [banType addObject:blockType];
    [[NSUserDefaults standardUserDefaults] setObject:banType forKey:@"blockedTypes"];
    NSLog(@"Type '%@' has been blocked.", self.post.Post_Type);
}

- (IBAction)touchUpSave:(id)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *savedPost;
    savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedPost" inManagedObjectContext:context];
    [savedPost setValue:[NSNumber numberWithInteger:self.post.Post_ID] forKey:@"postID"];
    [savedPost setValue:[NSNumber numberWithInteger:self.post.Phone] forKey:@"phone"];
    [savedPost setValue:[NSNumber numberWithInteger:self.post.End_Date] forKey:@"end_Date"];
    [savedPost setValue:self.post.Host forKey:@"host"];
    [savedPost setValue:self.post.Email forKey:@"email"];
    [savedPost setValue:self.post.Address forKey:@"address"];
    [savedPost setValue:self.post.Information forKey:@"information"];
    [savedPost setValue:self.post.Post_Type forKey:@"post_Type"];
    [savedPost setValue:self.post.Post_Status forKey:@"post_Status"];
    NSError *error;
    [context save:&error];
    NSLog(@"Post saved");
    
    
}

- (IBAction)touchUpTest:(id)sender {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    //NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //[request setEntity:entityDesc];
    
    [request setEntity:[NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSManagedObject *apost = [objects objectAtIndex:0];
    
    NSNumber *blah = [apost valueForKey:@"postID"];
    
    self.txtTest.text = [NSString stringWithFormat:@"%@",blah];
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
