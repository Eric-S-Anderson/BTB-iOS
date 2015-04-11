//
//  ViewBoardListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 4/5/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewBoardListScreen.h"
#import "ViewPostListScreen.h"

@interface ViewBoardListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblBoards;
@property NSMutableArray *boardList;

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
    for (int i = 0; i < self.boardList.count; i++) {
        if ([[self.boardList objectAtIndex:(i)] isEqualToString:(peripheral.name)]) {
            foundIt = true;     //check if device has already been found
        }
    }
    if (!foundIt) {
        //add device to the list and repopulate the table
        [self.boardList addObject:peripheral.name];
        NSLog(@"Discovered %@", peripheral.name);
        [self.tblBoards reloadData];
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
    NSString *cellPeripheral = [self.boardList objectAtIndex:indexPath.row];
    cell.textLabel.text = cellPeripheral;
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"selectBoardSegue"]){
        //set the current board to the seleced board
        NSIndexPath *indexPath = [self.tblBoards indexPathForSelectedRow];
        [Post setCurrentBoard:[self.boardList objectAtIndex:indexPath.row]];
    }
    
}


@end
