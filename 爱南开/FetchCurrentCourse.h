//
//  FetchCurrentCourse.h
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Current+Network.h"

@interface FetchCurrentCourse : NSObject

+ (void)fetchCurrentCourse:(NSManagedObjectContext *)managedObjectContext;

+ (void)fetchCurrentPageNum:(NSManagedObjectContext *)managedObjectContext;

+ (void)deleteCurrentData:(NSManagedObjectContext *)managedObjectContext;

@end
