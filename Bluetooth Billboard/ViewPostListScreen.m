//
//  ViewPostListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewPostListScreen.h"

@interface ViewPostListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblPosts;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
- (IBAction)touchUpSaveBoard:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@end

@implementation ViewPostListScreen

Board *myBoard;
NSInteger rowDex;
NSMutableArray *filteredPosts;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initializations
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
    [self.aivWaiting stopAnimating];
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    myBoard = [DynamoInterface getFilteredPosts:[DynamoInterface getCurrentBoard] statFilter:@"Posted"];
    
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];
    
    filteredPosts = [[NSMutableArray alloc] init];
    [filteredPosts removeAllObjects];
    NSArray *blockedTypes = [[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"];
    NSArray *blockedHosts = [[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"];
    bool foundIT = false;
    
    //filteredPosts = myBoard.Posts;
    for (unsigned int i = 0; i < myBoard.Posts.count; i++){
        foundIT = false;
        Post *filterMe = [myBoard.Posts objectAtIndex:i];
        for (unsigned int j = 0; j < blockedTypes.count; j++){
            if ([[blockedTypes objectAtIndex:j] isEqualToString:filterMe.Post_Type]){
                foundIT = true;
            }
        }
        for (unsigned int k = 0; k < blockedHosts.count; k++){
            if ([[blockedHosts objectAtIndex:k] isEqualToString:filterMe.Host]){
                foundIT = true;
            }
        }
        if (!foundIT){
            [filteredPosts addObject:filterMe];
        }
    }
    
    [self.tblPosts reloadData];
    
    if ([DynamoInterface getConnection]){
        self.btnSave.enabled = true;
        self.btnSave.hidden = false;
    }else{
        self.btnSave.enabled = false;
        self.btnSave.hidden = true;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        rowDex = cell.tag;
        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"Save Post"
                                                            message:@"Would you like to save this post?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Save", nil];
        [infoAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        Post *post = [filteredPosts objectAtIndex:rowDex];
        NSString *pstID = [NSString stringWithFormat:@"%@", post.Post_ID];
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
            [savedPost setValue:post.Phone forKey:@"phone"];
            [savedPost setValue:post.End_Date forKey:@"end_Date"];
            [savedPost setValue:post.Host forKey:@"host"];
            [savedPost setValue:post.Email forKey:@"email"];
            [savedPost setValue:post.Address forKey:@"address"];
            [savedPost setValue:post.Information forKey:@"information"];
            [savedPost setValue:post.Post_Type forKey:@"post_Type"];
            [savedPost setValue:post.Post_Status forKey:@"post_Status"];
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [filteredPosts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeCell" forIndexPath:indexPath];
    Post *post = [filteredPosts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.Host;
    cell.detailTextLabel.text = post.Information;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}

- (IBAction)touchUpSaveBoard:(id)sender {

    Board *bufferBoard = [DynamoInterface getCurrentBoardInfo];
    
    if (bufferBoard.Board_ID != nil){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSError *error;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"boardID == %@", bufferBoard.Board_ID];
        [request setPredicate:predicate];
        
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (array.count == 0) {
            NSManagedObject *savedBoard;
            savedBoard =
            [NSEntityDescription insertNewObjectForEntityForName:@"ManagedBoard" inManagedObjectContext:context];
            [savedBoard setValue:bufferBoard.Board_ID forKey:@"boardID"];
            [savedBoard setValue:bufferBoard.Group_ID forKey:@"groupID"];
            [savedBoard setValue:bufferBoard.Moderator_ID forKey:@"moderatorID"];
            [savedBoard setValue:bufferBoard.Organization forKey:@"organization"];
            [savedBoard setValue:bufferBoard.Instructions forKey:@"instructions"];
            [savedBoard setValue:bufferBoard.Board_Name forKey:@"boardName"];
            [context save:&error];
            NSLog(@"Board saved");
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Board Saved"
                                                                message:@"You have sucessfully saved the board.  To view this board again, click the 'Saved Boards' icon on your tab bar."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }else{
            NSLog(@"Board has already been saved.");
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Board Already Saved"
                                                                message:@"You had already saved this board.  To view this board again, click the 'Saved Boards' icon on your tab bar."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"postViewSegue"]) {
        NSIndexPath *indexPath = [self.tblPosts indexPathForSelectedRow];
        ViewPostScreen *destViewController = segue.destinationViewController;
        Post *post = [filteredPosts objectAtIndex:indexPath.row];
        destViewController.post = post;
    }
    
}



@end
