//
//  ViewBanListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 5/29/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewBanListScreen.h"

@interface ViewBanListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblBanned;
@property (weak, nonatomic) IBOutlet UIButton *btnTypes;
- (IBAction)touchUpTypes:(id)sender;

@end

@implementation ViewBanListScreen

int currentList = 0;
int selectedRow = 0;
NSMutableArray *banType;
NSMutableArray *banHost;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tblBanned.dataSource = self;
    self.tblBanned.delegate = self;
    [self.btnTypes setTitle:(@"Banned Types") forState:UIControlStateNormal];
    self.navigationItem.title = @"Banned Hosts";
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    banType = [[NSMutableArray alloc] init];
    banType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"]mutableCopy];
    
    banHost = [[NSMutableArray alloc] init];
    banHost = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"]mutableCopy];
    
    [self.tblBanned reloadData];
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
    if (currentList == 0){
        return banHost.count;
    }else{
        return banType.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *mesStart = @"Would you like to un-ban '";
    NSString *mesEnd = @"' ?";
    selectedRow = (int)indexPath.row;
    if (currentList == 0){
        NSString *message = [mesStart stringByAppendingString:[[banHost objectAtIndex:indexPath.row] stringByAppendingString:mesEnd]];
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Un-Ban Host"
                                                           message:message
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        [banAlert show];
    }else{
        NSString *message = [mesStart stringByAppendingString:[[banType objectAtIndex:indexPath.row] stringByAppendingString:mesEnd]];
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Un-Ban Type"
                                                           message:message
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        [banAlert show];
    }
    
    
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"The %ld button was tapped.", (long)buttonIndex);
    if (buttonIndex == 1){
        if (currentList == 0){
            [banHost removeObjectAtIndex:selectedRow];
            [[NSUserDefaults standardUserDefaults] setObject:banHost forKey:@"blockedHosts"];
        }else{
            [banType removeObjectAtIndex:selectedRow];
            [[NSUserDefaults standardUserDefaults] setObject:banType forKey:@"blockedTypes"];
        }
        banType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"]mutableCopy];
        banHost = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"]mutableCopy];
        [self.tblBanned reloadData];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get information for table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeBanCell" forIndexPath:indexPath];
    if (currentList == 0){
        cell.textLabel.text = [banHost objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = [banType objectAtIndex:indexPath.row];
    }
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)touchUpTypes:(id)sender {
    
    if (currentList == 0){
        currentList = 1;
        [self.btnTypes setTitle:(@"Banned Hosts") forState:UIControlStateNormal];
        self.navigationItem.title = @"Banned Types";
    }else{
        currentList = 0;
        [self.btnTypes setTitle:(@"Banned Types") forState:UIControlStateNormal];
        self.navigationItem.title = @"Banned Hosts";
    }
    
    [self.tblBanned reloadData];
}

@end
