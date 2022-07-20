//
//  EditTaskModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"

@class EditTaskModalViewController;

@protocol EditTaskModalViewControllerDelegate <NSObject>
- (void)didEditTask:(TaskObject *)item toFeed:(EditTaskModalViewController *)controller;
@end


@interface EditTaskModalViewController : UIViewController
@property (nonatomic, weak) id <EditTaskModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UITextField *taskNameInput;
@property (weak, nonatomic) IBOutlet UITextView *taskDescInput;
@property (weak, nonatomic) TaskObject *taskFromFeed;
@end