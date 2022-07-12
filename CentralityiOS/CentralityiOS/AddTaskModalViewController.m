//
//  AddTaskModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "AddTaskModalViewController.h"
#import "TaskObject.h"

@interface AddTaskModalViewController ()
@property (weak, nonatomic) IBOutlet UITextField *taskTitleInput;
@property (weak, nonatomic) IBOutlet UITextView *taskDescInput;

@end

@implementation AddTaskModalViewController
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)addTaskAction:(id)sender {
    
    if ([self.taskTitleInput.text isEqual:@""]){
        [self alert:@"Invalid Task Name" messageLabel:@"Task Name field is empty" label:@"OK"];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    TaskObject *newTask = [TaskObject new];
    newTask.taskTitle = self.taskTitleInput.text;
    newTask.taskDesc = self.taskDescInput.text;
    newTask.isCompleted = false;
    
    NSLog(@"Attempting to add task to Parse!");
    [newTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Task succesfully added to Parse!");
        }
        else {
            NSLog(@"Task not added to Parse : %@", error.localizedDescription);
        }
    }];
    }

- (void)alert:(NSString *)titleLabel messageLabel:(NSString *)messageLabel label: (NSString *)label{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleLabel
                                                                               message:messageLabel
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *onlyAction = [UIAlertAction actionWithTitle:label
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle cancel response here. Doing nothing will dismiss the view.
                                                      }];
    [alert addAction:onlyAction];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
