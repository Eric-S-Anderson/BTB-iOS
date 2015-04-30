//
//  ViewBoardListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewBoardListScreen.h"

@interface ViewBoardListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblBoards;
@property NSMutableArray *boardList;
@property NSMutableArray *scanResults;

@end

@implementation ViewBoardListScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //initializations
    self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.tblBoards.dataSource = self;
    self.tblBoards.delegate = self;
    self.boardList = [[NSMutableArray alloc] init];
    self.scanResults = [[NSMutableArray alloc] init];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    //interface function for CBCentralManager
    //ensure that the ble is on before attempting to scan
    if (central.state == CBCentralManagerStatePoweredOn){
        NSLog(@"BLE ON");
        [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
    }
    
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    //called when the scan finds a ble device
    BOOL foundIt = false;
    for (int i = 0; i < self.scanResults.count; i++) {
        if ([[self.scanResults objectAtIndex:(i)] isEqualToString:(peripheral.name)]) {
            foundIt = true;     //check if device has already been found
        }
    }
    if (!foundIt) {
        //add device to the list and repopulate the table
        NSLog(@"Discovered %@", peripheral.name);
        //CLBeacon *beacon;
        
        if (peripheral.name != nil){
            [self.scanResults addObject:peripheral.name];
            if ([peripheral.name isEqualToString:@"BLEbeacon116826"]){
                Board *foundBoard = [DynamoInterface getSingleBoardInformation:[@"776655" intValue]];
                [self.boardList addObject:foundBoard];
            }else if ([peripheral.name isEqualToString:@"Bluetooth6127"]){
                Board *foundBoard = [DynamoInterface getSingleBoardInformation:[@"213411" intValue]];
                [self.boardList addObject:foundBoard];
            }
            [self.tblBoards reloadData];
        }
    }
    
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
    return [self.boardList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeBoardCell" forIndexPath:indexPath];
    Board *cellBoard = [self.boardList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = cellBoard.Board_Name;
    cell.detailTextLabel.text = cellBoard.Organization;
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
