//
//  DataViewController.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 3/25/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "DataViewController.h"
#import "Post.h"

@interface DataViewController ()
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnPost;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtTester;


@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.myCentralManager =
    [[CBCentralManager alloc] initWithDelegate:self.myCentralManager.delegate queue:nil options:nil];
    
    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
    
    
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    //NSLog(@"Discovered %@", peripheral.name);
    self.txtTester.text = peripheral.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}
- (IBAction)clickPost:(id)sender {
    int pid = 73921234;
    Post *tpost = [Post new];
    [tpost populate:pid];
    while (tpost.Host == nil) {
        
    }
    self.txtTester.text = tpost.Host;
    //self.txtTester.text = @"button works!";
    
    
}


@end
