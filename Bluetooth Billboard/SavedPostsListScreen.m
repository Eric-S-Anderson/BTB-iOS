//
//  SavedPostsListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "SavedPostsListScreen.h"

@interface SavedPostsListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblPosts;

@end

@implementation SavedPostsListScreen

NSInteger rowDex;
NSMutableArray *posts;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tblPosts.dataSource = self;
    self.tblPosts.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
 
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    posts = [[NSMutableArray alloc] init];
    
    for (unsigned int i = 0; i < objects.count; i++){
        NSManagedObject *apost = [objects objectAtIndex:i];
        Post *buffer = [Post new];
        buffer.Post_ID = [apost valueForKey:@"postID"];
        buffer.Phone = [apost valueForKey:@"phone"];
        buffer.End_Date = [apost valueForKey:@"end_Date"];
        buffer.Host = [apost valueForKey:@"host"];
        buffer.Email = [apost valueForKey:@"email"];
        buffer.Address = [apost valueForKey:@"address"];
        buffer.Information = [apost valueForKey:@"information"];
        buffer.Post_Type = [apost valueForKey:@"post_Type"];
        buffer.Post_Status = [apost valueForKey:@"post_Status"];
        [posts addObject:buffer];
    }
    
    [self.tblPosts reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        rowDex = cell.tag;
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                           message:@"Would you like to delete this post from your device?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        [delAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        
        Post *endMe = [posts objectAtIndex:rowDex];
        NSNumber *postID = endMe.Post_ID;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSError *error;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", postID];
        [request setPredicate:predicate];
        
        NSArray *array = [[NSArray alloc] init];
        array = [context executeFetchRequest:request error:&error];
        if (array.count > 0){
            [context deleteObject:[array objectAtIndex:0]];
            NSLog(@"Post deleted");
        }
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Post Deleted"
                                                           message:@"The post has been deleted."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [delAlert show];
        
        NSFetchRequest *rePop = [[NSFetchRequest alloc] init];
        [rePop setEntity:entity];
        
        NSArray *objects = [context executeFetchRequest:rePop error:&error];
        
        posts = [[NSMutableArray alloc] init];
        
        for (unsigned int i = 0; i < objects.count; i++){
            NSManagedObject *apost = [objects objectAtIndex:i];
            Post *buffer = [Post new];
            buffer.Post_ID = [apost valueForKey:@"postID"];
            buffer.Phone = [apost valueForKey:@"phone"];
            buffer.End_Date = [apost valueForKey:@"end_Date"];
            buffer.Host = [apost valueForKey:@"host"];
            buffer.Email = [apost valueForKey:@"email"];
            buffer.Address = [apost valueForKey:@"address"];
            buffer.Information = [apost valueForKey:@"information"];
            buffer.Post_Type = [apost valueForKey:@"post_Type"];
            buffer.Post_Status = [apost valueForKey:@"post_Status"];
            [posts addObject:buffer];
        }
        
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedPostsPrototype" forIndexPath:indexPath];
    
    // Configure the cell...
    
    Post *post = [posts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = post.Host;
    HTMLParser *info = [[HTMLParser alloc] initWithString:post.Information];
    cell.detailTextLabel.text = info.textOnlyMessage;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"savedPostSegue"]) {
        NSIndexPath *indexPath = [self.tblPosts indexPathForSelectedRow];
        ViewSavedPostScreen *destViewController = segue.destinationViewController;
        Post *post = [posts objectAtIndex:indexPath.row];
        destViewController.post = post;
    }
}


@end
