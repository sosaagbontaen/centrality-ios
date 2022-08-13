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
#import "CentralityHelpers.h"
#import "NSDate+DateTools.h"
#import "SuggestionAlgorithm.h"

@interface ToDoFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITabBarItem *tabButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@end

NSTimer* notificationTimer;

@implementation ToDoFeedViewController

- (IBAction)logoutAction:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        [notificationTimer invalidate];
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
- (IBAction)viewAlertsAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:nil];
    AlertsModalViewController *alertsModalVC = [storyboard instantiateViewControllerWithIdentifier:@"AlertsModalViewController"];
    alertsModalVC.delegate = self;
    alertsModalVC.arrayOfSuggestions = [[NSMutableArray alloc] init];
    alertsModalVC.arrayOfPendingSharedTasks = [[NSMutableArray alloc] init];
    [self presentViewController:alertsModalVC animated:YES completion:^{}];
}

- (IBAction)newTaskAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:nil];
    ModifyTaskModalViewController *modifyTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"ModifyTaskModalViewController"];
    modifyTaskModalVC.delegate = self;
    modifyTaskModalVC.modifyMode = AddTaskMode;
    [self presentViewController:modifyTaskModalVC animated:YES completion:^{}];
}

- (void)didRespondToSuggestion:(AlertsModalViewController *)controller{
    [self fetchTasks];
}

- (void)didAddNewTask:(TaskObject*) newTask toFeed:(ModifyTaskModalViewController *)controller{
    [self.arrayOfTasks addObject:newTask];
    [self fetchTasks];
}

- (void)didEditTask:(TaskObject*) updatedTask toFeed:(ModifyTaskModalViewController *)controller{
    [updatedTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self fetchTasks];
        }
        else{
            NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
        }
    }];
}

- (void)didAcceptOrDeclineTask:(TaskObject *)acceptedTask toFeed:(AlertsModalViewController *)controller{
    [self fetchTasks];
}

- (PFQuery*)taskQuery{
    PFQuery *tasksOwnedByMe = [PFQuery queryWithClassName:kTaskClassName];
    [tasksOwnedByMe whereKey:kByOwnerQueryKey equalTo:[PFUser currentUser]];
    
    PFQuery *tasksIAccepted = [PFQuery queryWithClassName:kTaskClassName];
    [tasksIAccepted whereKey:kByAcceptedUsersQueryKey equalTo:[PFUser currentUser]];
    
    PFQuery *tasksOwnedOrShared = [PFQuery orQueryWithSubqueries:@[tasksOwnedByMe, tasksIAccepted]];
    [tasksOwnedOrShared orderByDescending:kByCreatedAtQueryKey];
    tasksOwnedOrShared.limit = kToDoFeedLimit;
    
    return tasksOwnedOrShared;
}

- (void)fetchTasks{
    PFQuery *queryForFeedTasks = [self taskQuery];
    
    [queryForFeedTasks findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (tasks != nil) {
            self.arrayOfTasks = [tasks mutableCopy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.taskTableView reloadData];
        [self.refreshControl endRefreshing];
        [self detectEmptyFeed];
    }];
    [self updateNotifications];
}

-(void)updateNotifications{
    if ([PFUser currentUser]){
        [[SuggestionAlgorithm querySuggestions] countObjectsInBackgroundWithBlock:^(int numberOfSuggestions, NSError *error) {
            [[self queryShareRequests] countObjectsInBackgroundWithBlock:^(int numberOfShareRequests, NSError *error) {
                NSString *alertsAsString = [NSString stringWithFormat:@"%ld", (long)numberOfSuggestions + numberOfShareRequests];
                [self.alertButton setTitle:alertsAsString forState:UIControlStateNormal];
            }];
        }];
        [[self taskQuery] countObjectsInBackgroundWithBlock:^(int taskCount, NSError * _Nullable error) {
            self.tabButton.badgeValue = [@(taskCount) stringValue];
        }];
    }
}

- (PFQuery*)queryShareRequests{
    PFQuery *receivedTasksQuery = [PFQuery queryWithClassName:kTaskClassName];
    [receivedTasksQuery whereKey:kBySharedOwnerQueryKey equalTo:PFUser.currentUser];
    [receivedTasksQuery whereKey:kByAcceptedUsersQueryKey notEqualTo:PFUser.currentUser];
    return receivedTasksQuery;
}

- (void)detectEmptyFeed{
    self.feedMessageLabel.hidden = !([self arrayOfTasks].count == 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskObject *task = self.arrayOfTasks[indexPath.row];
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell" forIndexPath:indexPath];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.task = task;
    cell.taskNameLabel.text = task.taskTitle;
    cell.taskDescLabel.text = task.taskDesc;
    
    if ([task.category fetchIfNeeded]){
        [CentralityHelpers updateLabel:cell.categoryLabel newText:[NSString stringWithFormat:@"Category : %@", task.category.categoryName] isHidden:NO];
        cell.spaceBetweenCategoryAndDate.constant = kLabelConstraintConstantWhenVisible;
    }
    else{
        [CentralityHelpers updateLabel:cell.categoryLabel newText:@"" isHidden:YES];
        cell.spaceBetweenCategoryAndDate.constant = kLabelConstraintConstantWhenInvisible;
    }
    
    if (task.dueDate){
        NSString *formattedDate = [DateFormatHelper formatDateAsString:task.dueDate];
        [CentralityHelpers updateLabel:cell.dueDateLabel newText:[NSString stringWithFormat:@"Due %@", formattedDate] isHidden:NO];
        cell.spaceBetweenDateAndShared.constant = kLabelConstraintConstantWhenVisible;
    }
    else{
        [CentralityHelpers updateLabel:cell.dueDateLabel newText:@"" isHidden:YES];
        cell.spaceBetweenDateAndShared.constant = kLabelConstraintConstantWhenInvisible;
    }
    
    if (task.sharedOwners.count > 0){
        NSMutableString* allUsers = [[NSMutableString alloc] initWithString:@""];
        
        for (NSInteger index = 0; index < task.sharedOwners.count; index++){
            [allUsers appendString:[task.sharedOwners[index] fetchIfNeeded].username];
            
            if (index < task.sharedOwners.count-1){
                [allUsers appendString:@", "];
            }
        }
        
        NSString* displayMessage = [[NSString alloc]init];
        if ([task.owner.objectId isEqualToString:PFUser.currentUser.objectId]){
            displayMessage = [NSString stringWithFormat:@"Shared with : %@",allUsers];
            cell.sharedLabel.backgroundColor = [UIColor systemTealColor];
        }
        else{
            [task.owner fetchIfNeeded];
            displayMessage = [NSString stringWithFormat:@"Owned by %@", task.owner.username];
            cell.sharedLabel.backgroundColor = [UIColor systemPurpleColor];
        }
        [CentralityHelpers updateLabel:cell.sharedLabel newText:displayMessage isHidden:NO];
    }
    else{
        [CentralityHelpers updateLabel:cell.sharedLabel newText:@"" isHidden:YES];
    }
    
    [cell refreshCell];
    
    [SuggestionAlgorithm checkAllSuggestionRules:cell.task];
    
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaskObject *task = self.arrayOfTasks[indexPath.row];
    
    NSMutableDictionary* dictOfSharedOwners = [CentralityHelpers userDictionaryFromArray:task.sharedOwners];
    NSMutableDictionary* dictOfReadOnlyUsers = [CentralityHelpers userDictionaryFromArray:task.readOnlyUsers];
    NSMutableDictionary* dictOfReadAndWriteUsers = [CentralityHelpers userDictionaryFromArray:task.readAndWriteUsers];
    NSMutableDictionary* dictOfAcceptedUsers = [CentralityHelpers userDictionaryFromArray:task.acceptedUsers];
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        PFQuery *query = [self taskQuery];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
            if (tasks != nil) {
                task.category.numberOfTasksInCategory--;
                [task.category saveInBackground];
                [self.arrayOfTasks[indexPath.row] deleteInBackground];
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
        modifyTaskModalVC.modifyMode = EditTaskMode;
        modifyTaskModalVC.taskFromFeed = task;
        modifyTaskModalVC.taskCategory = task.category;
        modifyTaskModalVC.taskDueDate = task.dueDate;
        modifyTaskModalVC.taskSharedOwners = [task.sharedOwners mutableCopy];
        modifyTaskModalVC.taskAcceptedUsers = [task.acceptedUsers mutableCopy];
        modifyTaskModalVC.taskReadOnlyUsers = task.readOnlyUsers;
        modifyTaskModalVC.taskReadAndWriteUsers = task.readAndWriteUsers;
        [self presentViewController:modifyTaskModalVC animated:YES completion:^{}];
        completionHandler(YES);
    }];
    
    UIContextualAction *unfollowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Unfollow" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        
        PFQuery *query = [self taskQuery];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
            if (tasks != nil) {
                if ([dictOfSharedOwners objectForKey:PFUser.currentUser.objectId]){
                    [dictOfSharedOwners removeObjectForKey:PFUser.currentUser.objectId];
                    task.sharedOwners = [[dictOfSharedOwners allValues] mutableCopy];
                }
                if ([dictOfAcceptedUsers objectForKey:PFUser.currentUser.objectId]){
                    [dictOfAcceptedUsers removeObjectForKey:PFUser.currentUser.objectId];
                    task.acceptedUsers = [[dictOfAcceptedUsers allValues] mutableCopy];
                }
                if ([dictOfReadOnlyUsers objectForKey:PFUser.currentUser.objectId]){
                    [dictOfReadOnlyUsers removeObjectForKey:PFUser.currentUser.objectId];
                    task.readOnlyUsers = [[dictOfReadOnlyUsers allValues] mutableCopy];
                }
                if ([dictOfReadAndWriteUsers objectForKey:PFUser.currentUser.objectId]){
                    [dictOfReadAndWriteUsers removeObjectForKey:PFUser.currentUser.objectId];
                    task.readAndWriteUsers = [[dictOfReadAndWriteUsers allValues] mutableCopy];
                }
                
                [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (succeeded) {
                        [self fetchTasks];
                        [self detectEmptyFeed];
                    }
                    else{
                        NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
                    }
                }];
                [self.arrayOfTasks removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        completionHandler(YES);
        
    }];
    
    deleteAction.backgroundColor = [UIColor systemRedColor];
    editAction.backgroundColor = [UIColor systemGreenColor];
    unfollowAction.backgroundColor = [UIColor systemTealColor];
    
    UISwipeActionsConfiguration *swipeActions;
    NSMutableArray<NSString*>* readOnlyObjIds = [CentralityHelpers getArrayOfObjectIds:task.readOnlyUsers];
    
    if ([readOnlyObjIds containsObject:PFUser.currentUser.objectId]){
        swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[unfollowAction]];
    }
    else if ([PFUser.currentUser.objectId isEqualToString:task.owner.objectId]){
        swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, editAction]];
    }
    else{
        swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[editAction, unfollowAction]];
    }
    swipeActions.performsFirstActionWithFullSwipe=NO;
    return swipeActions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskTableView.dataSource = self;
    self.taskTableView.delegate = self;
    [self fetchTasks];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchTasks) forControlEvents:UIControlEventValueChanged];
    [self.taskTableView insertSubview:self.refreshControl atIndex:0];
    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateNotifications) userInfo:nil repeats:YES];
}



@end
