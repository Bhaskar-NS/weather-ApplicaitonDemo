//
//  ViewController.m
//  WheatherApp
//
//  Created by test on 6/4/16.
//  Copyright © 2016 test. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"

@interface ViewController ()<UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewOutlet;
@property (strong, nonatomic) IBOutlet UILabel *countryName;
@property (strong, nonatomic) IBOutlet UILabel *weatherDesctionLbl;

@property (strong, nonatomic) IBOutlet UILabel *cityName;
@property (strong, nonatomic) IBOutlet UILabel *currentTemp;
@property (strong, nonatomic) IBOutlet UIImageView *weatherImgIcon;


@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong,nonatomic) IBOutletCollection(UIImageView) NSArray *currentConditionImg;
@property (strong, nonatomic) IBOutlet UIImageView *imgOutlet;

@property (strong,nonatomic) NSString *displayCity,*displayCountry,*currentTempF,*weatherImageUrl,*weatherDescription,*location,*feelStr;
@property (strong,nonatomic) NSMutableArray *citites;
@property (strong,nonatomic) NSString *url;

@property (assign,nonatomic) int i;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *feel;

@property (strong,nonatomic) IBOutletCollection(UILabel) NSArray *currentTempFar;
@end

@implementation ViewController
{
    NSMutableDictionary *json,*json1;
    NSMutableArray *arrayData;
    NSMutableArray *dates,*weatherIconUrlMutableArray;
    NSDate *today;
    NSMutableArray *cityNameArray,*perDayImages;
    NSArray *tempF,*differentDaysTempF,*differentDaysMaxTempF;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    weatherIconUrlMutableArray=[NSMutableArray array];
    perDayImages =[[NSMutableArray alloc]init];
    //cityNameArray=[NSMutableArray array];
    //[self.activityIndicator startAnimating];
    self.i=0;
    _citites=[[NSMutableArray alloc]initWithObjects:@"NewYork",@"Chennai", nil];
    self.url=@"http://api.worldweatheronline.com/premium/v1/weather.ashx?key=a05c24ec448d426787555224160406&q=Bangalore&format=json&num_of_days=5";
    [self getSession:self.url];
}

-(void)getSession:(NSString*)url
{
    
    [_activityIndicator startAnimating];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", json);
        
        
        arrayData=[json valueForKey:@"data"];
        
        NSArray *dateArry=[arrayData valueForKey:@"weather"];
        NSArray *numberOfDates=[dateArry valueForKey:@"date"];
        NSLog(@"%@",numberOfDates);
        NSLog(@"%lu",(unsigned long)[numberOfDates count]);
        [self displayNumberOfDays:arrayData];
        [self weatherForDifferentDays:arrayData];
        [self fetchingAndDisplayingLocationDetails:arrayData];
        [self fetchingAndDisplayingCurrentConditionImage:arrayData];
        [self changeBackGroundImage];
        
        self.countryName.text=self.displayCountry;
        self.cityName.text=self.displayCity;
        self.currentTemp.text=self.currentTempF;
        self.feel.text=self.feelStr;
        self.weatherDesctionLbl.text=self.weatherDescription;
        //[self.collectionViewOutlet reloadData];
        self.collectionViewOutlet.delegate=self;
        self.collectionViewOutlet.dataSource=self;
        [self.activityIndicator stopAnimating];
        
        [self performSelectorOnMainThread:@selector(reloadCollectionView) withObject:nil waitUntilDone:NO];
    }];
    [dataTask resume];

}

-(void)reloadCollectionView
{
    [self.collectionViewOutlet reloadData];
}

-(void)displayNumberOfDays:(NSArray *)datesArray
{
    dates=[NSMutableArray array];
    NSArray *dateArry=[datesArray valueForKey:@"weather"];
    NSArray *numberOfDates=[dateArry valueForKey:@"date"];
    NSLog(@"%@",numberOfDates);
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone *outputTimezone=[NSTimeZone localTimeZone];
    [myFormatter setTimeZone:outputTimezone];
    for (int i=0; i<[numberOfDates count]; i++) {
        
        
        today = [myFormatter dateFromString:[numberOfDates objectAtIndex:i]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE"];
        NSString *dayOfWeek=[dateFormatter stringFromDate:today];

        [dates addObject:dayOfWeek];

    }
     NSLog(@"%@",dates);
       
    
}

-(void)weatherForDifferentDays:(NSArray*) differenDaysWeather
{
    NSArray *weather=[differenDaysWeather valueForKey:@"weather"];
    differentDaysTempF=[weather valueForKey:@"mintempC"];
    differentDaysMaxTempF=[weather valueForKey:@"maxtempC"];
        NSLog(@"%@",weatherIconUrlMutableArray);
    
    NSLog(@"%@",differentDaysTempF);
//    for (int i=0; i<[_currentConditionImg count]; i++) {
//        [[_currentConditionImg objectAtIndex:i] setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[weatherIconUrlMutableArray objectAtIndex:i] componentsJoinedByString:@""]]]]];
    //}
    perDayImages=[[NSMutableArray alloc]init];
    
    for (int i=0; i<[weather count]; i++) {
        NSArray *perDayweatherIconUrl=[[[[weather objectAtIndex:i] valueForKey:@"hourly"] valueForKey:@"weatherIconUrl"] valueForKey:@"value"];
        [perDayImages addObject:[[perDayweatherIconUrl objectAtIndex:i] componentsJoinedByString:@""]];
    }
    NSLog(@"%@",perDayImages);
}

-(void)perdayWeatherConditionImages:(NSArray *)arr
{
 
    NSArray *weatherIconUrlArray=[arr valueForKey:@"hourly"];
    NSArray *iconUrlArry=[weatherIconUrlArray valueForKey:@"weatherIconUrl"];
    NSArray *urlIcon=[iconUrlArry valueForKey:@"value"];
    [weatherIconUrlMutableArray addObject:[urlIcon objectAtIndex:1]];
}
-(void)fetchingAndDisplayingLocationDetails:(NSArray *)location
{
    NSArray *locationDetailsArray=[location valueForKey:@"request"];
        NSArray *cityCountry=[locationDetailsArray valueForKey:@"query"];
    NSString *locationDetails=[cityCountry objectAtIndex:0];
    NSLog(@"%@",locationDetails);
        NSString *match=@",";
        NSString *cityNameStr;
        NSString *countryNameStr;
        NSScanner *scanner = [NSScanner scannerWithString:locationDetails];
        [scanner scanUpToString:match intoString:&cityNameStr];
        [scanner scanString:match intoString:nil];
        countryNameStr = [locationDetails substringFromIndex:scanner.scanLocation];
        self.displayCity=cityNameStr;
        self.displayCountry=countryNameStr;
    
    
}
- (IBAction)changeLocation:(id)sender {
    
    [self swipePerformAction];
}

-(void)swipePerformAction
{
    
    
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    NSString *apiUrl=[self replaceLocation:[_citites objectAtIndex:self.i]];
    
    [self getSession:apiUrl];
    self.i++;
    
    if ([_citites count] == self.i) {
        self.i=0;
    }
    

}
-(void)searchPerformAction:(NSString*)srchStr
{
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    NSString *apiUrl=[self replaceLocation:srchStr];
    
    [self getSession:apiUrl];
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:apiUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        json1 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        
//        
//        NSLog(@"%@", json1);
//        
//        arrayData=[json1 valueForKey:@"data"];
//        [self weatherForDifferentDays:arrayData];
//        [self fetchingAndDisplayingLocationDetails:arrayData];
//        [self fetchingAndDisplayingCurrentConditionImage:arrayData];
//        
//        self.countryName.text=self.displayCountry;
//        self.cityName.text=self.displayCity;
//        self.currentTemp.text=self.currentTempF;
//        self.weatherDesctionLbl.text=self.weatherDescription;
//        self.feel.text=_feelStr;
//        [self.activityIndicator stopAnimating];
//    }];
//    [dataTask resume];
}

-(void)fetchingAndDisplayingCurrentConditionImage:(NSArray *)imageDetails

{
    NSString *weatherIcon=[[[[[imageDetails valueForKey:@"current_condition"] valueForKey:@"weatherIconUrl"] valueForKey:@"value"] objectAtIndex:0] componentsJoinedByString:@""];
    self.weatherImgIcon.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:weatherIcon]]];

    NSArray *climate=[imageDetails valueForKey:@"current_condition"];
    
    tempF=[climate valueForKey:@"temp_C"];
    self.currentTempF=[tempF objectAtIndex:0];
    
    NSArray *feelsLikeArray=[climate valueForKey:@"FeelsLikeC"];
    NSString *feel=[feelsLikeArray objectAtIndex:0];
    self.feelStr=feel;
    self.weatherDescription=[[[[[imageDetails valueForKey:@"current_condition"] valueForKey:@"weatherDesc"] valueForKey:@"value"] objectAtIndex:0] componentsJoinedByString:@""];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)replaceLocation:(NSString *)changeLocation
{
    [self.citites addObject:changeLocation];
    NSString *newUrl=[NSString stringWithFormat:@"http://api.worldweatheronline.com/premium/v1/weather.ashx?key=a05c24ec448d426787555224160406&q=%@&format=json&num_of_days=4",changeLocation];
    NSLog(@"%@",newUrl);
    return newUrl;
}

-(void)changeBackGroundImage
{
    NSString *img=self.weatherDescription;
    NSLog(@"%lu",(unsigned long)[img length]);
    NSArray *weatherDesc=[[NSArray alloc]initWithObjects:@"Partly Cloudy ",@"Haze ",@"Clear ",@"Sunny",nil];
    NSLog(@"%lu",(unsigned long)[img length]);
    NSLog(@"%@",img);
    for (NSString *str in weatherDesc) {
    NSLog(@"%d",[str isEqualToString:_weatherDescription]);
        if ([str isEqualToString:_weatherDescription]) {
            self.imgOutlet.image=[UIImage imageNamed:str];
            break;
        }
        else
        {
            self.imgOutlet.image=[UIImage imageNamed:@"nature"];
        }
    }
}
- (IBAction)searchController:(id)sender {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedLocation:) name:@"sendData" object:nil];
    [self performSegueWithIdentifier:@"search" sender:nil];
}

-(void)receivedLocation:(NSNotification *)notification
{
    NSString *loc=[[notification userInfo] valueForKey:@"location"];
    NSLog(@"%@",loc);
    self.url=[NSString stringWithFormat:@"http://api.worldweatheronline.com/premium/v1/weather.ashx?key=a05c24ec448d426787555224160406&q=%@&format=json&num_of_days=4",loc];
        NSString *trimmedSpace=[self.url stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self getSession:trimmedSpace];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [dates count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.dayOfTheWeek.text=[dates objectAtIndex:indexPath.row];
    cell.dayOfTemperature.text=[differentDaysTempF objectAtIndex:indexPath.row];
    cell.daysOfMaxTemperature.text=[differentDaysMaxTempF objectAtIndex:indexPath.row];
    cell.weatherIcon.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[perDayImages objectAtIndex:indexPath.row]]]];
    return cell;
}
@end
