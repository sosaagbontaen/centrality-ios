//
//  AddTaskModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "AddTaskModalViewController.h"
#import "ToDoFeedViewController.h"
#import "SceneDelegate.h"

@interface AddTaskModalViewController ()
@end

@implementation AddTaskModalViewController
- (IBAction)changeDueDateAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    DueDateModalViewController *dueDateModalVC = [storyboard instantiateViewControllerWithIdentifier:@"DueDateModalViewController"];
    dueDateModalVC.delegate = self;
    [self presentViewController:dueDateModalVC animated:YES completion:^{}];
}

- (IBAction)changeCategoryAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    CategoryModalViewController *categoryTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"CategoryModalViewController"];
    categoryTaskModalVC.delegate = self;
    [self presentViewController:categoryTaskModalVC animated:YES completion:^{}];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)addTaskAction:(id)sender {
    if ([self.taskTitleInput.text isEqual:@""]){
        NSLog(@"Empty title");
        return;
    }
        
    TaskObject *newTask = [TaskObject new];
    newTask.owner = [PFUser currentUser];
    newTask.taskTitle = self.taskTitleInput.text;
    newTask.taskDesc = self.taskDescInput.text;
    newTask.category = self.taskCategory;
    newTask.dueDate = self.taskDueDate;
    newTask.isCompleted = NO;
    
    [newTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.delegate didAddNewTask:newTask toFeed:self];
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
        else {
            NSLog(@"Task not added to Parse : %@", error.localizedDescription);
        }
    }];
}

- (void)didChangeCategory:(CategoryObject *)item toFeed:(CategoryModalViewController *)controller{
    if (item){
        self.taskCategory = item;
        [self.changeCategoryButton setTitle:self.taskCategory.categoryName forState:UIControlStateNormal];
    }
    else{
        [self.changeCategoryButton setTitle:@"None" forState:UIControlStateNormal];
    }
}

- (void)didChangeDuedate:(NSDate *)item toFeed:(DueDateModalViewController *)controller{
    if (item){
        self.taskDueDate = item;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yy";
        NSString *formattedDate = [formatter stringFromDate:self.taskDueDate];
        [self.changeDateButton setTitle:formattedDate forState:UIControlStateNormal];
    }
    else{
        NSLog(@"Invalid date selected.");
        return;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskTitleInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name this task" attributes:@{NSForegroundColorAttributeName: [UIColor systemGrayColor]}];
}
@end
