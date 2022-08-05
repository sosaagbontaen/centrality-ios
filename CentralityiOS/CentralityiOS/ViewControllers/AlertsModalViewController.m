//
//  AlertsModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/1/22.
//

#import "AlertsModalViewController.h"
#import "ReceiverCell.h"
#import "CentralityHelpers.h"

@interface AlertsModalViewController ()<UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@end

static NSString* const kShareTabTitle = @"Share Requests";
static NSString* const kTaskSuggestions = @"Task Suggestions";
static NSString* const kViewSharingMode = @"Sharing Mode";
static NSString* const kViewSuggestionsMode = @"Suggestions Mode";

@implementation AlertsModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.kCurrentViewMode = kViewSharingMode;
    self.receiverTableView.dataSource = self;
    self.receiverTableView.delegate = self;
    self.modeTabBar.delegate = self;
    [self fetchNotifications];
    [self updateTabAlertCounts];
}

- (void)updateTabAlertCounts{
        
    [[self queryAllPendingTasks] countObjectsInBackgroundWithBlock:^(int numberOfTasks, NSError *error) {
        self.shareRequestsTabBarItem.badgeValue = [@(numberOfTasks) stringValue];
    }];
    [[self queryForSuggestions] countObjectsInBackgroundWithBlock:^(int numberOfSuggestions, NSError *error) {
        self.taskSuggestionsTabBarItem.badgeValue = [@(numberOfSuggestions) stringValue];
    }];
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item isEqual:self.shareRequestsTabBarItem] && !([self.kCurrentViewMode isEqualToString: kViewSharingMode])){
        self.kCurrentViewMode = kViewSharingMode;
    }
    else if ([item isEqual:self.taskSuggestionsTabBarItem] && !([self.kCurrentViewMode isEqualToString: kViewSuggestionsMode])){
        self.kCurrentViewMode = kViewSuggestionsMode;
    }
    [self fetchNotifications];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = self.arrayOfPendingSharedTasks.count;
    if ([self.kCurrentViewMode isEqualToString:kViewSuggestionsMode]){
        rowCount = self.arrayOfSuggestions.count;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReceiverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell" forIndexPath:indexPath];
    
    if ([self.kCurrentViewMode isEqualToString:kViewSharingMode]){
        TaskObject *task = self.arrayOfPendingSharedTasks[indexPath.row];
        [task.owner fetchIfNeeded];
        cell.taskNameLabel.text = task.taskTitle;
        cell.taskDescLabel.text = task.taskDesc;
        cell.taskOwnerLabel.text = [NSString stringWithFormat:@"Owned by : %@", task.owner.username];
        [self displaySharedUsers:task label:cell.taskSharerLabel];
    }
    else if ([self.kCurrentViewMode isEqualToString:kViewSuggestionsMode]){
        SuggestionObject *suggestion = self.arrayOfSuggestions[indexPath.row];
        if ([suggestion.associatedTask fetchIfNeeded] && [suggestion.associatedTask.owner fetchIfNeeded]){
            cell.taskNameLabel.text = suggestion.associatedTask.taskTitle;
            cell.taskDescLabel.text = suggestion.associatedTask.taskDesc;
            [self displaySharedUsers:suggestion.associatedTask label:cell.taskSharerLabel];
            cell.taskOwnerLabel.text = [NSString stringWithFormat:@"Owned by : %@", suggestion.associatedTask.owner.username];
        }
        else{
            [suggestion deleteInBackground];
            [self fetchNotifications];
        }
        
    }
    
    
    return cell;
}

- (void)displaySharedUsers:(TaskObject*)task label:(UILabel*)label{
    NSMutableString* allUsers = [[NSMutableString alloc] initWithString:@""];
    NSString* displayMessage = [[NSString alloc] init];
    if (task.acceptedUsers.count > 0){
        for (NSInteger index = 0; index < task.sharedOwners.count-1; index++){
            [allUsers appendString:[task.acceptedUsers[index] fetchIfNeeded].username];
            if (index < task.sharedOwners.count-2){
                [allUsers appendString:@", "];
            }
        }
        displayMessage = [NSString stringWithFormat:@"Accessible by : %@",allUsers];
        label.hidden = FALSE;
    }
    else{
        displayMessage = @"";
        label.hidden = TRUE;
    }
        
    label.text = displayMessage;
}

- (PFQuery*)queryAllPendingTasks{
    PFQuery *receivedTasksQuery = [PFQuery queryWithClassName:kTaskClassName];
    [receivedTasksQuery whereKey:kBySharedOwnerQueryKey equalTo:PFUser.currentUser];
    [receivedTasksQuery whereKey:kByAcceptedUsersQueryKey notEqualTo:PFUser.currentUser];
    return receivedTasksQuery;
}

- (PFQuery*)queryForSuggestions{
    PFQuery *suggestionsQuery = [PFQuery queryWithClassName:kSuggestionClassName];
    [suggestionsQuery whereKey:kByOwnerQueryKey equalTo:PFUser.currentUser];
    return suggestionsQuery;
}

- (void)fetchNotifications{
    if ([self.kCurrentViewMode isEqualToString:kViewSharingMode]){
        PFQuery *queryForPendingTasks = [self queryAllPendingTasks];
        
        [queryForPendingTasks findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (users != nil) {
                self.arrayOfPendingSharedTasks = [users mutableCopy];
                [self updateTabAlertCounts];
                [self.receiverTableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    else if ([self.kCurrentViewMode isEqualToString:kViewSuggestionsMode]){
        PFQuery *queryForSuggestions = [self queryForSuggestions];
        [queryForSuggestions findObjectsInBackgroundWithBlock:^(NSArray *suggestions, NSError *error) {
            if (suggestions != nil) {
                self.arrayOfSuggestions = [suggestions mutableCopy];
                [self updateTabAlertCounts];
                [self.receiverTableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UISwipeActionsConfiguration *swipeActions = [[UISwipeActionsConfiguration alloc] init];
    if ([self.kCurrentViewMode isEqualToString:kViewSharingMode]){
        TaskObject *task = self.arrayOfPendingSharedTasks[indexPath.row];
        
        UIContextualAction *declineAction =
        [UIContextualAction contextualActionWithStyle:
         UIContextualActionStyleDestructive title:
         @"Decline" handler:
         ^(UIContextualAction * _Nonnull action,
           __kindof UIView * _Nonnull sourceView,
           void (^ _Nonnull completionHandler)(BOOL))
         {
            
            PFQuery *query = [self queryAllPendingTasks];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
                if (tasks != nil) {
                    task.sharedOwners = [[CentralityHelpers removeUser:PFUser.currentUser FromArray:task.sharedOwners] mutableCopy];
                    task.readOnlyUsers = [[CentralityHelpers removeUser:PFUser.currentUser FromArray:task.readOnlyUsers] mutableCopy];
                    task.readAndWriteUsers = [[CentralityHelpers removeUser:PFUser.currentUser FromArray:task.readAndWriteUsers] mutableCopy];
                    [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        if (succeeded) {
                            [self fetchNotifications];
                        }
                        else{
                            NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
                        }
                    }];
                    [self.arrayOfPendingSharedTasks removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            completionHandler(YES);
            
        }];
        
        UIContextualAction *acceptAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Accept" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            
            
            PFQuery *query = [self queryAllPendingTasks];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
                if (tasks != nil) {
                    if ([[CentralityHelpers getArrayOfObjectIds:task.sharedOwners] containsObject:PFUser.currentUser.objectId])
                    {
                    task.acceptedUsers = [[CentralityHelpers addUser:PFUser.currentUser ToArray:task.acceptedUsers] mutableCopy];
                    }
                    
                    [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        if (succeeded) {
                            [self fetchNotifications];
                            [self.delegate didAcceptOrDeclineTask:task toFeed:self];
                        }
                        else{
                            NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
                        }
                    }];
                    [self.arrayOfPendingSharedTasks removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            completionHandler(YES);
            
        }];
        
        acceptAction.backgroundColor = [UIColor systemGreenColor];
        declineAction.backgroundColor = [UIColor systemRedColor];

        swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[declineAction, acceptAction]];
        swipeActions.performsFirstActionWithFullSwipe = NO;
        }
    return swipeActions;
}

@end
