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
    
    //newTask.taskID = User.taskCounter;
    //newTask.dueDate;
    newTask.taskTitle = self.taskTitleInput.text;
    newTask.taskDesc = self.taskDescInput.text;
    newTask.isCompleted = false;
    //newTask.category;
    
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
    
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
