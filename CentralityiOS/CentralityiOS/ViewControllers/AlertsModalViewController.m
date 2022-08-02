//
//  AlertsModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/1/22.
//

#import "AlertsModalViewController.h"
#import "ReceiverCell.h"
#import "CentralityHelpers.h"

@interface AlertsModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation AlertsModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.receiverTableView.dataSource = self;
    self.receiverTableView.delegate = self;
    [self fetchReceivedTasks];
}
- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfPendingSharedTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskObject *task = self.arrayOfPendingSharedTasks[indexPath.row];
    [task.owner fetchIfNeeded];
    ReceiverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell" forIndexPath:indexPath];
    cell.taskNameLabel.text = task.taskTitle;
    cell.taskDescLabel.text = task.taskDesc;
    cell.taskOwnerLabel.text = [NSString stringWithFormat:@"Owned by : %@", task.owner.username];
    
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
        cell.taskSharerLabel.hidden = FALSE;
    }
    else{
        displayMessage = @"";
        cell.taskSharerLabel.hidden = TRUE;
    }
        
    cell.taskSharerLabel.text = displayMessage;
    
    return cell;
}

- (PFQuery*)queryAllPendingTasks{
    PFQuery *receivedTasksQuery = [PFQuery queryWithClassName:kTaskClassName];
    [receivedTasksQuery whereKey:kBySharedOwnerQueryKey equalTo:PFUser.currentUser];
    [receivedTasksQuery whereKey:kByAcceptedUsersQueryKey notEqualTo:PFUser.currentUser];
    return receivedTasksQuery;
}

- (void)fetchReceivedTasks{
    PFQuery *query = [self queryAllPendingTasks];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.arrayOfPendingSharedTasks = [users mutableCopy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.receiverTableView reloadData];
    }];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
                        [self fetchReceivedTasks];
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
                        [self fetchReceivedTasks];
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

    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[declineAction, acceptAction]];
    swipeActions.performsFirstActionWithFullSwipe = NO;
    return swipeActions;
}

@end
