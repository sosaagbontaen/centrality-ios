//
//  ModifyTaskModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/21/22.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"
#import "CategoryModalViewController.h"
#import "DueDateModalViewController.h"
#import "ShareModalViewController.h"

@class ModifyTaskModalViewController;

@protocol ModifyTaskModalViewControllerDelegate <NSObject>
- (void)didAddNewTask:(TaskObject *)addedTask toFeed:(ModifyTaskModalViewController *)controller;
- (void)didEditTask:(TaskObject *)editedTask toFeed:(ModifyTaskModalViewController *)controller;
@end

@interface ModifyTaskModalViewController : UIViewController <CategoryModalViewControllerDelegate, DueDateModalViewControllerDelegate, ShareModalViewControllerDelegate>
@property (nonatomic, weak) id <ModifyTaskModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *modalTitle;
@property (weak, nonatomic) IBOutlet UIButton *changeCategoryButton;
@property (weak, nonatomic) IBOutlet UIButton *changeDateButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UITextField *taskTitleInput;
@property (weak, nonatomic) IBOutlet UITextView *taskDescInput;
@property (weak, nonatomic) TaskObject *taskFromFeed;
@property CategoryObject *taskCategory;
@property NSDate *taskDueDate;
@property NSString *modifyMode;
@property NSMutableArray<PFUser*>*taskSharedOwners;
@property NSMutableArray<PFUser*>*taskReadOnlyUsers;
@property NSMutableArray<PFUser*>*taskReadAndWriteUsers;
@property NSMutableArray<PFUser*>*taskAcceptedUsers;
@end
