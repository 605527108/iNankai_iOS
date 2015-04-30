//
//  WeatherViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 19/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "WeatherViewController.h"
#import "Network.h"

@interface WeatherViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loading;
@property (weak, nonatomic) IBOutlet UILabel *time1;
@property (weak, nonatomic) IBOutlet UILabel *time2;
@property (weak, nonatomic) IBOutlet UILabel *time3;
@property (weak, nonatomic) IBOutlet UILabel *time4;

@property (weak, nonatomic) IBOutlet UILabel *temp1;
@property (weak, nonatomic) IBOutlet UILabel *temp2;
@property (weak, nonatomic) IBOutlet UILabel *temp3;
@property (weak, nonatomic) IBOutlet UILabel *temp4;

@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;

@end

@implementation WeatherViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loadingIndicator startAnimating];
    UIImage *background = [UIImage imageNamed:@"background.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    [self updateWeatherInfo];
}

- (void)updateWeatherInfo
{
    NSURL *url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/forecast?lat=39.14&lon=117.18"];
    NSURLRequest *request = [Network HTTPGETRequestForURL:url];
    [Network sendRequest:request withCompetionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self alert:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
        else
        {
            NSError *error;
            NSDictionary *weatherData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"%@",error.userInfo);
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUI:weatherData];
                });
            }
        }
    }];
}

- (void)updateUI:(NSDictionary *)weatherData
{
    NSArray *predictData  = [weatherData valueForKeyPath:@"list"];
    if (predictData) {
        self.loading.text = nil;
        self.loadingIndicator.hidden = YES;
        [self.loadingIndicator stopAnimating];
        NSDictionary *main = [predictData[0] valueForKeyPath:@"main"];
        float temperature = [[main valueForKeyPath:@"temp"] floatValue];
        temperature = round(temperature - 273.15);
        self.temperature.text =[NSString stringWithFormat:@"%d℃",(int)temperature];
        
        NSArray *weather = [predictData[0] valueForKeyPath:@"weather"];
        NSInteger condition = [[weather[0] valueForKeyPath:@"id"] intValue];
        NSString *icon = [weather[0] valueForKeyPath:@"icon"];
        BOOL nightTime = [icon rangeOfString:@"target"].length > 0;
        [self updateWeatherIcon:condition withNightTime:nightTime withIndex:0];
        self.location.text = @"Tianjin";
        
        for (int index=1;index<5;index++)
        {
            NSDictionary *main = [predictData[index] valueForKeyPath:@"main"];
            float temperature = [[main valueForKeyPath:@"temp"] floatValue];
            
            if(temperature)
            {
                temperature = round(temperature - 273.15);
                if (index==1) {
                    self.temp1.text = [NSString stringWithFormat:@"%d℃",(int)temperature];
                }
                else if (index==2) {
                    self.temp2.text = [NSString stringWithFormat:@"%d℃",(int)temperature];
                }
                else if (index==3) {
                    self.temp3.text = [NSString stringWithFormat:@"%d℃",(int)temperature];
                }
                else if (index==4) {
                    self.temp4.text = [NSString stringWithFormat:@"%d℃",(int)temperature];
                }
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"HH:mm";
                NSInteger rawDate = [[predictData[index] valueForKeyPath:@"dt"] intValue];
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:rawDate];
                NSString *forecastTime = [dateFormatter stringFromDate:date];
                if (index==1) {
                    self.time1.text = forecastTime;
                }
                else if (index==2) {
                    self.time2.text = forecastTime;
                }
                else if (index==3) {
                    self.time3.text = forecastTime;
                }
                else if (index==4) {
                    self.time4.text = forecastTime;
                }
                
                NSArray *weather = [predictData[index] valueForKeyPath:@"weather"];
                NSInteger condition = [[weather[0] valueForKeyPath:@"id"] intValue];
                NSString *icon = [weather[0] valueForKeyPath:@"icon"];
                BOOL nightTime = [icon rangeOfString:@"n"].length > 0;
                [self updateWeatherIcon:condition withNightTime:nightTime withIndex:index];
            }
            else {
                continue;
            }
        }
    }
    else {
        self.loading.text = @"Weather info is not available!";
    }
}

- (void)updatePictures:(NSInteger)index withName:(NSString *)name
{
    if (index==0) {
        self.icon.image = [UIImage imageNamed:name];
    }
    if (index==1) {
        self.image1.image = [UIImage imageNamed:name];
    }
    if (index==2) {
        self.image2.image = [UIImage imageNamed:name];
    }
    if (index==3) {
        self.image3.image = [UIImage imageNamed:name];
    }
    if (index==4) {
        self.image4.image = [UIImage imageNamed:name];
    }
}

- (void)updateWeatherIcon:(NSInteger) condition withNightTime:(BOOL)nightTime withIndex:(NSInteger)index
{
    // Thunderstorm
    if (condition < 300) {
        if(nightTime) {
            [self updatePictures:index withName:@"tstorm1_night"];
        } else {
            [self updatePictures:index withName:@"tstorm1"];
        }
    }
    // Drizzle
    else if (condition < 500) {
        [self updatePictures:index withName:@"light_rain"];
    }
    // Rain / Freezing rain / Shower rain
    else if (condition < 600) {
        [self updatePictures:index withName:@"shower3"];
    }
    // Snow
    else if (condition < 700) {
        [self updatePictures:index withName:@"snow4"];
    }
    // Fog / Mist / Haze / etc.
    else if (condition < 771) {
        if (nightTime) {
            [self updatePictures:index withName:@"fog_night"];
        } else {
            [self updatePictures:index withName:@"fog"];
        }
    }
    // Tornado / Squalls
    else if (condition < 800) {
        [self updatePictures:index withName:@"tstorm3"];
    }
    // Sky is clear
    else if (condition == 800) {
        if (nightTime){
            [self updatePictures:index withName:@"sunny_night"];
        }
        else {
            [self updatePictures:index withName:@"sunny"];
        }
    }
    // few / scattered / broken clouds
    else if (condition < 804) {
        if (nightTime){
            [self updatePictures:index withName:@"cloudy2_night"];
        }
        else{
            [self updatePictures:index withName:@"cloudy2"];
        }
    }
    // overcast clouds
    else if (condition == 804) {
        [self updatePictures:index withName:@"overcast"];
    }
    // Extreme
    else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
        [self updatePictures:index withName:@"tstorm3"];
    }
    // Cold
    else if (condition == 903) {
        [self updatePictures:index withName:@"snow5"];
    }
    // Hot
    else if (condition == 904) {
        [self updatePictures:index withName:@"sunny"];

    }
    // Weather condition is not available
    else {
        [self updatePictures:index withName:@"dunno"];
    }
}





#pragma mark - Alerts

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Weather"
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


@end
