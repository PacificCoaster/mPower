//
//  APHEditSectionsViewController.m
//  Parkinson
//
//  Created by Ramsundar Shandilya on 9/8/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import "APHEditSectionsViewController.h"

static NSString * const SectionNamesCellIdentifier = @"SectionNamesCell";

@interface APHEditSectionsViewController ()

@property (nonatomic, strong) NSMutableArray *sectionsOrder;
@property (weak, nonatomic) IBOutlet UITableView *sectionNamesTableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@end

@implementation APHEditSectionsViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _sectionsOrder = [NSMutableArray arrayWithArray:[defaults objectForKey:kDashboardSectionsOrder]];
        
        self.title = NSLocalizedString(@"Edit Dashboard", nil);
    }
    
    return self;
}

#pragma mark - LifeCycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.sectionNamesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SectionNamesCellIdentifier];
    self.sectionNamesTableView.editing = YES;
    self.sectionNamesTableView.tableHeaderView = self.headerView;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneTapped)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sectionsOrder.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionNamesCellIdentifier forIndexPath:indexPath];
    
    NSInteger cellType = ((NSNumber *)[self.sectionsOrder objectAtIndex:indexPath.row]).integerValue;
    
    switch (cellType) {
        case kDashboardSectionStudyOverView:
        {
            cell.textLabel.text = @"Study Overview";
        }
            break;
        case kDashboardSectionActivity:
        {
            cell.textLabel.text = @"Activity";
        }
            break;
        case kDashboardSectionBloodCount:
        {
            cell.textLabel.text = @"Blood Count";
        }
            break;
        case kDashboardSectionMedications:
        {
            cell.textLabel.text = @"Medications";
        }
            break;
        case kDashboardSectionInsights:
        {
            cell.textLabel.text = @"Insights";
        }
            break;
        case kDashboardSectionAlerts:
        {
            cell.textLabel.text = @"Alerts";
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPat
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSNumber *sectionData = [self.sectionsOrder objectAtIndex:sourceIndexPath.row];
    
    [self.sectionsOrder removeObjectAtIndex:sourceIndexPath.row];
    [self.sectionsOrder insertObject:sectionData atIndex:destinationIndexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.sectionsOrder forKey:kDashboardSectionsOrder];
    [defaults synchronize];
}

#pragma mark - UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Selector Actions

- (void)doneTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
