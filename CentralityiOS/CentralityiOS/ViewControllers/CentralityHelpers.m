//
//  CentralityHelpers.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/28/22.
//

#import "CentralityHelpers.h"
#import "Parse/Parse.h"
#import "TaskObject.h"
@interface CentralityHelpers ()

@end

@implementation CentralityHelpers

+ (void)showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage currentVC:(UIViewController*)currentVC{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [currentVC presentViewController:alert animated:YES completion:nil];
}

+ (NSMutableArray*)getArrayOfObjectIds:(NSMutableArray*)userArray{
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    for (PFUser* user in userArray) {
        [returnArray addObject:user.objectId];
    }
    return returnArray;
}

+ (void) updateLabel:(UILabel*)label newText:(NSString*)newText isHidden:(BOOL)isHidden{
    label.text = newText;
    label.hidden = isHidden;
}

+ (NSArray<PFUser*>*)removeUser:(PFUser*)user FromArray:(NSArray<PFUser*>*)arrayToCheck{
    for (int i = 0; i < arrayToCheck.count; i++) {
        if ([arrayToCheck[i].objectId isEqualToString:user.objectId]){
            NSMutableArray *copyOfArrayToCheck = [arrayToCheck mutableCopy];
            [copyOfArrayToCheck removeObjectAtIndex:i];
            arrayToCheck = copyOfArrayToCheck;
        }
    }
    return arrayToCheck;
}

+ (NSArray<PFUser*>*)addUser:(PFUser*)user ToArray:(NSArray<PFUser*>*)receivingArray{
    NSMutableArray *copyOfReceivingArray = [receivingArray mutableCopy];
    [copyOfReceivingArray addObject:user];
    receivingArray = copyOfReceivingArray;
    return receivingArray;
}

+ (PFQuery*)queryForUsersCompletedTasks{
    PFQuery *completedTasks = [PFQuery queryWithClassName:kTaskClassName];
    [completedTasks whereKey:kByOwnerQueryKey equalTo:PFUser.currentUser];
    [completedTasks whereKeyExists:kByDateCompletedKey];
    [completedTasks whereKey:kIsCompletedKey equalTo:@(YES)];
    return completedTasks;
}

// Queries tasks due within 24 hour margin of error.
// Not necessarily tasks due in the same day
// When query called elsewhere, make sure to modify results to make them more accurate
+ (PFQuery*)queryForTasksRoughDueByDate{
    PFQuery *dueTasks = [PFQuery queryWithClassName:kTaskClassName];
    [dueTasks whereKey:kByOwnerQueryKey equalTo:PFUser.currentUser];
    [dueTasks whereKeyExists:kByDueDateKey];
    [dueTasks whereKey:kByDueDateKey lessThan:[[NSDate date]dateByAddingDays:1]];
    [dueTasks whereKey:kByDueDateKey greaterThan:[[NSDate date]dateBySubtractingDays:1]];
    return dueTasks;
}

+ (PFQuery*)queryForUsersCategories{
    PFQuery *alluserCategories = [PFQuery queryWithClassName:kByCategoryClassName];
    [alluserCategories whereKey:kByOwnerQueryKey equalTo:PFUser.currentUser];
    [alluserCategories orderByDescending:kByCreatedAtQueryKey];
    return alluserCategories;
}

+ (CategoryObject*)getMostRecentCategory{
    PFQuery *userCategories = [self queryForUsersCategories];
    CategoryObject* mostRecentCategory = [userCategories getFirstObject];
    return mostRecentCategory;
}

+ (CategoryObject*)getLargestCategory{
    PFQuery *userCategories = [self queryForUsersCategories];
    NSArray<CategoryObject*>* allUserCategories = [userCategories findObjects];
    CategoryObject *largestCategory = allUserCategories[0];
    for (NSInteger i = 0; i < allUserCategories.count; i++) {
        if (allUserCategories[i].numberOfTasksInCategory > largestCategory.numberOfTasksInCategory){
            largestCategory = allUserCategories[i];
        }
    }
    return largestCategory;
}

+ (NSInteger)getAverageCompletionTimeInDays:(CategoryObject*)category{
    PFQuery* userTasksQuery = [self queryForUsersCompletedTasks];
    NSArray* completedTasks = [userTasksQuery findObjects];
    NSInteger averageAccumulator = 0;
    NSInteger totalCountedTasks = 0;
    NSInteger calculatedAverage = 0;
    
    if ([category fetchIfNeeded]){
        for (TaskObject* task in completedTasks) {
            if ([task.category.objectId isEqualToString:category.objectId]){
                NSInteger completionInterval = [task.dateCompleted daysFrom:task.createdAt];
                averageAccumulator += completionInterval;
                totalCountedTasks++;
            }
        }
    }
    else{
        for (TaskObject* task in completedTasks) {
            NSInteger completionInterval = [task.dateCompleted daysFrom:task.createdAt];
            averageAccumulator += completionInterval;
            totalCountedTasks++;
        }
    }
    calculatedAverage = averageAccumulator / totalCountedTasks;
    
    return calculatedAverage;
}

+ (NSMutableDictionary<NSString*, PFUser*> *)userDictionaryFromArray :(NSMutableArray*)userArray{
    NSMutableDictionary<NSString*, PFUser*>* userDict = [[NSMutableDictionary alloc] init];
    NSArray<PFUser*>* keysFromArray = userArray;
    for (PFUser* user in keysFromArray) {
        userDict[user.objectId] = user;
    }
    return userDict;
}

@end
