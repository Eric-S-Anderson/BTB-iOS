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
    //save a board to the device
    if (saveMe.Board_ID != nil){    //board is populated
        //initialize context
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSError *error;
        //initialize fetch request
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        //initialize entity
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
        [request setEntity:entity];
        //set search predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"boardID == %@", saveMe.Board_ID];
        [request setPredicate:predicate];
        //store result of search
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (array.count == 0) { //board was not previously saved
            //create a new managed board from passed board
            NSManagedObject *savedBoard;
            savedBoard = [NSEntityDescription insertNewObjectForEntityForName:@"ManagedBoard"inManagedObjectContext:context];
            [savedBoard setValue:saveMe.Board_ID forKey:@"boardID"];
            [savedBoard setValue:saveMe.Group_ID forKey:@"groupID"];
            [savedBoard setValue:saveMe.Moderator_ID forKey:@"moderatorID"];
            [savedBoard setValue:saveMe.Organization forKey:@"organization"];
            [savedBoard setValue:saveMe.Instructions forKey:@"instructions"];
            [savedBoard setValue:saveMe.Board_Name forKey:@"boardName"];
            //save the managed board to the device
            [context save:&error];
            NSLog(@"Board saved");
            //display an alert box to the user that the board has been saved
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Board Saved"
                                                                message:@"You have sucessfully saved the board.  To view this board again, click the 'Saved Boards' icon on your tab bar."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [saveAlert show];
        }else{  //board was previously saved
            NSLog(@"Board has already been saved.");
            //display an alert box to the user that the board has already been saved
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
    //save a post to the device
    //create a composite id for the post (board id + post id)
    NSString *pstID = [NSString stringWithFormat:@"%@", saveMe.Post_ID];
    NSString *brdID = [DynamoInterface getCurrentBoard];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *lngID = [formatter numberFromString:[brdID stringByAppendingString:pstID]];
    //initialize context
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    //initialize fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //initialize entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    [request setEntity:entity];
    //set search predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", lngID];
    [request setPredicate:predicate];
    //store search result
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0){      //post not previously saved
        //initialize managed post from passed post
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
        //save post to the device
        [context save:&error];
        NSLog(@"Post saved");
        //display an alert box that the post has been saved
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Saved"
                                                            message:@"You have sucessfully saved this post.  To view this post again, click the 'Saved Posts' icon on your tab bar."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [saveAlert show];
    }else{  //post has been previously saved
        NSLog(@"Post has already been saved.");
        //display an alert box that the post has already been saved
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Post Already Saved"
                                                            message:@"You had already saved this post.  To view this post again, click the 'Saved Posts' icon on your tab bar."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [saveAlert show];
    }
}

+(void)deleteBoard:(Board*)endMe{
    //delete a board from the device
    //initialize context
    NSNumber *boardID = endMe.Board_ID;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    //initialize fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //initialize entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
    [request setEntity:entity];
    //set search predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"boardID == %@", boardID];
    [request setPredicate:predicate];
    //store search results
    NSArray *array = [[NSArray alloc] init];
    array = [context executeFetchRequest:request error:&error];
    if (array.count == 0){  //board not found
        NSLog(@"Board cannot be deleted");
        //display an alert box that the board cannot be located
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Board Corrupted"
                                                           message:@"Data corruption, could not locate Board."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [delAlert show];
    }else{  //found board on device
        //delete board from the device
        [context deleteObject:[array objectAtIndex:0]];
        NSLog(@"Board deleted");
        //display an alert box that the board has been deleted
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Board Deleted"
                                                       message:@"The board has been deleted."
                                                      delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [delAlert show];
    }
}

+(void)deletePost:(Post*)endMe{
    //delete a post from the device
    //initialize context
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    //initialize fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //initialize entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    [request setEntity:entity];
    //set search predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@", endMe.Post_ID];
    [request setPredicate:predicate];
    //store search results
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0){  //post not found
        NSLog(@"Post cannot be deleted");
        //display an alert box that the post cannot be found
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Post Corrupted"
                                                           message:@"Data corruption, could not locate post."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [delAlert show];
    }else{  //post was located
        NSLog(@"Post deleted");
        //delete post from the device
        [context deleteObject:[array objectAtIndex:0]];
        //display an alert box that the post has been deleted
        UIAlertView *delAlert = [[UIAlertView alloc] initWithTitle:@"Post Deleted"
                                                           message:@"The post has been deleted from your device."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [delAlert show];
    }
}

+(NSMutableArray*)getBoards{
    //returns an array of all boards saved to the device
    //initialize context
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    //initialize entity
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ManagedBoard" inManagedObjectContext:context];
    //initialize fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    //store found boards
    NSArray *objects = [context executeFetchRequest:request error:&error];
    NSMutableArray* boards = [[NSMutableArray alloc] init];
    for (unsigned int i = 0; i < objects.count; i++){
        //transition managed boards to boards
        NSManagedObject *aboard = [objects objectAtIndex:i];
        Board *buffer = [Board new];
        buffer.Board_ID = [aboard valueForKey:@"boardID"];
        buffer.Group_ID = [aboard valueForKey:@"groupID"];
        buffer.Moderator_ID = [aboard valueForKey:@"moderatorID"];
        buffer.Instructions = [aboard valueForKey:@"instructions"];
        buffer.Organization = [aboard valueForKey:@"organization"];
        buffer.Board_Name = [aboard valueForKey:@"boardName"];
        //store boards in array
        [boards addObject:buffer];
    }
    return boards;
}

+(NSMutableArray*)getPosts{
    //returns an array of all posts saved to the device
    //initialize context
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    //initialize entity
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ManagedPost" inManagedObjectContext:context];
    //initialize fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    //store found posts
    NSArray *objects = [context executeFetchRequest:request error:&error];
    NSMutableArray* posts = [[NSMutableArray alloc] init];
    for (unsigned int i = 0; i < objects.count; i++){
        //transition managed posts to posts
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
        //store posts in an array
        [posts addObject:buffer];
    }
    return posts;
}

@end