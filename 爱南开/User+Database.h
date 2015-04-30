//
//  User+Database.h
//  iiNankai
//
//  Created by SynCeokhou on 5/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "User.h"

@interface User (Database)

+ (User *)userIntoDatabase:(NSDictionary *)userDictionary
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
