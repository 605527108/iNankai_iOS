//
//  LogoutViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 22/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "LogoutViewController.h"
#import <CoreData/CoreData.h>

@interface LogoutViewController ()


@end

@implementation LogoutViewController


- (IBAction)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userLoggedIn"];
    [defaults synchronize];
    [self deleteData:@"History"];
    [self deleteData:@"Current"];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)deleteData:(NSString *)TableName
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count])
    {
        for (NSManagedObject *obj in datas)
        {
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
}

- (IBAction)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
