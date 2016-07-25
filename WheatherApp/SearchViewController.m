//
//  SearchViewController.m
//  WheatherApp
//
//  Created by test on 6/13/16.
//  Copyright © 2016 test. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation SearchViewController{
    NSMutableArray *cityNameArray,*countryNameArray;
    NSDictionary *json,*location;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    cityNameArray=[[NSMutableArray alloc]init];
    countryNameArray=[[NSMutableArray alloc]init];
    self.myTableView.hidden=NO;
    NSString *searchQuery=[NSString stringWithFormat:@"http://api.worldweatheronline.com/premium/v1/search.ashx?key=a05c24ec448d426787555224160406&q=%@&format=json",searchBar.text];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:searchQuery] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSArray *array=[json valueForKey:@"search_api"];
        NSArray *result=[array valueForKey:@"result"];
        [self fetchingCityName:result];
        [self fetchingCountryName:result];
        
        [self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
        
    }];
    [dataTask resume];
    
    
}

-(void)reload{
    
    [_myTableView reloadData];
}



-(void)fetchingCountryName:(NSArray*)result
{
    NSArray *countryName=[result valueForKey:@"country"];
    
    NSArray *namesOfArrayOfArray=[countryName valueForKey:@"value"];
    NSLog(@"%@",namesOfArrayOfArray);
    
    for (NSArray *name in namesOfArrayOfArray) {
        NSString *singleName=[name objectAtIndex:0];
        [countryNameArray addObject:singleName];
    }
    
    NSLog(@"%@",countryNameArray);
}


-(void)fetchingCityName:(NSArray*)result
{
    NSArray *areaName=[result valueForKey:@"areaName"];
    
    NSArray *namesOfArrayOfArray=[areaName valueForKey:@"value"];
    NSLog(@"%@",namesOfArrayOfArray);
    
    for (NSArray *name in namesOfArrayOfArray) {
        NSString *singleName=[name objectAtIndex:0];
        [cityNameArray addObject:singleName];
    }
    
    NSLog(@"%@",cityNameArray);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cityNameArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text=[cityNameArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text=[countryNameArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedAreaName=[cityNameArray objectAtIndex:indexPath.row];
    location=[NSDictionary dictionaryWithObject:selectedAreaName forKey:@"location"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"sendData" object:nil userInfo:location];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
