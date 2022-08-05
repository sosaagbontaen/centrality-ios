//
//  CentralityHelpers.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "CategoryObject.h"
#import "DateTools.h"

@interface CentralityHelpers : UIViewController
//Frequently Used Methods across different View Controllers
+ (void)showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage currentVC:(UIViewController*)currentVC;
+ (NSMutableArray*)getArrayOfObjectIds:(NSMutableArray*)userArray;
+ (void) updateLabel:(UILabel*)label newText:(NSString*)newText isHidden:(BOOL)isHidden;
+ (NSArray<PFUser*>*)removeUser:(PFUser*)user FromArray:(NSArray<PFUser*>*)arrayToCheck;
+ (NSArray<PFUser*>*)addUser:(PFUser*)user ToArray:(NSArray<PFUser*>*)receivingArray;
+ (NSInteger)getAverageCompletionTimeInDays:(CategoryObject*)category;
+ (PFQuery*)queryForUsersCompletedTasks;
@end

//Global Constants used across different View Controllers
static const NSInteger kToDoFeedLimit = 20;
static const NSInteger kFeedLimit = 20;
static const CGFloat kKeyboardDistanceFromTitleInput = 130.0;
static const CGFloat kKeyboardDistanceFromDescInput = 120.0;
static NSInteger kLabelConstraintConstantWhenVisible = 5;
static NSInteger kLabelConstraintConstantWhenInvisible = 0;
static NSString * const kTaskClassName = @"TaskObject";
static NSString * const kAssociatedTaskKey = @"associatedTask";
static NSString * const kSuggestionTypeKey = @"suggestionType";
static NSString * const kByDateCompletedKey = @"dateCompleted";
static NSString * const kSuggestionClassName = @"SuggestionObject";
static NSString * const kByOwnerQueryKey = @"owner";
static NSString * const kByCategoryClassName = @"CategoryObject";
static NSString * const kBySharedOwnerQueryKey = @"sharedOwners";
static NSString * const kByAcceptedUsersQueryKey = @"acceptedUsers";
static NSString * const kByCreatedAtQueryKey = @"createdAt";
static NSString * const kAddTaskMode = @"Adding";
static NSString * const kEditTaskMode = @"Editing";
static NSString* const kAccessReadAndWrite = @"Read and Write";
static NSString* const kAccessReadOnly = @"Read Only";
static NSString* const kShareMode = @"Share Mode";
static NSString* const kUnshareMode = @"Unshare Mode";
static NSString* const kMakeReadOnlyMode = @"Make Read Only";
static NSString* const kMakeWritableMode = @"Make Writable";
static NSString * const kSuggestionTypeOverdue = @"Overdue Task";
static NSString * const kSuggestionTypeUncategorized = @"Uncategorized Task";
static NSString * const kSuggestionTypeUndated = @"Undated Task";
