//
//  Current+Network.h
//  iiNankai
//
//  Created by SynCeokhou on 16/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "Current.h"

@interface Current (Network)

+ (Current *)courseIntoDatabase:(NSDictionary *)courseDictionary
         inManagedObjectContext:(NSManagedObjectContext *)context;

@end
