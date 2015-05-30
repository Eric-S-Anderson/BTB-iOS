//
//  SavedBoardsListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "SavedBoardsListScreen.h"

@interface SavedBoardsListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblBoards;

@end

@implementation SavedBoardsListScreen

NSMutableArray *boards;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tblBoards.dataSource = self;
    self.tblBoards.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    boards = [[NSMutableArray alloc] init];
    
    for (unsigned int i = 0; i < objects.count; i++){
        NSManagedObject *aboard = [objects objectAtIndex:i];
        Board *buffer = [Board new];
        buffer.Board_ID = [aboard valueForKey:@"boardID"];
        buffer.Group_ID = [aboard valueForKey:@"groupID"];
        buffer.Moderator_ID = [aboard valueForKey:@"moderatorID"];
        buffer.Instructions = [aboard valueForKey:@"instructions"];
        buffer.Organization = [aboard valueForKey:@"organization"];
        buffer.Board_Name = [aboard valueForKey:@"boardName"];
        [boards addObject:buffer];
    }
    
    [self.tblBoards reloadData];
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
    return [boards count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedBoardPrototype" forIndexPath:indexPath];
    
    // Configure the cell...
    Board *cellBoard = [boards objectAtIndex:indexPath.row];
    
    cell.textLabel.text = cellBoard.Board_Name;
    cell.detailTextLabel.text = cellBoard.Organization;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //set the current board to the selected board
    //this only occurs immediately before the modal exit segue
    Board *bufferBoard = [boards objectAtIndex:indexPath.row];
    NSString *brdName = [NSString stringWithFormat:@"%@",bufferBoard.Board_ID];
    [DynamoInterface setCurrentBoard:brdName];
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
}


@end
