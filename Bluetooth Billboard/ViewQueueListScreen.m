//
//  ViewQueueListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewQueueListScreen.h"


@interface ViewQueueListScreen ()

@property (weak, nonatomic) IBOutlet UITableView *tblPosts;                 //table that holds the posts
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;   //activity indicator

@end

@implementation ViewQueueListScreen

Board *queueBoard;      //board that is being viewed

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //load board information
    queueBoard = [DynamoInterface getFilteredPosts:[DynamoInterface getCurrentBoard] statFilter:@"Queued"];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];    //show activity indicator while database is querying
    //assign delegates
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [queueBoard.Posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //populate table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeCell" forIndexPath:indexPath];   //storyboad prototype
    //pust post information in the cell
    Post *post = [queueBoard.Posts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.Host;
    HTMLParser *info = [[HTMLParser alloc] initWithString:post.Information];
    cell.detailTextLabel.text = info.textOnlyMessage;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //called when a table cell is selected
    if ([segue.identifier isEqualToString:@"viewQueueSegue"]) {
        //pass the post attached to that cell to the view queue screen
        NSIndexPath *indexPath = [self.tblPosts indexPathForSelectedRow];
        ViewQueueScreen *destViewController = segue.destinationViewController;
        Post *post = [queueBoard.Posts objectAtIndex:indexPath.row];
        destViewController.post = post;
    }
}

@end
