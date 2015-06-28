//
//  SearchScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "SearchScreen.h"

@interface SearchScreen ()

@property (weak, nonatomic) IBOutlet UISearchBar *scbBoardSearch;   //search bar
@property (weak, nonatomic) IBOutlet UITableView *tblBoards;        //table that displays search results
@property NSMutableArray *allBoards;        //array that holds all boards
@property NSMutableArray *filterBoards;     //array that holds boards that match the search input
@property BOOL isFiltered;      //bool that tests whether or not the board list is filtered
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;   //activity indicator

@end

@implementation SearchScreen

Board *infoBoard;   //holds the selected board

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //assign delegates
    self.scbBoardSearch.delegate = self;
    //initialize and populate board array
    self.allBoards = [[NSMutableArray alloc] init];
    self.allBoards = [DynamoInterface getAllBoardInformation:self.allBoards];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];    //show activity indicator while database is querying
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //called when the text in the search bar changes
    if(searchText.length == 0){
        //not filtered if there is no search input
        self.isFiltered = false;
    }else{
        //there is search input
        self.isFiltered = true;
        self.filterBoards = [[NSMutableArray alloc] init];  //initialize filtered board array
        //add boards that fit search input to filtered array
        for (Board *looper in self.allBoards){
            NSRange nameRange = [looper.Board_Name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [looper.Organization rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound){
                [self.filterBoards addObject:looper];
            }
        }
    }
    //reload table with new search results
    [self.tblBoards reloadData];
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    //called when the user long presses a table cell
    if (gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSInteger tagNum = cell.tag;
        infoBoard = [self.filterBoards objectAtIndex:tagNum];
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
    NSUInteger rowCount;
    if(self.isFiltered){
        rowCount = self.filterBoards.count;
    }else{
        rowCount = self.allBoards.count;
    }
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell =[self.tblBoards dequeueReusableCellWithIdentifier:@"searchPrototype" ];
    //check if boards are being filtered
    Board *cellBoard;
    if(self.isFiltered){
        cellBoard = [self.filterBoards objectAtIndex:indexPath.row];
    }else{
        cellBoard = [self.allBoards objectAtIndex:indexPath.row];
    }
    //populate cell information
    cell.textLabel.text = cellBoard.Board_Name;
    cell.detailTextLabel.text = cellBoard.Organization;
    UILongPressGestureRecognizer *holdIt = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdIt:)];    //add long press gesture to each table cell
    [cell addGestureRecognizer:holdIt];
    cell.tag = indexPath.row;
    return cell;
}
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //called when a table cell is selected
    Board *bufferBoard = [self.filterBoards objectAtIndex:indexPath.row];
    NSString *brdName = [NSString stringWithFormat:@"%@",bufferBoard.Board_ID];
    [DynamoInterface setCurrentBoard:brdName];  //set the current board to the selected board
}

@end
