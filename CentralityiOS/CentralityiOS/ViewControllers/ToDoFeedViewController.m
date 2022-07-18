//
//  ToDoFeedViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "ToDoFeedViewController.h"
#import "AddTaskModalViewController.h"
#import "Parse/Parse.h"
#import "TaskCell.h"
#import "TaskObject.h"
#import "SceneDelegate.h"

@interface ToDoFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@end

@implementation ToDoFeedViewController

- (IBAction)logoutAction:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if ([mySceneDelegate.window.rootViewController isKindOfClass:[UITabBarController self]]){
            mySceneDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
        NSLog(@"User logged out succesfully!");
    }];
}

- (IBAction)newTaskAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    AddTaskModalViewController *addTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"AddTaskModalViewController"];
    addTaskModalVC.delegate = self;
    [self presentViewController:addTaskModalVC animated:YES completion:^{}];
}

- (void)didAddNewTask:(TaskObject*) newTask toFeed:(AddTaskModalViewController *)controller{
    NSLog(@"Succesfully added '%@' to Parse!", newTask.taskTitle);
    [self.arrayOfTasks addObject:newTask];
    [self fetchData];
}

- (void)fetchData{
    PFQuery *query = [PFQuery queryWithClassName:@"TaskObject"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    query.limit = 20;

    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (tasks != nil) {
            self.arrayOfTasks = [tasks mutableCopy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.taskTableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskObject *task = self.arrayOfTasks[indexPath.row];
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    cell.task = task;
    cell.taskNameLabel.text = task.taskTitle;
    cell.taskDescLabel.text = task.taskDesc;
    [cell refreshCell];
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskTableView.dataSource = self;
    self.taskTableView.delegate = self;
    [self fetchData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    [self.taskTableView insertSubview:self.refreshControl atIndex:0];
}

@end
