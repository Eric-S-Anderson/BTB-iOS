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

@end

@implementation ViewPostScreen

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
    }else{
        NSLog(@"Host was already banned");
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
    }else{
        NSLog(@"Type was already banned");
    }
    [[NSUserDefaults standardUserDefaults] setObject:banType forKey:@"blockedTypes"];
}

- (IBAction)touchUpSave:(id)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", self.post.Post_ID];
    [request setPredicate:predicate];
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0) {
        NSManagedObject *savedPost;
        savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedPost" inManagedObjectContext:context];
        [savedPost setValue:self.post.Post_ID forKey:@"postID"];
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
    }else{
        NSLog(@"Post has already been saved.");
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
