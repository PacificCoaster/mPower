//
//  APHSleepQualityTaskViewController.h
//  Parkinson
//
//  Created by Henry McGilton on 9/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ResearchKit/ResearchKit.h>

#import "APHSetupTaskViewController.h"

@interface APHSleepQualityTaskViewController : APHSetupTaskViewController

+ (instancetype)customTaskViewController: (APCScheduledTask*) scheduledTask;

@end
