//
//  ViewBanListScreen.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 5/29/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "ViewBanListScreen.h"

@interface ViewBanListScreen ()
@property (weak, nonatomic) IBOutlet UITableView *tblBanned;    //tableview that displays the bans
@property (weak, nonatomic) IBOutlet UIButton *btnTypes;        //button that swithces between hosts and types
- (IBAction)touchUpTypes:(id)sender;        //called when types button is pressed

@end

@implementation ViewBanListScreen

int currentList = 0;        //identifies which list is being viewed, 0 for hosts, 1 for types
int selectedRow = 0;        //identifies which table cell has been selected
NSMutableArray *banType;    //list of banned types
NSMutableArray *banHost;    //list of banned hosts

- (void)viewDidLoad {
    //called when the view controller loads
    [super viewDidLoad];
    //assign delegates
    self.tblBanned.dataSource = self;
    self.tblBanned.delegate = self;
    //initializa button and title labels
    [self.btnTypes setTitle:(@"Banned Types") forState:UIControlStateNormal];
    self.navigationItem.title = @"Banned Hosts";
}

- (void)viewDidAppear:(BOOL)animated {
    //called everytime the page appears
    [super viewDidAppear:animated];
    //populate types list
    banType = [[NSMutableArray alloc] init];
    banType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"]mutableCopy];
    //populate hosts list
    banHost = [[NSMutableArray alloc] init];
    banHost = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"]mutableCopy];
    //reload table data after populating lists
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
    //called when a table cell is selected
    NSString *mesStart = @"Would you like to un-ban '";
    NSString *mesEnd = @"' ?";
    selectedRow = (int)indexPath.row;
    if (currentList == 0){  //check which list is being viewed
        NSString *message = [mesStart stringByAppendingString:[[banHost objectAtIndex:indexPath.row] stringByAppendingString:mesEnd]];
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Un-Ban Host"
                                                           message:message
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        //ask the user if they want to un-ban the selected host
        [banAlert show];
    }else{
        NSString *message = [mesStart stringByAppendingString:[[banType objectAtIndex:indexPath.row] stringByAppendingString:mesEnd]];
        UIAlertView *banAlert = [[UIAlertView alloc] initWithTitle:@"Un-Ban Type"
                                                           message:message
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
        //ask the user if they want to un-ban the selected type
        [banAlert show];
    }
    
    
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex{
    //called when an alert box button is pressed
    NSLog(@"The %ld button was tapped.", (long)buttonIndex);
    if (buttonIndex == 1){
        if (currentList == 0){  //check which list is currently being viewed
            [banHost removeObjectAtIndex:selectedRow];  //remove ban from list
            [[NSUserDefaults standardUserDefaults] setObject:banHost forKey:@"blockedHosts"];
        }else{
            [banType removeObjectAtIndex:selectedRow];  //remove ban from list
            [[NSUserDefaults standardUserDefaults] setObject:banType forKey:@"blockedTypes"];
        }
        //repopulate ban lists and reload table data
        banType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedTypes"]mutableCopy];
        banHost = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockedHosts"]mutableCopy];
        [self.tblBanned reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //populate table cells
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"prototypeBanCell" forIndexPath:indexPath];        //use prototype from storyboard
    if (currentList == 0){      //check which list is currently being viewed
        cell.textLabel.text = [banHost objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = [banType objectAtIndex:indexPath.row];
    }
    return cell;
}

- (IBAction)touchUpTypes:(id)sender {
    //called when the types button is pressed
    if (currentList == 0){  //check which list is currently being viewed
        currentList = 1;    //set current list to the other
        [self.btnTypes setTitle:(@"Banned Hosts") forState:UIControlStateNormal];
        self.navigationItem.title = @"Banned Types";    //change title and button labels
    }else{
        currentList = 0;    //set current list to the other
        [self.btnTypes setTitle:(@"Banned Types") forState:UIControlStateNormal];
        self.navigationItem.title = @"Banned Hosts";    //change title and button labels
    }
    //reload table data
    [self.tblBanned reloadData];
}

@end
