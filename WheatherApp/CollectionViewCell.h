//
//  CollectionViewCell.h
//  WheatherApp
//
//  Created by test on 6/13/16.
//  Copyright © 2016 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *dayOfTheWeek;
@property (strong, nonatomic) IBOutlet UILabel *dayOfTemperature;
@property (strong, nonatomic) IBOutlet UIImageView *weatherIcon;
@property (strong, nonatomic) IBOutlet UILabel *daysOfMaxTemperature;

@end
