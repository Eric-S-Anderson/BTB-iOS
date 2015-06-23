//
//  DeviceInterface.m
//  Bluetooth Billboard
//
//  Created by Eric Anderson on 6/23/15.
//  Copyright (c) 2015 Sargon Partners. All rights reserved.
//

#import "DeviceInterface.h"

@implementation DeviceInterface

+(void)saveBoard:(Board*)saveMe{
    
    if (saveMe.Board_ID != nil){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSError *error;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"boardID == %@", saveMe.Board_ID];
        [request setPredicate:predicate];
        
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (array.count == 0) {
            NSManagedObject *savedBoard;
            savedBoard =
            [NSEntityDescription insertNewObjectForEntityForName:@"ManagedBoard" inManagedObjectContext:context];
            [savedBoard setValue:saveMe.Board_ID forKey:@"boardID"];
            [savedBoard setValue:saveMe.Group_ID forKey:@"groupID"];
            [savedBoard setValue:saveMe.Moderator_ID forKey:@"moderatorID"];
            [savedBoard setValue:saveMe.Organization forKey:@"organization"];
            [savedBoard setValue:saveMe.Instructions forKey:@"instructions"];
            [savedBoard setValue:saveMe.Board_Name forKey:@"boardName"];
            [context save:&error];
            NSLog(@"Board saved");
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Board Saved"
                                                                message:@"You have sucessfully saved the board.  To view this board again, click the 'Saved Boards' icon on your tab bar."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }else{
            NSLog(@"Board has already been saved.");
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Board Already Saved"
                                                                message:@"You had already saved this board.  To view this board again, click the 'Saved Boards' icon on your tab bar."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }
    }
    
}

+(void)savePost:(Post*)saveMe{
    
    NSString *pstID = [NSString stringWithFormat:@"%@", saveMe.Post_ID];
    NSString *brdID = [DynamoInterface getCurrentBoard];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *lngID = [formatter numberFromString:[brdID stringByAppendingString:pstID]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", lngID];
    [request setPredicate:predicate];
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0) {
        NSManagedObject *savedPost;
        savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedPost" inManagedObjectContext:context];
        [savedPost setValue:lngID forKey:@"postID"];
        [savedPost setValue:saveMe.Phone forKey:@"phone"];
        [savedPost setValue:saveMe.End_Date forKey:@"end_Date"];
        [savedPost setValue:saveMe.Host forKey:@"host"];
        [savedPost setValue:saveMe.Email forKey:@"email"];
        [savedPost setValue:saveMe.Address forKey:@"address"];
        [savedPost setValue:saveMe.Information forKey:@"information"];
        [savedPost setValue:saveMe.Post_Type forKey:@"post_Type"];
        [savedPost setValue:saveMe.Post_Status forKey:@"post_Status"];
        [context save:&error];
        NSLog(@"Post saved");
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Saved"
                                                            message:@"You have sucessfully saved this post.  To view this post again, click the 'Saved Posts' icon on your tab bar."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [saveAlert show];
    }else{
        NSLog(@"Post has already been saved.");
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Already Saved"
                                                            message:@"You had already saved this post.  To view this post again, click the 'Saved Posts' icon on your tab bar."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [saveAlert show];
    }
    
}

+(void)deleteBoard:(Board*)endMe{
    
    NSNumber *boardID = endMe.Board_ID;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"boardID == %@", boardID];
    [request setPredicate:predicate];
    
    NSArray *array = [[NSArray alloc] init];
    array = [context executeFetchRequest:request error:&error];
    if (array.count == 0){
        NSLog(@"Board cannot be deleted");
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Board Corrupted"
                                                           message:@"Data corruption, could not locate Board."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [delAlert show];
    }else{
        [context deleteObject:[array objectAtIndex:0]];
        NSLog(@"Board deleted");
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Board Deleted"
                                                       message:@"The board has been deleted."
                                                      delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [delAlert show];
    }
}

+(void)deletePost:(Post*)endMe{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", endMe.Post_ID];
    [request setPredicate:predicate];
    
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0){
        NSLog(@"Post cannot be deleted");
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Post Corrupted"
                                                           message:@"Data corruption, could not locate post."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [delAlert show];
    }else{
        NSLog(@"Post deleted");
        [context deleteObject:[array objectAtIndex:0]];
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Post Deleted"
                                                           message:@"The post has been deleted from your device."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [delAlert show];
    }
    
}

+(NSMutableArray*)getBoards{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSMutableArray* boards = [[NSMutableArray alloc] init];
    
    for (unsigned int i = 0; i < objects.count; i++){
        NSManagedObject *aboard = [objects objectAtIndex:i];
        Board *buffer = [Board new];
        buffer.Board_ID = [aboard valueForKey:@"boardID"];
        buffer.Group_ID = [aboard valueForKey:@"groupID"];
        buffer.Moderator_ID = [aboard valueForKey:@"moderatorID"];
        buffer.Instructions = [aboard valueForKey:@"instructions"];
        buffer.Organization = [aboard valueForKey:@"organization"];
        buffer.Board_Name = [aboard valueForKey:@"boardName"];
        [boards addObject:buffer];
    }
    
    return boards;
    
}

+(NSMutableArray*)getPosts{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSMutableArray* posts = [[NSMutableArray alloc] init];
    
    for (unsigned int i = 0; i < objects.count; i++){
        NSManagedObject *apost = [objects objectAtIndex:i];
        Post *buffer = [Post new];
        buffer.Post_ID = [apost valueForKey:@"postID"];
        buffer.Phone = [apost valueForKey:@"phone"];
        buffer.End_Date = [apost valueForKey:@"end_Date"];
        buffer.Host = [apost valueForKey:@"host"];
        buffer.Email = [apost valueForKey:@"email"];
        buffer.Address = [apost valueForKey:@"address"];
        buffer.Information = [apost valueForKey:@"information"];
        buffer.Post_Type = [apost valueForKey:@"post_Type"];
        buffer.Post_Status = [apost valueForKey:@"post_Status"];
        [posts addObject:buffer];
    }
    
    return posts;
    
}

@end
