//
//  ViewPostListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewPostListScreen.h"

@interface ViewPostListScreen ()

@property (weak, nonatomic) IBOutlet UITableView *tblPosts;     //table that displays posts
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;   //activity indicator
@property (weak, nonatomic) IBOutlet UIButton *btnSave;         //save button
- (IBAction)touchUpSaveBoard:(id)sender;        //called when the save button is pressed

@end

@implementation ViewPostListScreen

Board *myBoard;         //board currently being viewed
NSInteger rowDex;       //index of the selected post
NSMutableArray *filteredPosts;  //filtered array of posts

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //assign delegates
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
    [self.aivWaiting stopAnimating];
    
}

- (void)viewDidAppear:(BOOL)animated {
    //called everytime the page appears
    [super viewDidAppear:animated];
    //populate board
    myBoard = [DynamoInterface getFilteredPosts:[DynamoInterface getCurrentBoard] statFilter:@"Posted"];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];    //show activity indicator while database is querying
    //initialize filtered posts array
    filteredPosts = [[NSMutableArray alloc] init];
    [filteredPosts removeAllObjects];
    //load arrays of blocked hosts and types
    NSArray *blockedTypes = [[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"];
    NSArray *blockedHosts = [[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"];
    //only add post to filtered array if it doesn't match a blocked type or host
    bool foundIT = false;
    for (unsigned int i = 0; i < myBoard.Posts.count; i++){
        foundIT = false;
        Post *filterMe = [myBoard.Posts objectAtIndex:i];
        for (unsigned int j = 0; j < blockedTypes.count; j++){
            if ([[blockedTypes objectAtIndex:j] isEqualToString:filterMe.Post_Type]){
                foundIT = true;     //type is blocked
            }
        }
        for (unsigned int k = 0; k < blockedHosts.count; k++){
            if ([[blockedHosts objectAtIndex:k] isEqualToString:filterMe.Host]){
                foundIT = true;     //host is blocked
            }
        }
        if (!foundIT){
            //post not blocked
            [filteredPosts addObject:filterMe];
        }
    }
    if ([[DynamoInterface getCurrentBoard] isEqualToString:@"000000"] && filteredPosts.count > 1){
        for (int i = 0; i < filteredPosts.count; i++){
            for (int j = 0; j < filteredPosts.count - 1; j++){
                Post *first = [filteredPosts objectAtIndex:j];
                Post *second = [filteredPosts objectAtIndex:j + 1];
                if (first.Post_ID > second.Post_ID){
                    [filteredPosts replaceObjectAtIndex:j withObject:second];
                    [filteredPosts replaceObjectAtIndex:j + 1 withObject:first];
                }
            }
        }
    }
    //reload table data
    [self.tblPosts reloadData];
    //hide save button if the device doesn't have an internet connection
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
    //called when the user long presses a table cell
    if (gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        rowDex = cell.tag;          //set row index from cell tag
        //display an alert box to the user asking if they want to save the post
        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:@"Save Post"
                                                            message:@"Would you like to save this post?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Save", nil];
        [infoAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    //called when an alert box button is pressed
    if (buttonIndex == 1){
        //get post information
        Post *saveMe = [filteredPosts objectAtIndex:rowDex];
        //save post
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
    //populate cell information
    Post *post = [filteredPosts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.Host;
    HTMLParser *info = [[HTMLParser alloc] initWithString:post.Information];
    cell.detailTextLabel.text = info.textOnlyMessage;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];        //add long press gesture to each table cell
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}

- (IBAction)touchUpSaveBoard:(id)sender {
    //save the board to the device
    [DeviceInterface saveBoard:[DynamoInterface getCurrentBoardInfo]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // called when a table cell is selected
    if ([segue.identifier isEqualToString:@"postViewSegue"]) {
        NSIndexPath *indexPath = [self.tblPosts indexPathForSelectedRow];
        ViewPostScreen *destViewController = segue.destinationViewController;
        Post *post = [filteredPosts objectAtIndex:indexPath.row];
        destViewController.post = post;     //pass selected post to view post screen
    }
}

@end
