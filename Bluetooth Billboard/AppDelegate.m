//
//  AppDelegate.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 3/25/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

CLLocationManager *locManager;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions{
    // Override point for customization after application launch.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;   //reset badge number
    //register notification priviledges
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil]];
    }
    //request location service usage from device/user
    [locManager requestAlwaysAuthorization];
    [locManager startUpdatingLocation];
    //UUID that will be monitored
    NSUUID *myUUID = [[NSUUID alloc] initWithUUIDString:@"B8FB1855-0644-4FFC-94E7-CBA10CFC4087"];
    // Create the beacon region to be monitored.
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:myUUID identifier:@"BTBRegion"];
    beaconRegion.notifyEntryStateOnDisplay = true;
    beaconRegion.notifyOnEntry = true;
    // Register the beacon region with the location manager.
    locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;
    [locManager startMonitoringForRegion:beaconRegion];
    [locManager startRangingBeaconsInRegion:beaconRegion];
    //initialize user default arrays
    NSDictionary *boards = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init]
        forKey:@"boards"];
    NSDictionary *hosts = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init] forKey:@"blockedHosts"];
    NSDictionary *types = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init] forKey:@"blockedTypes"];
    //register user default arrays
    [[NSUserDefaults standardUserDefaults] registerDefaults:boards];
    [[NSUserDefaults standardUserDefaults] registerDefaults:hosts];
    [[NSUserDefaults standardUserDefaults] registerDefaults:types];
    //set starting board (default welcome board)
    [DynamoInterface setCurrentBoard:@"000000"];
    return YES;
}

- (void)requestAlwaysAuthorization{
    //request permission to always have location services available to the application
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied){
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        //display an alert box to alter location settings
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined){
        [locManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //alert box button was pressed
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"Resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Entered background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"Entered foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"Became active");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"Terminate");
}

#pragma mark - Region Monitoring

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    //called when a beacon matching the UUID has been found
    if (beacons.count > 0) {
        //get formatted string from major and minor ids of the beacon
        CLBeacon *foundBeacon = [beacons objectAtIndex:0];
        NSString *foundMajor = [NSString stringWithFormat:@"%@", foundBeacon.major];
        NSString *foundMinor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
        NSString *foundBoard = [foundMajor stringByAppendingString:foundMinor];
        //initializations
        bool foundIT = false;
        NSMutableArray *alreadyFound = [[NSMutableArray alloc] init];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *boardID = [formatter numberFromString:foundBoard];
        //load beacons that have already been found
        alreadyFound = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boards"]mutableCopy];
        //check if the current beacon matches any that have already been found
        for (unsigned int i = 0; i < alreadyFound.count; i++){
            NSNumber *bufferID = [alreadyFound objectAtIndex:i];
            if (bufferID.intValue == boardID.intValue){
                foundIT = true;     //beacon already found
            }
        }
        if (!foundIT){  //beacon was not previously found
            //add becaon to the list of found beacons
            [alreadyFound addObject:boardID];
            NSLog(@"Added board %@", foundBoard);
            //notify the user that a beacon (board) has been found
            UILocalNotification* notifyBoard = [[UILocalNotification alloc] init];
            notifyBoard.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
            notifyBoard.alertBody = @"You've found a new billboard!";
            notifyBoard.timeZone = [NSTimeZone defaultTimeZone];
            notifyBoard.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:notifyBoard];
        }else{  //beacon was previously found
            //removed log because it writes constantly
            //NSLog(@"Board %@ already added", foundBoard);
        }
        //save user default array of found baords
        [[NSUserDefaults standardUserDefaults] setObject:alreadyFound forKey:@"boards"];
    }else{  //region was found without a beacon being ranged
        NSLog(@"Found beacon region %@", region.identifier);
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    //notify debugger when device has entered a new region
    NSLog(@"Entered region %@", region.identifier);
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

- (void)saveContext{
    //save context, core data
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]){
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    //returns managed object context
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    //get persistent store coordinator
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    //returns the managed object model for the application.
        //if the model doesn't already exist, it is created from the application's model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BTB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    //returns the persistent store coordinator for the application.
        //if the coordinator doesn't already exist, it is created and the application's store added to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    //initialize storage url and store coordinator
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Bluetooth Billboard.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                             URL:storeURL options:nil error:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();    //couldn't initialize properly
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory{
    //returns the URL to the application's Documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
