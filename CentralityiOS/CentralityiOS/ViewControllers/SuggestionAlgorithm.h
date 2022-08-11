//
//  SuggestionAlgorithm.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/11/22.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"
#import "DateTools/DateTools.h"
#import "CentralityHelpers.h"
#import "Parse/Parse.h"
#import "SuggestionObject.h"

@interface SuggestionAlgorithm : UIViewController
+ (void)checkAllSuggestionRules:(TaskObject*)task;
+ (PFQuery*)querySuggestions;

// Uncategorized Suggestion Methods
+(void)addTaskToLargestCategory:(SuggestionObject*)suggestion;
+(void)addTaskToNewestCategory:(SuggestionObject*)suggestion;

// Undated / Overdue Suggestion Methods
+ (void)extendDueDate: (SuggestionObject*)suggestion;

@end

