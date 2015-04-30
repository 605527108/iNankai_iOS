//
//  User+Database.m
//  iiNankai
//
//  Created by SynCeokhou on 5/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "User+Database.h"

@implementation User (Database)

+ (User *)userIntoDatabase:(NSDictionary *)userDictionary
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    NSString *student_id = userDictionary[student_id];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"student_id = %@", student_id];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        user = [matches firstObject];
    } else {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                             inManagedObjectContext:context];
        user.password = [userDictionary valueForKeyPath:@"password"];
    }
    
    return user;
}

@end
