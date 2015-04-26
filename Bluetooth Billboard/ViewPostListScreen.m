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

@end

@implementation ViewPostListScreen

Board *myBoard;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initializations
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    myBoard = [DynamoInterface getFilteredPosts:[DynamoInterface getCurrentBoard] statFilter:@"Posted"];
    NSLog(@"Waiting for database response...");
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
    
    [self.tblPosts reloadData];
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
    cell.detailTextLabel.text = post.Information;
    return cell;
}

- (IBAction)touchUpSaveBoard:(id)sender {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *savedBoard;
    savedBoard = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedBoard" inManagedObjectContext:context];
    Board *bufferBoard = [DynamoInterface getSingleBoardInformation:[[DynamoInterface getCurrentBoard] intValue]];
    while ([DynamoInterface getQueryStatus] < 0) {}   //loop while waiting for database
    
    [savedBoard setValue:bufferBoard.Board_ID forKey:@"boardID"];
    [savedBoard setValue:bufferBoard.Group_ID forKey:@"groupID"];
    [savedBoard setValue:bufferBoard.Moderator_ID forKey:@"moderatorID"];
    [savedBoard setValue:bufferBoard.Organization forKey:@"organization"];
    [savedBoard setValue:bufferBoard.Instructions forKey:@"instructions"];
    [savedBoard setValue:bufferBoard.Board_Name forKey:@"boardName"];
    NSError *error;
    [context save:&error];
    NSLog(@"Board saved");
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
