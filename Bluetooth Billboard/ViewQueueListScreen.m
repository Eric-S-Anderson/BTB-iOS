//
//  ViewQueueListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewQueueListScreen.h"
#import "ViewQueueScreen.h"
#import "Board.h"


@interface ViewQueueListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblPosts;

@end

@implementation ViewQueueListScreen

Board *brd;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarController.title = @"View Board Queue";
    
    brd = [Board new];
    NSString *brdid = @"776655";
    [brd populate:brdid statFilter:@"Queued"];
    
    
    while (brd.Posts == nil || brd.Posts.count == 0) {
    }
    
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
    return [brd.Posts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeCell" forIndexPath:indexPath];
    
    Post *post = [brd.Posts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.Host;
    // Configure the cell...
    //[self.tblPosts reloadData];
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"viewQueueSegue"]) {
        NSIndexPath *indexPath = [self.tblPosts indexPathForSelectedRow];
        ViewQueueScreen *destViewController = segue.destinationViewController;
        Post *post = [brd.Posts objectAtIndex:indexPath.row];
        destViewController.post = post;
    }
}

@end
