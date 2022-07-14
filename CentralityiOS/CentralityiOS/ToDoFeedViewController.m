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

@interface ToDoFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation ToDoFeedViewController

- (IBAction)newTaskAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    AddTaskModalViewController *addTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"AddTaskModalViewController"];
    addTaskModalVC.delegate = self;
    [self presentViewController:addTaskModalVC animated:YES completion:^{}];
}

- (void)addNewTaskToFeed:(AddTaskModalViewController *)controller newTaskToAddToFeed:(TaskObject*) newTask {
    NSLog(@"Succesfully added '%@' to Parse!", newTask.taskTitle);
    [self.arrayOfTasks addObject:newTask];
    [self fetchData];
}

- (void)fetchData{
    PFQuery *query = [PFQuery queryWithClassName:@"TaskObject"];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;

    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (tasks != nil) {
            self.arrayOfTasks = (NSMutableArray*)tasks;
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
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    TaskObject *task = self.arrayOfTasks[indexPath.row];
    cell.task = task;
    cell.taskNameLabel.text = task.taskTitle;
    cell.taskDescLabel.text = task.taskDesc;
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
