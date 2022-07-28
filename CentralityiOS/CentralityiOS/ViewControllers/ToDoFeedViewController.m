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
#import "SceneDelegate.h"
#import "DateFormatHelper.h"

@interface ToDoFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@end

static const NSInteger kToDoFeedLimit = 20;
static NSString * const kTaskClassName = @"TaskObject";
static NSString * const kByOwnerQueryKey = @"owner";
static NSString * const kCreatedAtQueryKey = @"createdAt";
static NSString * const kAddTaskMode = @"Addding";
static NSString * const kEditTaskMode = @"Editing";
static NSInteger kLabelConstraintConstantWhenVisible = 5;
static NSInteger kLabelConstraintConstantWhenInvisible = 0;

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
    }];
}

- (IBAction)newTaskAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    ModifyTaskModalViewController *modifyTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"ModifyTaskModalViewController"];
    modifyTaskModalVC.delegate = self;
    modifyTaskModalVC.modifyMode = kAddTaskMode;
    [self presentViewController:modifyTaskModalVC animated:YES completion:^{}];
}

- (void)didAddNewTask:(TaskObject*) newTask toFeed:(ModifyTaskModalViewController *)controller{
    [self.arrayOfTasks addObject:newTask];
    [self fetchData];
}

- (void)didEditTask:(TaskObject*) updatedTask toFeed:(ModifyTaskModalViewController *)controller{
    [updatedTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self fetchData];
        }
        else{
            NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
        }
    }];
}

- (PFQuery*)makeQuery{
    PFQuery *query = [PFQuery queryWithClassName:kTaskClassName];
    [query orderByDescending:kCreatedAtQueryKey];
    [query whereKey:kByOwnerQueryKey equalTo:[PFUser currentUser]];
    query.limit = kToDoFeedLimit;
    return query;
}

- (void)fetchData{
    PFQuery *query = [self makeQuery];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (tasks != nil) {
            self.arrayOfTasks = [tasks mutableCopy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.taskTableView reloadData];
        [self.refreshControl endRefreshing];
        [self detectEmptyFeed];
    }];
}

- (void)detectEmptyFeed{
    if ([self arrayOfTasks].count == 0){
        self.feedMessageLabel.hidden = FALSE;
    }
    else{
        self.feedMessageLabel.hidden = true;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskObject *task = self.arrayOfTasks[indexPath.row];
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    
    cell.task = task;
    cell.taskNameLabel.text = task.taskTitle;
    cell.taskDescLabel.text = task.taskDesc;
    
    if ([task.category fetchIfNeeded]){
        [self updateLabel:cell.categoryLabel newText:[NSString stringWithFormat:@"Category : %@", task.category.categoryName] isHidden:FALSE];
        cell.spaceBetweenCategoryAndDate.constant = kLabelConstraintConstantWhenVisible;
    }
    else{
        [self updateLabel:cell.categoryLabel newText:@"" isHidden:TRUE];
        cell.spaceBetweenCategoryAndDate.constant = kLabelConstraintConstantWhenInvisible;
    }
    
    if (task.dueDate){
        NSString *formattedDate = [DateFormatHelper formatDateAsString:task.dueDate];
        [self updateLabel:cell.dueDateLabel newText:[NSString stringWithFormat:@"Due %@", formattedDate] isHidden:FALSE];
        cell.spaceBetweenDateAndShared.constant = kLabelConstraintConstantWhenVisible;
    }
    else{
        [self updateLabel:cell.dueDateLabel newText:@"" isHidden:TRUE];
        cell.spaceBetweenDateAndShared.constant = kLabelConstraintConstantWhenInvisible;
    }
    
    if (task.sharedOwners.count > 0){
        NSString* allUsers = @"";
        for (NSInteger index = 0; index < task.sharedOwners.count; index++){
            allUsers = [allUsers stringByAppendingString:[task.sharedOwners[index] fetchIfNeeded].username];
            if (index < task.sharedOwners.count-1){
                allUsers = [NSString stringWithFormat:@"%@, ",allUsers];
            }
        }
        NSString* displayMessage = [NSString stringWithFormat:@"Shared with : %@",allUsers];
        [self updateLabel:cell.sharedLabel newText:displayMessage isHidden:FALSE];
    }
    else{
        [self updateLabel:cell.sharedLabel newText:@"" isHidden:TRUE];
    }
    
    [cell refreshCell];
    return cell;
}

- (void) updateLabel:(UILabel*)label newText:(NSString*)newText isHidden:(BOOL)isHidden{
    label.text = newText;
    label.hidden = isHidden;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        PFQuery *query = [self makeQuery];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
            if (tasks != nil) {
                //Removes task from backend
                [self.arrayOfTasks[indexPath.row] deleteInBackground];
                //Removes task from current view / local array
                [self.arrayOfTasks removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self detectEmptyFeed];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        completionHandler(YES);
        
    }];
    
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                        @"Main" bundle:nil];
        ModifyTaskModalViewController *modifyTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"ModifyTaskModalViewController"];
        modifyTaskModalVC.delegate = self;
        modifyTaskModalVC.modifyMode = kEditTaskMode;
        TaskObject *task = self.arrayOfTasks[indexPath.row];
        modifyTaskModalVC.taskFromFeed = task;
        modifyTaskModalVC.taskCategory = task.category;
        modifyTaskModalVC.taskDueDate = task.dueDate;
        modifyTaskModalVC.taskSharedOwners = task.sharedOwners;
        [self presentViewController:modifyTaskModalVC animated:YES completion:^{}];
        completionHandler(YES);
    }];
    
    deleteAction.backgroundColor = [UIColor systemRedColor];
    editAction.backgroundColor = [UIColor systemGreenColor];
    
    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,editAction]];
    swipeActions.performsFirstActionWithFullSwipe=false;
    return swipeActions;
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
