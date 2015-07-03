//
//  Current+Network.m
//  iiNankai
//
//  Created by SynCeokhou on 16/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "Current+Network.h"

@implementation Current (Network)

+ (Current *)courseIntoDatabase:(NSDictionary *)courseDictionary
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Current *course = nil;
    NSString *course_id = courseDictionary[@"unique"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Current"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", course_id];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        course = [matches firstObject];
    } else {
        course = [NSEntityDescription insertNewObjectForEntityForName:@"Current"
                                               inManagedObjectContext:context];
        course.unique = course_id;
        course.name = [courseDictionary valueForKeyPath:@"name"];
        course.number = [courseDictionary valueForKeyPath:@"number"];
        course.weekday = [courseDictionary valueForKeyPath:@"weekday"];
        course.start = [courseDictionary valueForKeyPath:@"start"];
        course.end = [courseDictionary valueForKeyPath:@"end"];
        course.location = [courseDictionary valueForKeyPath:@"location"];
        course.teacher = [courseDictionary valueForKeyPath:@"teacher"];
    }
    return course;
}

+ (void)loadCoursesFromArray:(NSArray *)courses intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *course in courses) {
        [self courseIntoDatabase:course inManagedObjectContext:context];
    }
}

@end
