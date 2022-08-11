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
+ (PFQuery*)queryForUsersCategories;
+ (CategoryObject*)getMostRecentCategory;
+ (CategoryObject*)getLargestCategory;
+ (NSMutableDictionary<NSString*, PFUser*> *)userDictionaryFromArray :(NSMutableArray*)userArray;
@end

//Global Constants used across different View Controllers

// Feed limits
static const NSInteger kToDoFeedLimit = 20;
static const NSInteger kFeedLimit = 20;

// Keyboard Constants
static const CGFloat kKeyboardDistanceFromTitleInput = 130.0;
static const CGFloat kKeyboardDistanceFromDescInput = 120.0;

// Constraints for task labels
static NSInteger kLabelConstraintConstantWhenVisible = 5;
static NSInteger kLabelConstraintConstantWhenInvisible = 0;

// Parse Class Names
static NSString * const kTaskClassName = @"TaskObject";
static NSString * const kByCategoryClassName = @"CategoryObject";
static NSString * const kSuggestionClassName = @"SuggestionObject";

// Parse Task Key Names
static NSString * const kAssociatedTaskKey = @"associatedTask";
static NSString * const kSuggestionTypeKey = @"suggestionType";
static NSString * const kByDateCompletedKey = @"dateCompleted";
static NSString * const kByOwnerQueryKey = @"owner";
static NSString * const kBySharedOwnerQueryKey = @"sharedOwners";
static NSString * const kByAcceptedUsersQueryKey = @"acceptedUsers";
static NSString * const kByCreatedAtQueryKey = @"createdAt";

// Task Modification Modes
typedef NS_ENUM(NSInteger, TaskModifyMode) {
    AddTaskMode,
    EditTaskMode
};

// Privacy Access Setting
typedef NS_ENUM(NSInteger, PrivacyAccessStatus) {
    ReadAndWriteAccess,
    ReadOnlyAccess
};

// Privacy Update Mode
typedef NS_ENUM(NSInteger, PrivacyUpdateMode) {
    MakeReadOnly,
    MakeWritable,
    MakeShared,
    MakeUnshared
};

// Suggestion Types
typedef NS_ENUM(NSInteger, SuggestionType) {
    Overdue,
    Uncategorized,
    Undated
};
