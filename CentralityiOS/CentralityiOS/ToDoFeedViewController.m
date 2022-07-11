//
//  ToDoFeedViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "ToDoFeedViewController.h"
#import "Parse/Parse.h"
#import "TaskCell.h"
#import "TaskObject.h"

@interface ToDoFeedViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ToDoFeedViewController

- (void)fetchData{
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"TaskObject"];
    [query orderByDescending:@"createdAt"];
    //[query whereKey:@"likesCount" greaterThan:@100];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (tasks != nil) {
            self.arrayOfTasks = tasks;
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
