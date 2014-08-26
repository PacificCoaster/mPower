//
//  YMLActivitiesTableViewCell.h
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  YMLConfirmationView;

@interface YMLActivitiesTableViewCell : UITableViewCell

@property  (nonatomic, weak)  IBOutlet  UILabel              *title;
@property  (nonatomic, weak)  IBOutlet  UILabel              *subTitle;
@property  (nonatomic, weak)  IBOutlet  UILabel              *completionFraction;
@property  (nonatomic, weak)  IBOutlet  YMLConfirmationView  *confirmation;
@property  (nonatomic, assign, getter = isCompleted)   BOOL   completed;

@end
