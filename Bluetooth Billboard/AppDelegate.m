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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge
                                                                                                              categories:nil]];
    }
    
    //request location service usage from device/user
    [locManager requestAlwaysAuthorization];
    [locManager startUpdatingLocation];
    
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
    
    NSDictionary *boards = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init] forKey:@"boards"];
    NSDictionary *hosts = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init] forKey:@"blockedHosts"];
    NSDictionary *types = [NSDictionary dictionaryWithObject:[[NSMutableArray alloc] init] forKey:@"blockedTypes"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:boards];
    [[NSUserDefaults standardUserDefaults] registerDefaults:hosts];
    [[NSUserDefaults standardUserDefaults] registerDefaults:types];
    
    [DynamoInterface setCurrentBoard:@"000000"];
    
    return YES;
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Region Monitoring

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    if (beacons.count > 0) {
        
        CLBeacon *foundBeacon = [beacons objectAtIndex:0];
        NSString *foundMajor = [NSString stringWithFormat:@"%@", foundBeacon.major];
        NSString *foundMinor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
        NSString *foundBoard = [foundMajor stringByAppendingString:foundMinor];
        
        
        
        bool foundIT = false;
        NSMutableArray *alreadyFound = [[NSMutableArray alloc] init];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *boardID = [formatter numberFromString:foundBoard];
        
        alreadyFound = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boards"]mutableCopy];
        for (unsigned int i = 0; i < alreadyFound.count; i++){
            NSNumber *bufferID = [alreadyFound objectAtIndex:i];
            if (bufferID.intValue == boardID.intValue){
                foundIT = true;
            }
        }
        if (!foundIT){
            [alreadyFound addObject:boardID];
            NSLog(@"Added board %@", foundBoard);
            
            UILocalNotification* notifyBoard = [[UILocalNotification alloc] init];
            notifyBoard.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
            notifyBoard.alertBody = @"You've found a new billboard!";
            notifyBoard.timeZone = [NSTimeZone defaultTimeZone];
            notifyBoard.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:notifyBoard];
            
        }else{
            //NSLog(@"Board %@ already added", foundBoard);
        }
        [[NSUserDefaults standardUserDefaults] setObject:alreadyFound forKey:@"boards"];
    }else{
        NSLog(@"Found beacon region %@", region.identifier);
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
    NSLog(@"Entered region %@", region.identifier);
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
    if (state == CLRegionStateInside) {
        
        NSLog(@"Entered region %@", region);
        //Start Ranging
        //[manager startRangingBeaconsInRegion:region];
    }
    
    else{
        
        //Stop Ranging
        //[manager stopRangingBeaconsInRegion:region];
    }
    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BTB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Bluetooth Billboard.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
