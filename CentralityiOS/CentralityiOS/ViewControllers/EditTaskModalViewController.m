//
//  EditTaskModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/19/22.
//

#import "EditTaskModalViewController.h"
#import "ToDoFeedViewController.h"
#import "SceneDelegate.h"

@interface EditTaskModalViewController ()
@end


@implementation EditTaskModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskNameInput.text = self.taskFromFeed.taskTitle;
    self.taskDescInput.text = self.taskFromFeed.taskDesc;
    if (self.taskCategory){
    [self.changeCategoryButton setTitle:self.taskCategory.categoryName forState:UIControlStateNormal];
    }
    if (self.taskDueDate){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yy";
        NSString *formattedDate = [formatter stringFromDate:self.taskDueDate];
        [self.changeDateButton setTitle:formattedDate forState:UIControlStateNormal];
    }
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
    self.taskCategory = item;
    [self.changeCategoryButton setTitle:self.taskCategory.categoryName forState:UIControlStateNormal];
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

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)updateAction:(id)sender {
    if ([self.taskNameInput.text isEqual:@""]){
        NSLog(@"Empty title");
        return;
    }
    self.taskFromFeed.taskTitle = self.taskNameInput.text;
    self.taskFromFeed.taskDesc = self.taskDescInput.text;
    self.taskFromFeed.category = self.taskCategory;
    self.taskFromFeed.dueDate = self.taskDueDate;
    [self.delegate didEditTask:self.taskFromFeed toFeed:self];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
