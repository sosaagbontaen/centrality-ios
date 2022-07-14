//
//  AddTaskModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"

@class AddTaskModalViewController;

@protocol AddTaskModalViewControllerDelegate <NSObject>
- (void)addNewTaskToFeed:(AddTaskModalViewController *)controller newTaskToAddToFeed:(TaskObject *)item;
@end

@interface AddTaskModalViewController : UIViewController
@property (nonatomic, weak) id <AddTaskModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *taskTitleInput;
@property (weak, nonatomic) IBOutlet UITextView *taskDescInput;
@end
