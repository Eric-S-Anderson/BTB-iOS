//
//  SearchScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "SearchScreen.h"

@interface SearchScreen ()
@property (weak, nonatomic) IBOutlet UISearchBar *scbBoardSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblBoards;
@property NSMutableArray *allBoards;
@property NSMutableArray *filterBoards;
@property BOOL isFiltered;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivWaiting;

@end

@implementation SearchScreen

Board *infoBoard;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scbBoardSearch.delegate = self;
    self.allBoards = [[NSMutableArray alloc] init];     //initialize storage array

    self.allBoards = [DynamoInterface getAllBoardInformation:self.allBoards];
    while ([DynamoInterface getQueryStatus] < 0) {[self.aivWaiting startAnimating];}
    [self.aivWaiting stopAnimating];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText{
    
    if(searchText.length == 0){
        self.isFiltered = FALSE;
    }
    else{
        self.isFiltered = true;
        self.filterBoards = [[NSMutableArray alloc] init];
        
        for (Board *looper in self.allBoards){
            NSRange nameRange = [looper.Board_Name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [looper.Organization rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound){
                [self.filterBoards addObject:looper];
            }
        }
    }
    
    [self.tblBoards reloadData];
    
}

- (void)holdIt:(UILongPressGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan ) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSInteger tagNum = cell.tag;
        infoBoard = [self.filterBoards objectAtIndex:tagNum];
        NSString *message = [NSString stringWithFormat:@"Organization\n %@ \n Instructions\n %@", infoBoard.Organization, infoBoard.Instructions];
        
        UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:infoBoard.Board_Name
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Save Board", nil];
        [infoAlert show];
    }
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        
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
    
    UITableViewCell *cell =[self.tblBoards dequeueReusableCellWithIdentifier:@"searchPrototype" ];
    
    Board *cellBoard;
    if(self.isFiltered){
        cellBoard = [self.filterBoards objectAtIndex:indexPath.row];
    }else{
        cellBoard = [self.allBoards objectAtIndex:indexPath.row];
    }

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
    Board *bufferBoard = [self.filterBoards objectAtIndex:indexPath.row];
    NSString *brdName = [NSString stringWithFormat:@"%@",bufferBoard.Board_ID];
    [DynamoInterface setCurrentBoard:brdName];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   
}


@end
