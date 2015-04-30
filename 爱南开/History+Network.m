//
//  History+Network.m
//  iiNankai
//
//  Created by SynCeokhou on 15/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "History+Network.h"

@implementation History (Network)

+ (History *)courseIntoDatabase:(NSDictionary *)courseDictionary
         inManagedObjectContext:(NSManagedObjectContext *)context;
{
    History *course = nil;
    NSString *course_id = courseDictionary[@"unique"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", course_id];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        course = [matches firstObject];
    } else {
        course = [NSEntityDescription insertNewObjectForEntityForName:@"History"
                                             inManagedObjectContext:context];
        course.unique = course_id;
        course.name = [courseDictionary valueForKeyPath:@"name"];
        course.type = [courseDictionary valueForKeyPath:@"type"];
        course.score = [courseDictionary valueForKeyPath:@"score"];
        course.credit = [courseDictionary valueForKeyPath:@"credit"];
    }
    return course;
}

@end
