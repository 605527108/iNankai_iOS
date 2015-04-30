//
//  Current.h
//  iiNankai
//
//  Created by SynCeokhou on 16/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Current : NSManagedObject

@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * weekday;
@property (nonatomic, retain) NSString * start;
@property (nonatomic, retain) NSString * end;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * teacher;
@property (nonatomic, retain) NSString * number;

@end
