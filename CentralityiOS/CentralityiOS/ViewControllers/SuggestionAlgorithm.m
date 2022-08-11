//
//  SuggestionAlgorithm.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/11/22.
//

#import "SuggestionAlgorithm.h"


@interface SuggestionAlgorithm ()

@end

@implementation SuggestionAlgorithm
+ (void)checkAllSuggestionRules:(TaskObject*)task{
    [self checkForOverdueTasks:task];
    [self checkForUndatedTasks:task];
    [self checkForUncategorizedTasks:task];
}

+ (void)checkForOverdueTasks:(TaskObject*)task{
    if ([task.dueDate isEarlierThan:NSDate.date] && ![NSDate isSameDay:task.dueDate asDate:NSDate.date] && task.isCompleted == NO){
        [self createUniqueSuggestion:task :Overdue];
    }
}

+ (void)checkForUndatedTasks:(TaskObject*)task{
    if (!task.dueDate){
        [self createUniqueSuggestion:task :Undated];
    }
}

+ (void)createUniqueSuggestion:(TaskObject*)task :(SuggestionType)suggestionType{
    [[self querySuggestionsOfType:suggestionType Task:task] countObjectsInBackgroundWithBlock:^(int numOfduplicates, NSError * _Nullable error) {
                if (numOfduplicates == 0){
                    SuggestionObject *suggestion = [SuggestionObject new];
                    suggestion.associatedTask = task;
                    suggestion.suggestionType = suggestionType;
                    suggestion.owner = PFUser.currentUser;
                    [suggestion saveInBackground];
                }
    }];
}

+ (void)checkForUncategorizedTasks:(TaskObject*)task{
    if (!task.category){
        [self createUniqueSuggestion:task :Uncategorized];
    }
}

+ (PFQuery*)querySuggestions{
    PFQuery *receivedSuggestionsQuery = [PFQuery queryWithClassName:kSuggestionClassName];
    [receivedSuggestionsQuery whereKey:kByOwnerQueryKey equalTo:PFUser.currentUser];
    return receivedSuggestionsQuery;
}

+ (PFQuery*)querySuggestionsOfType:(SuggestionType)suggestionType Task:(TaskObject*)task{
    PFQuery *specificSuggestionQuery = [PFQuery queryWithClassName:kSuggestionClassName];
    [specificSuggestionQuery whereKey:kByOwnerQueryKey equalTo:PFUser.currentUser];
    [specificSuggestionQuery whereKey:kAssociatedTaskKey equalTo:task];
    [specificSuggestionQuery whereKey:kSuggestionTypeKey equalTo:@(suggestionType)];
    return specificSuggestionQuery;
}

+ (void)extendDueDate: (SuggestionObject*)suggestion{
    suggestion.associatedTask.dueDate = [NSDate.date dateByAddingDays:[CentralityHelpers getAverageCompletionTimeInDays:suggestion.associatedTask.category]];
}

+(void)addTaskToLargestCategory:(SuggestionObject*)suggestion{
    if ([suggestion.associatedTask.category fetchIfNeeded]){
        suggestion.associatedTask.category.numberOfTasksInCategory--;
    }
    suggestion.associatedTask.category = [CentralityHelpers getLargestCategory];
    suggestion.associatedTask.category.numberOfTasksInCategory++;
}

+(void)addTaskToNewestCategory:(SuggestionObject*)suggestion{
    if ([suggestion.associatedTask.category fetchIfNeeded]){
        suggestion.associatedTask.category.numberOfTasksInCategory--;
    }
    suggestion.associatedTask.category = [CentralityHelpers getMostRecentCategory];
    suggestion.associatedTask.category.numberOfTasksInCategory++;
}

@end
