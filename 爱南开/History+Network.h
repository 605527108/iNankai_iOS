//
//  History+Network.h
//  iiNankai
//
//  Created by SynCeokhou on 15/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "History.h"

@interface History (Network)

+ (History *)courseIntoDatabase:(NSDictionary *)courseDictionary
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
