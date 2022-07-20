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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskTitleInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name this task" attributes:@{NSForegroundColorAttributeName: [UIColor systemGrayColor]}];
}
@end
