//
//  SearchScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/3/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "SearchScreen.h"
#import "Board.h"

@interface SearchScreen ()
@property (weak, nonatomic) IBOutlet UISearchBar *scbBoardSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblBoards;
@property NSMutableArray *allBoards;
@property NSMutableArray *filterBoards;
@property int queryStatus;
@property BOOL isFiltered;

@end

@implementation SearchScreen


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scbBoardSearch.delegate = self;
    
    //aws credentials
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:ed50d9e9-fd87-4188-b4e2-24a974ee68e9"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //aws object mapper
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    //aws scan expression
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @10;
    
    [Post setTableName:@"Board"];    //set table name and key
    [Post setHashKey:@"Board_ID"];
    self.allBoards = [[NSMutableArray alloc] init];     //initialize storage array
    
    self.queryStatus = -1;           //reset query status
    
    [[dynamoDBObjectMapper scan:[Board class] expression:scanExpression]
     continueWithSuccessBlock:^id(BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
             self.queryStatus = 1;   //error code
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
             self.queryStatus = 2;   //exception code
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (Board *buffer in paginatedOutput.items) {
                 [self.allBoards addObject:buffer];   //store each result
             }
             self.queryStatus = 0;   //success code
             NSLog(@"Scan Sucessful");
         }
         return nil;
     }];
    
    while (self.queryStatus < 0){}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText{
    
    if(searchText.length == 0)
    {
        self.isFiltered = FALSE;
    }
    else
    {
        self.isFiltered = true;
        self.filterBoards = [[NSMutableArray alloc] init];
        
        for (Board *looper in self.allBoards)
        {
            NSRange nameRange = [looper.Board_Name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [looper.Organization rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [self.filterBoards addObject:looper];
            }
        }
    }
    
    [self.tblBoards reloadData];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger rowCount;
    if(self.isFiltered)
        rowCount = self.filterBoards.count;
    else
        rowCount = self.allBoards.count;
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =[self.tblBoards dequeueReusableCellWithIdentifier:@"searchPrototype" ];
    
    Board *cellBoard;
    if(self.isFiltered)
        cellBoard = [self.filterBoards objectAtIndex:indexPath.row];
    else
        cellBoard = [self.allBoards objectAtIndex:indexPath.row];
    

    cell.textLabel.text = cellBoard.Board_Name;
    cell.detailTextLabel.text = cellBoard.Organization;

    return cell;
}
 


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"searchBoardSegue"]){
        //set the current board to the seleced board
        NSIndexPath *indexPath = [self.tblBoards indexPathForSelectedRow];
        Board *bufferBoard = [self.filterBoards objectAtIndex:indexPath.row];
        NSString *brdName = [NSString stringWithFormat:@"%d",bufferBoard.Board_ID];
        [Post setCurrentBoard:brdName];
    }
}


@end
