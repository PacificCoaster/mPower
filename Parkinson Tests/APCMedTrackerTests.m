//
//  APCMedTrackerTests.m
//  Parkinson
//
//  Created by Ron Conescu on 2/17/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <APCAppCore/APCAppCore.h>
//#import "APCMedicationDataStorageEngine.h"
//#import "APCMedicationWeeklySchedule.h"
//#import "APCMedicationLozenge.h"
//#import "APCMedTrackerMedicationSchedule+Helper.h"
//#import "APCAppDelegate.h"

@interface APCMedTrackerTests : XCTestCase

@end

@implementation APCMedTrackerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.


//    [APCMedicationDataStorageEngine startup];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void) testCreateOneScheduleAsynchronously
{
    NSArray *daysOfTheWeek = @[ @(1), @(5) ];
    NSNumber *timesPerDay = @(3);
    NSOperationQueue *someQueue = [NSOperationQueue new];
    someQueue.name = @"Waiting for 'create' op to finish...";

    [APCMedTrackerMedicationSchedule newScheduleWithMedication: nil
                                                        dosage: nil
                                                         color: nil
                                                 daysOfTheWeek: daysOfTheWeek
                                           numberOfTimesPerDay: timesPerDay
                                               andUseThisQueue: someQueue
                                              toDoThisWhenDone: ^(id createdObject,
                                                                  NSTimeInterval operationDuration,
                                                                  NSManagedObjectContext *context,
                                                                  NSManagedObjectID *scheduleId)
     {
         APCMedTrackerMedicationSchedule *schedule = createdObject;
         NSLog (@"Created a schedule!  Creation time = %f seconds.  Schedule = %@" , operationDuration, schedule);

         [self okLetsPlayWithTheSchedule: schedule
                         fromThisContext: context
                              withThisId: scheduleId];

     }];

    // This is required, or else the code may not get a chance to complete.
    // This suggests we may need to ask the system to let the app stay awake
    // 'til our CoreData stuff has finished writing.  Are we doing that?
    NSLog (@"Waiting for schedule-generator to finish...");
    [NSThread sleepForTimeInterval: 60];
    NSLog (@"Done waiting.  Hopefully exiting the app.");
}

- (void) okLetsPlayWithTheSchedule: (APCMedTrackerMedicationSchedule *) schedule
                   fromThisContext: (NSManagedObjectContext *) context
                        withThisId: (NSManagedObjectID *) scheduleId
{
    NSLog (@"The schedule is: timesPerDay: %@", schedule.numberOfTimesPerDay);
    NSLog (@"The schedule is: zeroBasedDaysOfTheWeek: %@", schedule.zeroBasedDaysOfTheWeek);
    NSLog (@"The schedule is: color: %@", schedule.color.name);
    NSLog (@"The schedule is: dosage: %@", schedule.dosage.name);
    NSLog (@"The schedule is: meds: %@", schedule.medicine.name);
    NSLog (@"The schedule is: Created on: %@", schedule.dateStartedUsing);
    NSLog (@"The schedule is: object ID is temporary: %@", scheduleId.isTemporaryID ? @"YES" : @"NO");
//    schedule.t


    APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *masterContextIThink = appDelegate.dataSubstrate.persistentContext;
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    localContext.parentContext = masterContextIThink;
    id thingy = [localContext objectWithID: scheduleId];

    if ([thingy isKindOfClass: [APCMedTrackerMedicationSchedule class]])
    {
        NSLog (@"And after retrieving a new one, we got: %@", thingy);
        
        APCMedTrackerMedicationSchedule *retrievedSchedule = thingy;
        NSLog (@"Is it active? [%@]", retrievedSchedule.isActive ? @"YES" : @"NO");
        NSLog (@"timesPerDay:  [%@]", retrievedSchedule.numberOfTimesPerDay);
        NSLog (@"date created:  [%@]", retrievedSchedule.dateStartedUsing);
        NSLog (@"temp ID:  [%d]", retrievedSchedule.objectID.isTemporaryID);
    }
    else
    {
        NSLog (@"Hey!  We couldn't retrieve that ID from the database as a Schedule!");
    }

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([APCMedTrackerMedicationSchedule class])];
//    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"objectId", "*"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: NSStringFromSelector( @selector (dateStartedUsing))
                                                              ascending: YES]];

//    [localContext objectWithID: ]

    NSError *error = nil;
    NSArray *allSchedules = [localContext executeFetchRequest: request error: &error];
    NSLog (@"All schedules in the system are now: %@", allSchedules);

}

- (void) testRetrieveAllEntitiesWithoutProvidingThem
{
    // Create a context
    APCAppDelegate *appDelegate = (APCAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *masterContextIThink = appDelegate.dataSubstrate.persistentContext;
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    localContext.parentContext = masterContextIThink;

    // Simplest-possible requests
    NSFetchRequest  *scheduleRequest        = nil,
                    *medRequest             = nil,
                    *possibleDosageRequest  = nil,
                    *colorsRequest          = nil,
                    *doseHistoryRequest     = nil;

    NSArray *schedules          = nil,
            *meds               = nil,
            *possibleDosages    = nil,
            *colors             = nil,
            *doseHistory        = nil;

    NSError *scheduleRequestError = nil,
            *medRequestError = nil,
            *possibleDosageRequestError = nil,
            *colorsRequestError = nil,
            *doseHistoryRequestError = nil;

    scheduleRequest         = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([APCMedTrackerMedicationSchedule class])];
    medRequest              = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([APCMedTrackerMedication class])];
    possibleDosageRequest   = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([APCMedTrackerPossibleDosage class])];
    colorsRequest           = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([APCMedTrackerScheduleColor class])];
    doseHistoryRequest      = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass ([APCMedTrackerActualDosageTaken class])];

    schedules       = [localContext executeFetchRequest: scheduleRequest error: &scheduleRequestError];
    meds            = [localContext executeFetchRequest: medRequest error: &medRequestError];
    possibleDosages = [localContext executeFetchRequest: possibleDosageRequest error: &possibleDosageRequestError];
    colors          = [localContext executeFetchRequest: colorsRequest error: &colorsRequestError];
    doseHistory     = [localContext executeFetchRequest: doseHistoryRequest error: &doseHistoryRequestError];

    NSLog (@"scheduleRequestError:  %@",        scheduleRequestError);
    NSLog (@"medRequestError:  %@",             medRequestError);
    NSLog (@"possibleDosageRequestError:  %@",  possibleDosageRequestError);
    NSLog (@"colorsRequestError:  %@",          colorsRequestError);
    NSLog (@"doseHistoryRequestError:  %@",     doseHistoryRequestError);

    NSLog (@"Schedules retrieved:\n----------\n%@\n----------",         schedules);
    NSLog (@"Meds retrieved:\n----------\n%@\n----------",              meds);
    NSLog (@"PossibleDosages retrieved:\n----------\n%@\n----------",   possibleDosages);
    NSLog (@"Colors retrieved:\n----------\n%@\n----------",            colors);
    NSLog (@"Dose History retrieved:\n----------\n%@\n----------",      doseHistory);
}

//- (void) testAllFeatures
//{
//    NSArray *medications = [APCMedicationDataStorageEngine allMedications];
//    NSArray *colors = [APCMedicationDataStorageEngine allColors];
//    NSArray *dosages = [APCMedicationDataStorageEngine allDosages];
//    NSArray *sampleSchedules = [APCMedicationDataStorageEngine allSampleSchedules];
//    NSArray *sampleDosesTaken = [APCMedicationDataStorageEngine allSampleDosesTaken];
//
//
//    NSLog (@"The medications on disk are: %@", medications);
//    NSLog (@"The colors on disk are: %@", colors);
//    NSLog (@"The dosages on disk are: %@", dosages);
//    NSLog (@"The sample schedules on disk are: %@", sampleSchedules);
//    NSLog (@"The sample doses on disk are: %@", sampleDosesTaken);
//
//    NSArray *daysOfTheWeek = @[ @(1), @(5) ];
//    NSNumber *timesPerDay = @(3);
//
//    APCMedicationWeeklySchedule *schedule = [APCMedicationWeeklySchedule weeklyScheduleWithMedication: medications [0]
//                                                                                               dosage: dosages [0]
//                                                                                                color: colors [1]
//                                                                                        daysOfTheWeek: daysOfTheWeek
//                                                                                  numberOfTimesPerDay: timesPerDay];
//
//    NSLog (@"For a new schedule:");
//    NSLog (@"- Medication name: %@", schedule.medicationName);
//    NSLog (@"- Schedule color: %@", schedule.color);
//    NSLog (@"- Frequencies and Days: %@", schedule.frequenciesAndDays);
//    NSLog (@"- Dosage value: %@", schedule.dosageValue);
//    NSLog (@"- Dosage Text: %@", schedule.dosageText);
//
//    [schedule save];
//
//    NSArray *lozenges = schedule.blankLozenges;
//    NSLog (@"The blank lozenges are:  %@", lozenges);
//
//    APCMedicationLozenge *lozenge = lozenges [0];
//    [lozenge takeDoseNowAndSave];
//    NSLog (@"After taking one dose, the first lozenge is:  %@", lozenge);
//
//    NSLog (@"Waiting 3 seconds so the 'save' has a chance to finish...");
//    [NSThread sleepForTimeInterval: 3];
//    NSLog (@"...done!");
//}

@end










