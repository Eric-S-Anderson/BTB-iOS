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
        Post *saveMe = [filteredPosts objectAtIndex:rowDex];
        
        [DeviceInterface savePost:saveMe];
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
    HTMLParser *info = [[HTMLParser alloc] initWithString:post.Information];
    cell.detailTextLabel.text = info.textOnlyMessage;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}

- (IBAction)touchUpSaveBoard:(id)sender {

    [DeviceInterface saveBoard:[DynamoInterface getCurrentBoardInfo]];
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
