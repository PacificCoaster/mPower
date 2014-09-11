//
//  APHActivitiesViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

/* ViewControllers */
#import "APHActivitiesViewController.h"
#import "APHWalkingOverviewViewController.h"
#import "APHWalkingStepsViewController.h"
#import "APHWalkingResultsViewController.h"
#import "APHWalkingTaskViewController.h"
#import "APHPhonationTaskViewController.h"
#import "APHSleepQualityTaskViewController.h"
#import "APHChangedMedsTaskViewController.h"
#import "APHIntervalTappingTaskViewController.h"
#import "APHTracingObjectsTaskViewController.h"

/* Views */
#import "APHActivitiesTableViewCell.h"

/* Model */
#import "APCScheduledTask.h"

/* Other Classes */
#import "NSString+CustomMethods.h"
#import "NSManagedObject+APCHelper.h"
#import "APHStepDictionaryKeys.h"
#import "UIColor+Parkinson.h"
#import "APHParkinsonAppDelegate.h"
#import <ResearchKit/ResearchKit.h>

static  NSInteger  kNumberOfSectionsInTableView = 1;

static  NSString   *kTableCellReuseIdentifier = @"ActivitiesTableViewCell";
static  NSString   *kViewControllerTitle      = @"Activities";

@interface APCGroupedScheduledTask : NSObject

@property (nonatomic, strong) NSMutableArray *scheduledTasks;
@property (nonatomic, strong) NSString *taskType;
@property (nonatomic, strong) NSString *taskTitle;
@property (nonatomic, assign, readonly) NSUInteger completedTasksCount;
@property (nonatomic, assign, readonly, getter=isComplete) BOOL complete;

@end

@interface APHActivitiesViewController () <RKTaskViewControllerDelegate, RKStepViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *scheduledTasksArray;

@end

@implementation APHActivitiesViewController

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _scheduledTasksArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Activities";

    [self.tableView registerNib:[UINib nibWithNibName:@"APHActivitiesTableViewCell" bundle:nil] forCellReuseIdentifier:kTableCellReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  kNumberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.scheduledTasksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APHActivitiesTableViewCell  *cell = (APHActivitiesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kTableCellReuseIdentifier];
    
    id task = self.scheduledTasksArray[indexPath.row];
    
    if ([task isKindOfClass:[APCGroupedScheduledTask class]]) {
        
        cell.type = APHActivitiesTableViewCellTypeSubtitle;
        
        APCGroupedScheduledTask *groupedScheduledTask = (APCGroupedScheduledTask *)task;
        
        cell.titleLabel.text = groupedScheduledTask.taskTitle;
        
        NSUInteger tasksCount = groupedScheduledTask.scheduledTasks.count;
        NSUInteger completedTasksCount = groupedScheduledTask.completedTasksCount;
        
        cell.subTitleLabel.text = [NSString stringWithFormat:@"%lu/%lu Tasks Completed", (unsigned long)completedTasksCount, (unsigned long)tasksCount];
        
        cell.completed = groupedScheduledTask.complete;
        
    } else if ([task isKindOfClass:[APCScheduledTask class]]){
        
        cell.type = APHActivitiesTableViewCellTypeDefault;
        
        APCScheduledTask *scheduledTask = (APCScheduledTask *)task;
        
        cell.titleLabel.text = scheduledTask.task.taskTitle;
        cell.completed = scheduledTask.completed;
        
    } else{
        
    }
    
    return  cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  70.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 30)];
    [headerView.contentView setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
    
    switch (section) {
        case 0:
            headerView.textLabel.text = @"Today";
            break;
        
        default://TODO: Assert
            break;
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id task = self.scheduledTasksArray[indexPath.row];
    
    if ([task isKindOfClass:[APCGroupedScheduledTask class]]) {
        
        APCGroupedScheduledTask *groupedScheduledTask = (APCGroupedScheduledTask *)task;
        NSString *taskType = groupedScheduledTask.taskType;
        
        if ([taskType isEqualToString:@"APHTimedWalking"]) {
            
            APHWalkingTaskViewController *walkingTaskViewController = [APHWalkingTaskViewController customTaskViewController];
            
            [self presentViewController:walkingTaskViewController animated:YES completion:nil];
            
        } else if ([taskType isEqualToString:@"APHPhonation"]){
            
            APHPhonationTaskViewController *phonationTaskViewController = [APHPhonationTaskViewController customTaskViewController];
            
            [self presentViewController:phonationTaskViewController animated:YES completion:nil];
            
        } else if ([taskType isEqualToString:@"APHIntervalTapping"]){
            
            APHIntervalTappingTaskViewController *intervalTappingTaskViewController = [APHIntervalTappingTaskViewController customTaskViewController];
            
            [self presentViewController:intervalTappingTaskViewController animated:YES completion:nil];
            
        } else if ([taskType isEqualToString:@"APHCustomizableSurvey"]){
            
            APHSleepQualityTaskViewController *sleepQualityTaskViewController = [APHSleepQualityTaskViewController customTaskViewController];
            [self presentViewController:sleepQualityTaskViewController animated:YES completion:nil];
            
        } else {
            
        }
    }
}

#pragma mark - Update methods

- (IBAction)updateActivities:(id)sender
{
    [self reloadData];
    [self.refreshControl endRefreshing];
}

- (void)reloadData
{
    [self.scheduledTasksArray removeAllObjects];
    
    NSFetchRequest * request = [APCScheduledTask request];
//    request.predicate = [NSPredicate predicateWithFormat:@"dueOn == %@",[NSDate date]];
//    request.predicate = [NSPredicate predicateWithFormat:@"(dueOn >= %@) AND (dueOn <= %@)", startDate, endDate];
    
    NSError * error;
    NSManagedObjectContext *context = ((APHParkinsonAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext;
    
    NSArray *unsortedScheduledTasks = [context executeFetchRequest:request error:&error];
     //((APHParkinsonAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate  scheduledTasksDueFrom:<#(NSDate *)#> toDate:<#(NSDate *)#> sortDescriptors:<#(NSArray *)#>
    
//    self.scheduledTasksArray = [NSMutableArray arrayWithArray:unsortedScheduledTasks];
    [self groupSimilarTasks:unsortedScheduledTasks];
    
    [self.tableView reloadData];
}

#pragma mark - Sort and Group Task

- (void)groupSimilarTasks:(NSArray *)unsortedScheduledTasks
{
    NSMutableArray *taskTypesArray = [[NSMutableArray alloc] init];
    
    /* Get the list of different task types */
    for (APCScheduledTask *scheduledTask in unsortedScheduledTasks) {
        NSString *taskType = scheduledTask.task.taskType;
        
        if (![taskTypesArray containsObject:taskType]) {
            [taskTypesArray addObject:taskType];
        }
    }
    
    
    for (NSString *taskType in taskTypesArray) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"task.taskType == %@", taskType];
        
        NSArray *filteredTasksArray = [unsortedScheduledTasks filteredArrayUsingPredicate:predicate];
        
        if (filteredTasksArray.count > 1) {
            APCScheduledTask *scheduledTask = filteredTasksArray.firstObject;
            APCGroupedScheduledTask *groupedTask = [[APCGroupedScheduledTask alloc] init];
            groupedTask.scheduledTasks = [NSMutableArray arrayWithArray:filteredTasksArray];
            groupedTask.taskType = taskType;
            groupedTask.taskTitle = scheduledTask.task.taskTitle;
            
            [self.scheduledTasksArray addObject:groupedTask];
        } else{
            
            [self.scheduledTasksArray addObject:filteredTasksArray.firstObject];
        }
    }
}

@end

/*
 --------------------------------------------------
 APCGroupedSCheduledTask
 --------------------------------------------------
 */

@implementation APCGroupedScheduledTask

- (instancetype)init
{
    if (self = [super init]) {
        _scheduledTasks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"Task Title : %@\nTask Type : %@\nTasks : %@", self.taskTitle, self.taskType, self.scheduledTasks];
}

- (NSUInteger)completedTasksCount
{
    NSUInteger count = 0;
    
    for (APCScheduledTask *scheduledTask in self.scheduledTasks) {
        if (scheduledTask.completed.boolValue) {
            count++;
        }
    }
    
    return count;
}

- (BOOL)isComplete
{
    return ([self completedTasksCount]/self.scheduledTasks.count);
}

@end
