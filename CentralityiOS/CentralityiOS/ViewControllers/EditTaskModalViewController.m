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
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

@end

@implementation EditTaskModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)updateAction:(id)sender {
}

@end
