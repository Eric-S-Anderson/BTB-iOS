//
//  ViewBoardListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewBoardListScreen.h"

@interface ViewBoardListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblBoards;        //tableview for listing found boards
@property NSMutableArray *boardList;                                //array that holds the found boards
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;   //displays when querying database

@end

@implementation ViewBoardListScreen

Board *infoBoard;       //will hold the selected board

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //initializations
    [self.aivWaiting stopAnimating];
    self.tblBoards.dataSource = self;
    self.tblBoards.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated {
    //called everytime the page appears
    [super viewDidAppear:animated];
    //load board list and get info for each board
    self.boardList = [[NSMutableArray alloc] init];
    NSArray *boardIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boards"]mutableCopy];
    for (unsigned int i = 0; i < boardIDs.count; i++){
        NSNumber *bufferID = [boardIDs objectAtIndex:i];
        Board *newBoard = [Board new];
        newBoard = [DynamoInterface getSingleBoardInformation:bufferID.intValue];
        //get each board's information
        while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
        [self.aivWaiting stopAnimating];
        //add each board to the main board list
        [self.boardList addObject:newBoard];
    }
    [self.tblBoards reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    //called when the user long presses a table cell
    if (gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSInteger tagNum = cell.tag;
        infoBoard = [self.boardList objectAtIndex:tagNum];
        NSString *message = [NSString stringWithFormat:@"Organization\n %@ \n Instructions\n %@", infoBoard.Organization, infoBoard.Instructions];
        //display board info to the user, and allow them to save them board
        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:infoBoard.Board_Name
                                                           message:message
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:@"Save Board", nil];
        [infoAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    //called when an alert box button is pressed
    if (buttonIndex == 1){
        //save the board
        [DeviceInterface saveBoard:infoBoard];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.boardList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeBoardCell" forIndexPath:indexPath];
    Board *cellBoard = [self.boardList objectAtIndex:indexPath.row];
    //populate cell information
    cell.textLabel.text = cellBoard.Board_Name;
    cell.detailTextLabel.text = cellBoard.Organization;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];    //add long press gesture to each table cell
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"selectBoardSegue"]){
        //set the current board to the seleced board
        NSIndexPath *indexPath = [self.tblBoards indexPathForSelectedRow];
        Board *bufferBoard = [self.boardList objectAtIndex:indexPath.row];
        NSString *brdName = [NSString stringWithFormat:@"%@",bufferBoard.Board_ID];
        [DynamoInterface setCurrentBoard:brdName];
    }
}

@end
