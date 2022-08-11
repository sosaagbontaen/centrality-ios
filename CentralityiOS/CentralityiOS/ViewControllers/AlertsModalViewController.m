//
//  AlertsModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/1/22.
//

#import "AlertsModalViewController.h"
#import "ReceiverCell.h"
#import "CentralityHelpers.h"
#import "DateFormatHelper.h"
#import "DateTools.h"
#import "SuggestionAlgorithm.h"

@interface AlertsModalViewController ()<UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@end

static NSString* const kShareTabTitle = @"Share Requests";
static NSString* const kTaskSuggestions = @"Task Suggestions";
static AlertViewMode alertViewMode = ShareViewMode;


@implementation AlertsModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [[SuggestionAlgorithm querySuggestions] countObjectsInBackgroundWithBlock:^(int numberOfSuggestions, NSError *error) {
        self.taskSuggestionsTabBarItem.badgeValue = [@(numberOfSuggestions) stringValue];
    }];
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item isEqual:self.shareRequestsTabBarItem] && !(alertViewMode == ShareViewMode)){
        alertViewMode = ShareViewMode;
    }
    else if ([item isEqual:self.taskSuggestionsTabBarItem] && !(alertViewMode == SuggestionViewMode)){
        alertViewMode = SuggestionViewMode;
    }
    [self fetchNotifications];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0;
    if (alertViewMode == SuggestionViewMode){
        rowCount = self.arrayOfSuggestions.count;
    }
    else if (alertViewMode == ShareViewMode){
        rowCount = self.arrayOfPendingSharedTasks.count;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary<NSNumber*, NSString*>* suggestionLabelDictionary = [[NSMutableDictionary alloc] init];
    suggestionLabelDictionary[@(Overdue)] = @"Overdue Task";
    suggestionLabelDictionary[@(Uncategorized)] = @"Uncategorized Task";
    suggestionLabelDictionary[@(Undated)] = @"Undated Task";
    
    ReceiverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell" forIndexPath:indexPath];
    
    if (alertViewMode == ShareViewMode){
        TaskObject *task = self.arrayOfPendingSharedTasks[indexPath.row];
        [task.owner fetchIfNeeded];
        cell.taskNameLabel.text = task.taskTitle;
        cell.taskDescLabel.text = task.taskDesc;
        cell.taskOwnerLabel.text = [NSString stringWithFormat:@"Owned by : %@", task.owner.username];
        cell.taskOwnerLabel.backgroundColor = [UIColor systemBlueColor];
        cell.taskSharerLabel.backgroundColor = [UIColor systemPurpleColor];
        [self displaySharedUsers:task label:cell.taskSharerLabel];
    }
    else if (alertViewMode == SuggestionViewMode){
        SuggestionObject *suggestion = self.arrayOfSuggestions[indexPath.row];
        if ([suggestion.associatedTask fetchIfNeeded] && [suggestion.associatedTask.owner fetchIfNeeded]){
            cell.taskNameLabel.text = suggestion.associatedTask.taskTitle;
            cell.taskDescLabel.text = suggestion.associatedTask.taskDesc;
            cell.taskOwnerLabel.text = suggestionLabelDictionary[@(suggestion.suggestionType)];
            cell.taskOwnerLabel.backgroundColor = [UIColor systemRedColor];
            if (suggestion.suggestionType == Overdue){
                cell.taskSharerLabel.hidden = NO;
                cell.taskSharerLabel.text = [NSString stringWithFormat:@"Due %@", [DateFormatHelper formatDateAsString:suggestion.associatedTask.dueDate]];
                cell.taskSharerLabel.backgroundColor = [UIColor systemGreenColor];
            }
            else{
                cell.taskSharerLabel.hidden = YES;
            }
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
        label.hidden = NO;
    }
    else{
        displayMessage = @"";
        label.hidden = YES;
    }
        
    label.text = displayMessage;
}

- (PFQuery*)queryAllPendingTasks{
    PFQuery *receivedTasksQuery = [PFQuery queryWithClassName:kTaskClassName];
    [receivedTasksQuery whereKey:kBySharedOwnerQueryKey equalTo:PFUser.currentUser];
    [receivedTasksQuery whereKey:kByAcceptedUsersQueryKey notEqualTo:PFUser.currentUser];
    return receivedTasksQuery;
}

- (void)fetchNotifications{
    if (alertViewMode == ShareViewMode){
        PFQuery *queryForPendingTasks = [self queryAllPendingTasks];
        
        [queryForPendingTasks findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (users != nil) {
                self.arrayOfPendingSharedTasks = [users mutableCopy];
                [self updateTabAlertCounts];
                self.modalTitle.text = @"Pending Share Requests";
                [self.receiverTableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    else if (alertViewMode == SuggestionViewMode){
        PFQuery *queryForSuggestions = [SuggestionAlgorithm querySuggestions];
        [queryForSuggestions findObjectsInBackgroundWithBlock:^(NSArray *suggestions, NSError *error) {
            if (suggestions != nil) {
                self.arrayOfSuggestions = [suggestions mutableCopy];
                [self updateTabAlertCounts];
                self.modalTitle.text = @"Suggestions";
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
    
    if (alertViewMode == ShareViewMode){
        
        TaskObject *task = self.arrayOfPendingSharedTasks[indexPath.row];
        
        NSMutableDictionary* dictOfSharedOwners = [CentralityHelpers userDictionaryFromArray:task.sharedOwners];
        NSMutableDictionary* dictOfReadOnlyUsers = [CentralityHelpers userDictionaryFromArray:task.readOnlyUsers];
        NSMutableDictionary* dictOfReadAndWriteUsers = [CentralityHelpers userDictionaryFromArray:task.readAndWriteUsers];
        NSMutableDictionary* dictOfAcceptedUsers = [CentralityHelpers userDictionaryFromArray:task.acceptedUsers];
        
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
                    
                    if ([dictOfSharedOwners objectForKey:PFUser.currentUser.objectId]){
                        [dictOfSharedOwners removeObjectForKey:PFUser.currentUser.objectId];
                        task.sharedOwners = [[dictOfSharedOwners allValues] mutableCopy];
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
                    if ([dictOfSharedOwners objectForKey:PFUser.currentUser.objectId]){
                        dictOfAcceptedUsers[PFUser.currentUser.objectId] = PFUser.currentUser;
                        task.acceptedUsers = [[dictOfAcceptedUsers allValues] mutableCopy];
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
    
    if (alertViewMode == SuggestionViewMode){
        SuggestionObject *suggestion = self.arrayOfSuggestions[indexPath.row];
        
        UIContextualAction *markCompletedAction =
        [UIContextualAction contextualActionWithStyle:
         UIContextualActionStyleDestructive title:
         @"Mark Completed" handler:
         ^(UIContextualAction * _Nonnull action,
           __kindof UIView * _Nonnull sourceView,
           void (^ _Nonnull completionHandler)(BOOL))
         {
            suggestion.associatedTask.isCompleted = YES;
            [suggestion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [self.arrayOfSuggestions removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [suggestion deleteInBackground];
                    [self.delegate didRespondToSuggestion:self];
                    [self updateTabAlertCounts];
                }
                else{
                    NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
                }
            }];
            completionHandler(YES);
        }];
        
        UIContextualAction *extendDueDateAction =
        [UIContextualAction contextualActionWithStyle:
         UIContextualActionStyleDestructive title:
         @"Extend due date" handler:
         ^(UIContextualAction * _Nonnull action,
           __kindof UIView * _Nonnull sourceView,
           void (^ _Nonnull completionHandler)(BOOL))
         {
            [SuggestionAlgorithm extendDueDate:suggestion];
            [suggestion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [self.arrayOfSuggestions removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [suggestion deleteInBackground];
                    [self.delegate didRespondToSuggestion:self];
                    [self updateTabAlertCounts];
                }
                else{
                    NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
                }
            }];
            completionHandler(YES);
        }];
        
        if (suggestion.suggestionType == Overdue){
            extendDueDateAction.title = @"Extend due date";
            
        }
        else if (suggestion.suggestionType == Undated){
            extendDueDateAction.title = @"Estimate due date";
        }
        
        UIContextualAction *addToLargestCategoryAction =
        [UIContextualAction contextualActionWithStyle:
         UIContextualActionStyleDestructive title:
         @"Add to largest category" handler:
         ^(UIContextualAction * _Nonnull action,
           __kindof UIView * _Nonnull sourceView,
           void (^ _Nonnull completionHandler)(BOOL))
         {
            [SuggestionAlgorithm addTaskToLargestCategory:suggestion];
            [suggestion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [self.arrayOfSuggestions removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [suggestion deleteInBackground];
                    [self.delegate didRespondToSuggestion:self];
                    [self updateTabAlertCounts];
                }
                else{
                    NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
                }
            }];
            completionHandler(YES);
        }];
        
        UIContextualAction *addToMostRecentCategoryAction =
        [UIContextualAction contextualActionWithStyle:
         UIContextualActionStyleDestructive title:
         @"Add to newest category" handler:
         ^(UIContextualAction * _Nonnull action,
           __kindof UIView * _Nonnull sourceView,
           void (^ _Nonnull completionHandler)(BOOL))
         {
            [SuggestionAlgorithm addTaskToNewestCategory:suggestion];
            [suggestion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [self.arrayOfSuggestions removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [suggestion deleteInBackground];
                    [self.delegate didRespondToSuggestion:self];
                    [self updateTabAlertCounts];
                }
                else{
                    NSLog(@"Task not updated on Parse : %@", error.localizedDescription);
                }
            }];
            completionHandler(YES);
        }];
        
        markCompletedAction.backgroundColor = [UIColor systemGreenColor];
        extendDueDateAction.backgroundColor = [UIColor systemOrangeColor];
        addToLargestCategoryAction.backgroundColor = [UIColor systemOrangeColor];
        addToMostRecentCategoryAction.backgroundColor = [UIColor systemPurpleColor];
        swipeActions.performsFirstActionWithFullSwipe = NO;
        
        if (suggestion.suggestionType == Overdue){
            swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[markCompletedAction, extendDueDateAction]];
        }
        else if(suggestion.suggestionType == Uncategorized && [[CentralityHelpers queryForUsersCategories] countObjects] > 0){
                swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[addToLargestCategoryAction, addToMostRecentCategoryAction]];
        }
        else if(suggestion.suggestionType == Undated){
            swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[extendDueDateAction]];
        }
    }
    return swipeActions;
    
}

@end
