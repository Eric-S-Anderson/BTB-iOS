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
NSMutableArray *filteredPosts;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initializations
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
    
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    myBoard = [DynamoInterface getFilteredPosts:[DynamoInterface getCurrentBoard] statFilter:@"Posted"];
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
    return [filteredPosts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeCell" forIndexPath:indexPath];
    Post *post = [filteredPosts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.Host;
    cell.detailTextLabel.text = post.Information;
    return cell;
}

- (IBAction)touchUpSaveBoard:(id)sender {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Board *bufferBoard = [DynamoInterface getCurrentBoardInfo];
    
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
    }else{
        NSLog(@"Board has already been saved.");
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
