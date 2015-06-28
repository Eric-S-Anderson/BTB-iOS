//
//  SavedBoardsListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "SavedBoardsListScreen.h"

@interface SavedBoardsListScreen ()

@property (weak, nonatomic) IBOutlet UITableView *tblBoards;    //table that displays saved boards

@end

@implementation SavedBoardsListScreen

NSInteger rowDex;           //index of the selected row
NSMutableArray *boards;     //array of saved boards

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //assign delegates
    self.tblBoards.dataSource = self;
    self.tblBoards.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    //called everytime the page appears
    [super viewDidAppear:animated];
    //populate board array with saved boards
    boards = [DeviceInterface getBoards];
    //reload table data
    [self.tblBoards reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    //called when the user long presses a table cell
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        rowDex = cell.tag;  //set row index from cell tag
        //display an alert box to the user asking if they want to delete the board
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Delete Board"
                                                           message:@"Would you like to delete this board from your device?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        [delAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    //called when an alert box button is pressed
    if (buttonIndex == 1){
        //get board information
        Board *endMe = [boards objectAtIndex:rowDex];
        //delete board from device
        [DeviceInterface deleteBoard:endMe];
        //reload all saved baords
        boards = [DeviceInterface getBoards];
        //reload table data
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
    //get information for table cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedBoardPrototype" forIndexPath:indexPath];
    //populate cell information
    Board *cellBoard = [boards objectAtIndex:indexPath.row];
    cell.textLabel.text = cellBoard.Board_Name;
    cell.detailTextLabel.text = cellBoard.Organization;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];        //add long press gesture to each table cell
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //called when a table cell is selected
    Board *bufferBoard = [boards objectAtIndex:indexPath.row];
    NSString *brdName = [NSString stringWithFormat:@"%@",bufferBoard.Board_ID];
    [DynamoInterface setCurrentBoard:brdName];  //set the current board to the selected board
}

@end
