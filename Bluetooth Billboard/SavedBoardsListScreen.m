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

NSInteger rowDex;
NSMutableArray *boards;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tblBoards.dataSource = self;
    self.tblBoards.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    boards = [DeviceInterface getBoards];
    
    [self.tblBoards reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        rowDex = cell.tag;
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Delete Board"
                                                           message:@"Would you like to delete this board from your device?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        [delAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        
        Board *endMe = [boards objectAtIndex:rowDex];
        
        [DeviceInterface deleteBoard:endMe];
        
        boards = [DeviceInterface getBoards];
        
        [self.tblBoards reloadData];
    }
    
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
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
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
