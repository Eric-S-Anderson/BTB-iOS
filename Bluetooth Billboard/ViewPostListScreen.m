//
//  ViewPostListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewPostListScreen.h"
#import "ViewPostScreen.h"
#import "Board.h"
#import "Post.h"

@interface ViewPostListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblPosts;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation ViewPostListScreen

Board *myBoard;

- (void)viewDidLoad {
    [super viewDidLoad];
    //initializations
    self.tabBarController.title = @"View Board";    //set title
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
    //create a populate board
    myBoard = [Board new];
    [myBoard populate:[Post getCurrentBoard] statFilter:@"Posted"];
    NSLog(@"Waiting for database response...");
    while ([Board getQueryStatus] < 0) {}   //loop while waiting for database
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
    return [myBoard.Posts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeCell" forIndexPath:indexPath];
    Post *post = [myBoard.Posts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.Host;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"postViewSegue"]) {
        NSIndexPath *indexPath = [self.tblPosts indexPathForSelectedRow];
        ViewPostScreen *destViewController = segue.destinationViewController;
        Post *post = [myBoard.Posts objectAtIndex:indexPath.row];
        destViewController.post = post;
    }
    
}


@end
