//
//  History.h
//  iiNankai
//
//  Created by SynCeokhou on 15/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface History : NSManagedObject

@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * score;
@property (nonatomic, retain) NSString * credit;

@end
