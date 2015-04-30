//
//  LoginViewController.m
//  iNankai
//
//  Created by SynCeokhou on 18/3/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "LoginViewController.h"
#import "Network.h"
#import "User+Database.h"
#import "History+Network.h"
#import "Current+Network.h"


@interface LoginViewController () <UITextFieldDelegate , UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *studentIdField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *vadilationField;
@property (weak, nonatomic) IBOutlet UIImageView *vadilationImageView;
@property (nonatomic , strong) UIImage *vadilationImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic ,strong) User *user;
@end

@implementation LoginViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.studentIdField.delegate = self;
    self.passwordField.delegate = self;
    self.vadilationField.delegate = self;
    [self fetchImage];
}


- (void)setVadilationImage:(UIImage *)vadilationImage
{
    self.vadilationImageView.image = vadilationImage;
}


- (BOOL)fetchImage
{
    NSURL *url = [Network URLforFetchImage];
    
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:URLRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"ValidateCode Unresolved error %@, %@", error, [error userInfo]);
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.vadilationImage = image;
                });
            }
            else
            {
                [self alert:[NSString stringWithFormat:@"%ld",(long)httpResponse.statusCode]];
            }
        }
        
    }];
    [task resume];
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==self.studentIdField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField==self.passwordField) {
        [self.vadilationField becomeFirstResponder];
    } else if (textField==self.vadilationField)
    {
        [self login];
    }
    return YES;
}

- (IBAction)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signIn:(NSDictionary *)parameters
{
    NSURL *url = [Network URLforSignin];
    NSURLRequest *URLRequest = [Network HTTPPOSTRequestForURL:url withParameters:parameters];
    [self.spinner startAnimating];
    [Network sendRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self alert:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
        else
        {
            NSLog(@"%lu",(unsigned long)data.length);
            if (data.length==1138) {
                [self updateUserLoggedInFlag];
                [self fetchHistoryFirst];
                [self fetchCurrentFirst];
                [self.spinner stopAnimating];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
            }
        }
    }];
}


- (void)updateUserLoggedInFlag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"loggedIn" forKey:@"userLoggedIn"];
    [defaults synchronize];
}

- (void)fetchHistoryFirst
{
    NSURL *url = [Network URLforFetchHistoryFirst];
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    
    [Network sendRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self alert:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
        else
        {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
            
            NSError *error = NULL;
            
            NSString *pattern = @"共 (.) 页";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *match = [regex firstMatchInString:temp options:0 range:NSMakeRange(0, [temp length])];
            NSRange firstHalfRange = [match rangeAtIndex:1];
            int pages = [[temp substringWithRange:firstHalfRange] intValue];
            
            pattern = @"<td [^w>]*>([^\n]*)";
            regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            
            NSArray *matches = [regex matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];
            NSInteger bound=0;
            bound = [matches count];
            
            for (NSInteger i=1; i*8+6<bound; i++) {
                NSRange course_id = [matches[i*8] rangeAtIndex:1];
                NSRange course_name = [matches[i*8+2] rangeAtIndex:1];
                NSRange course_type = [matches[i*8+3] rangeAtIndex:1];
                NSRange course_score = [matches[i*8+4] rangeAtIndex:1];
                NSRange course_credit = [matches[i*8+5] rangeAtIndex:1];
                NSDictionary *course = [[NSDictionary alloc]initWithObjectsAndKeys:
                                        [temp substringWithRange:course_id],@"unique",
                                        [temp substringWithRange:course_name],@"name",
                                        [temp substringWithRange:course_type],@"type",
                                        [temp substringWithRange:course_score],@"score",
                                        [temp substringWithRange:course_credit],@"credit",
                                        nil];
                NSLog(@"%@",[History courseIntoDatabase:course inManagedObjectContext:self.managedObjectContext]);
            }
//            [self.managedObjectContext save:NULL];
            for (int i=1; i<pages; i++) {
                [self fetchHistory];
            }
        }
    }];
}

- (void)fetchHistory
{
        NSURL *url = [Network URLforFetchHistory];
        NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
        
        [Network sendRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
            if (error) {
                [self alert:[NSString stringWithFormat:@"%@",[error userInfo]]];
            }
            else
            {
                NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
                NSString *pattern = @"<td [^w>]*>([^\n]*)";
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
                
                NSArray *matches = [regex matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];
                NSInteger bound = [matches count];
                for (NSInteger i=1; i*8+6<bound; i++) {
                    NSRange course_id = [matches[i*8] rangeAtIndex:1];
                    NSRange course_name = [matches[i*8+2] rangeAtIndex:1];
                    NSRange course_type = [matches[i*8+3] rangeAtIndex:1];
                    NSRange course_score = [matches[i*8+4] rangeAtIndex:1];
                    NSRange course_credit = [matches[i*8+5] rangeAtIndex:1];
                    NSDictionary *course = [[NSDictionary alloc]initWithObjectsAndKeys:
                                            [temp substringWithRange:course_id],@"unique",
                                            [temp substringWithRange:course_name],@"name",
                                            [temp substringWithRange:course_type],@"type",
                                            [temp substringWithRange:course_score],@"score",
                                            [temp substringWithRange:course_credit],@"credit",
                                            nil];
                    NSLog(@"%@",[History courseIntoDatabase:course inManagedObjectContext:self.managedObjectContext]);
                }
//                [self.managedObjectContext save:NULL];
            }
        }];
}

- (void)fetchCurrentFirst
{
    NSURL *url = [Network URLforFetchCurrentFirst];
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    
    [Network sendRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self alert:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
        else
        {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
            
            NSError *error = NULL;
            
            NSString *pattern = @"共 (.) 页";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *match = [regex firstMatchInString:temp options:0 range:NSMakeRange(0, [temp length])];
            NSRange firstHalfRange = [match rangeAtIndex:1];
            NSInteger pages = [[temp substringWithRange:firstHalfRange] integerValue];
            
            pattern = @"<td [^w>]*>([^\n]*)";
            regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            
            NSArray *matches = [regex matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];
            NSInteger bound=0;
            bound = [matches count];
            
            for (NSInteger i=1; i*13+9<bound; i++) {
                NSRange course_id = [matches[i*13] rangeAtIndex:1];
                NSRange course_number = [matches[i*13+1] rangeAtIndex:1];
                NSRange course_name = [matches[i*13+3] rangeAtIndex:1];
                NSRange course_weekday = [matches[i*13+4] rangeAtIndex:1];
                NSRange course_start = [matches[i*13+5] rangeAtIndex:1];
                NSRange course_end = [matches[i*13+6] rangeAtIndex:1];
                NSRange course_location = [matches[i*13+7] rangeAtIndex:1];
                NSRange course_teacher = [matches[i*13+9] rangeAtIndex:1];
                
                NSDictionary *course = [[NSDictionary alloc]initWithObjectsAndKeys:
                                        [temp substringWithRange:course_id],@"unique",
                                        [temp substringWithRange:course_number],@"number",
                                        [temp substringWithRange:course_name],@"name",
                                        [temp substringWithRange:course_weekday],@"weekday",
                                        [temp substringWithRange:course_start],@"start",
                                        [temp substringWithRange:course_end],@"end",
                                        [temp substringWithRange:course_location],@"location",
                                        [temp substringWithRange:course_teacher],@"teacher",
                                        nil];
                [Current courseIntoDatabase:course inManagedObjectContext:self.managedObjectContext];
            }
            [self.managedObjectContext save:NULL];
            for (NSInteger i=1; i<pages; i++) {
                [self fetchCurrent];
            }
        }
    }];
}

- (void)fetchCurrent
{
    NSURL *url = [Network URLforFetchCurrent];
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    
    [Network sendRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self alert:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
        else
        {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
            NSString *pattern = @"<td [^w>]*>([^\n]*)";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            
            NSArray *matches = [regex matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];
            NSInteger bound = [matches count];
            for (NSInteger i=1; i*13+9<bound; i++) {
                NSRange course_id = [matches[i*13] rangeAtIndex:1];
                NSRange course_number = [matches[i*13+1] rangeAtIndex:1];
                NSRange course_name = [matches[i*13+3] rangeAtIndex:1];
                NSRange course_weekday = [matches[i*13+4] rangeAtIndex:1];
                NSRange course_start = [matches[i*13+5] rangeAtIndex:1];
                NSRange course_end = [matches[i*13+6] rangeAtIndex:1];
                NSRange course_location = [matches[i*13+7] rangeAtIndex:1];
                NSRange course_teacher = [matches[i*13+9] rangeAtIndex:1];
                
                NSDictionary *course = [[NSDictionary alloc]initWithObjectsAndKeys:
                                        [temp substringWithRange:course_id],@"unique",
                                        [temp substringWithRange:course_number],@"number",
                                        [temp substringWithRange:course_name],@"name",
                                        [temp substringWithRange:course_weekday],@"weekday",
                                        [temp substringWithRange:course_start],@"start",
                                        [temp substringWithRange:course_end],@"end",
                                        [temp substringWithRange:course_location],@"location",
                                        [temp substringWithRange:course_teacher],@"teacher",
                                        nil];
                [Current courseIntoDatabase:course inManagedObjectContext:self.managedObjectContext];
            }
            [self.managedObjectContext save:NULL];
        }
    }];
}

- (IBAction)login
{
        if (![self.studentIdField.text length]) {
            [self alert:@"Username required!"];
        } else if (![self.passwordField.text length]) {
            [self alert:@"Password required!"];
        } else if (![self.vadilationField.text length]) {
            [self alert:@"Vadilation required!"];
        } else {
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"operation",self.passwordField.text,@"userpwd_text",self.vadilationField.text,@"checkcode_text",@"%C8%B7+%C8%CF",@"submittype",self.studentIdField.text,@"usercode_text",nil];
            [self signIn:parameters];
        }
//    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"operation",@"012206",@"userpwd_text",self.vadilationField.text,@"checkcode_text",@"%C8%B7+%C8%CF",@"submittype",@"1210403",@"usercode_text",nil];
//    [self signIn:parameters];
}

#pragma mark - Alerts

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:msg
                               delegate:self // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancel];
}


@end
