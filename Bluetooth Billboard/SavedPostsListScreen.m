//
//  SavedPostsListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "SavedPostsListScreen.h"

@interface SavedPostsListScreen ()

@property (weak, nonatomic) IBOutlet UITableView *tblPosts;     //table that displays saved posts

@end

@implementation SavedPostsListScreen

NSInteger rowDex;           //index of the selected row
NSMutableArray *posts;      //array of saved posts

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //assign delegates
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    //called everytime the page appears
    [super viewDidAppear:animated];
    //populate post array with saved posts
    posts = [DeviceInterface getPosts];
    //reload table data
    [self.tblPosts reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    //called when the user long presses a table cell
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        rowDex = cell.tag;      //set row index from cell tag
        //display an alert box to the user asking if they want to delete the post
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                           message:@"Would you like to delete this post from your device?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        [delAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    //called when an alert box button is pressed
    if (buttonIndex == 1){
        //get post information
        Post *endMe = [posts objectAtIndex:rowDex];
        //delete post from device
        [DeviceInterface deletePost:endMe];
        //reload all saved posts
        posts = [DeviceInterface getPosts];
        //reload table data
        [self.tblPosts reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedPostsPrototype" forIndexPath:indexPath];
    //populate cell information
    Post *post = [posts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.Host;
    HTMLParser *info = [[HTMLParser alloc] initWithString:post.Information];
    cell.detailTextLabel.text = info.textOnlyMessage;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];        //add long press gesture to each table cell
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //called before segue to view saved post screen
    if ([segue.identifier isEqualToString:@"savedPostSegue"]) {
        NSIndexPath *indexPath = [self.tblPosts indexPathForSelectedRow];
        ViewSavedPostScreen *destViewController = segue.destinationViewController;
        Post *post = [posts objectAtIndex:indexPath.row];
        destViewController.post = post;     //pass selected post to new screen
    }
}

@end
