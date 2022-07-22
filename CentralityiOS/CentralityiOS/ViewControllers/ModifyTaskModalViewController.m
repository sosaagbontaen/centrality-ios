//
//  ModifyTaskModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/21/22.
//

#import "ModifyTaskModalViewController.h"

@interface ModifyTaskModalViewController ()

@end

static NSString * const kAddTaskMode = @"Addding";
static NSString * const kEditTaskMode = @"Editing";

@implementation ModifyTaskModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.modifyMode isEqualToString:kEditTaskMode]){
        [self initModalForEditTaskMode];
    }
    else if([self.modifyMode isEqualToString:kAddTaskMode]){
        [self initModalForAddTaskMode];
    }
}

-(void)initModalForEditTaskMode{
    self.taskTitleInput.text = self.taskFromFeed.taskTitle;
    self.taskDescInput.text = self.taskFromFeed.taskDesc;
    self.modalTitle.text = @"Edit Task";
    [self.modifyButton setTitle:@"Update Task" forState:UIControlStateNormal];
    if (self.taskCategory){
        [self.changeCategoryButton setTitle:self.taskCategory.categoryName forState:UIControlStateNormal];
    }
    else{
        [self.changeCategoryButton setTitle:@"None" forState:UIControlStateNormal];
    }
    if (self.taskDueDate){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yy";
        NSString *formattedDate = [formatter stringFromDate:self.taskDueDate];
        [self.changeDateButton setTitle:formattedDate forState:UIControlStateNormal];
    }
    else{
        [self.changeCategoryButton setTitle:@"None" forState:UIControlStateNormal];
    }
}

-(void)initModalForAddTaskMode{
    self.taskTitleInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name this task" attributes:@{NSForegroundColorAttributeName: [UIColor systemGrayColor]}];
    [self.modifyButton setTitle:@"Add Task" forState:UIControlStateNormal];
    self.modalTitle.text = @"Add a Task";
}

- (IBAction)changeCategoryAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    CategoryModalViewController *categoryTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"CategoryModalViewController"];
    categoryTaskModalVC.delegate = self;
    [self presentViewController:categoryTaskModalVC animated:YES completion:^{}];
}

- (IBAction)changeDueDateAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    DueDateModalViewController *dueDateModalVC = [storyboard instantiateViewControllerWithIdentifier:@"DueDateModalViewController"];
    dueDateModalVC.delegate = self;
    [self presentViewController:dueDateModalVC animated:YES completion:^{}];
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

- (IBAction)modifyTaskAction:(id)sender {
    if ([self.modifyMode isEqualToString:kAddTaskMode]){
        if ([self.taskTitleInput.text isEqualToString:@""]){
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
    else if([self.modifyMode isEqualToString:kEditTaskMode]){
        if ([self.taskTitleInput.text isEqualToString:@""]){
            NSLog(@"Empty title");
            return;
        }
        self.taskFromFeed.taskTitle = self.taskTitleInput.text;
        self.taskFromFeed.taskDesc = self.taskDescInput.text;
        self.taskFromFeed.category = self.taskCategory;
        self.taskFromFeed.dueDate = self.taskDueDate;
        [self.delegate didEditTask:self.taskFromFeed toFeed:self];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
