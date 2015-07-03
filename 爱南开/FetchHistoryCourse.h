//
//  FetchHistoryCourse.h
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "History+Network.h"


@interface FetchHistoryCourse : NSObject

+ (void)fetchHistoryPageNum:(NSManagedObjectContext *)managedObjectContext;

+ (void)fetchHistoryCourse:(NSManagedObjectContext *)managedObjectContext;

+ (void)deleteHistoryData:(NSManagedObjectContext *)managedObjectContext;

+ (void)evaluateCourse;

@end
