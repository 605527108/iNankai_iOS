//
//  HistoryCourseCDTVC.m
//  iiNankai
//
//  Created by SynCeokhou on 25/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "HistoryCourseCDTVC.h"
#import "HistoryTableViewCell.h"
#import "LoginViewController.h"
#import "LogoutViewController.h"
#import "Login.h"

@interface HistoryCourseCDTVC ()

@property (strong,nonatomic) NSArray *courses;

@end

@implementation HistoryCourseCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![Login isLogin]) {
        LoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginController.managedObjectContext = self.managedObjectContext;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:loginController animated:true completion:^{
                [self performFetch];
            }];
        });
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:YES selector:@selector(localizedStandardCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - UITableViewDataSource

- (HistoryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"History Cell"];
    if (cell == nil) {
        cell = [[HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"History Cell"];
    }
    History *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell updateUI:course.name withCredit:course.credit withScore:course.score withType:course.type];
    return cell;
}


- (IBAction)refresh:(UIBarButtonItem *)sender {
    LoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginController.managedObjectContext = self.managedObjectContext;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:loginController animated:true completion:nil];
    });
}

#pragma mark - Navigation

//- (void)prepareViewController:(id)vc
//                     forSegue:(NSString *)segueIdentifer
//                fromIndexPath:(NSIndexPath *)indexPath
//{
//    History *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    if ([vc isKindOfClass:[HistoryViewController class]]) {
//        HistoryViewController *nvc = (HistoryViewController *)vc;
//        nvc.item = item;
//    }
//}
//
//// boilerplate
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSIndexPath *indexPath = nil;
//    if ([sender isKindOfClass:[UITableViewCell class]]) {
//        indexPath = [self.tableView indexPathForCell:sender];
//    }
//    [self prepareViewController:segue.destinationViewController
//                       forSegue:segue.identifier
//                  fromIndexPath:indexPath];
//}
//
//// boilerplate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id detailvc = [self.splitViewController.viewControllers lastObject];
//    if ([detailvc isKindOfClass:[UINavigationController class]]) {
//        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
//        [self prepareViewController:detailvc
//                           forSegue:nil
//                      fromIndexPath:indexPath];
//    }
//}

@end
