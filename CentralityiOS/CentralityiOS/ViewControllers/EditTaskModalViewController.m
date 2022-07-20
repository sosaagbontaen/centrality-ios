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
    [self.delegate didEditTask:self.taskFromFeed toFeed:self];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
