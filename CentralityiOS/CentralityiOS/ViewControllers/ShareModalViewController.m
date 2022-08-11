//
//  ShareModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/27/22.
//

#import "ShareModalViewController.h"
#import "UserCell.h"
#import "CentralityHelpers.h"

@interface ShareModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@end
@implementation ShareModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userTableView.dataSource = self;
    self.userTableView.delegate = self;
    [self fetchUsers];
}

- (PFQuery*)queryAllSharedUsers{    
    PFQuery *sendingUser = [PFUser query];
    [sendingUser whereKey:@"objectId" equalTo:self.taskToUpdate.owner.objectId];
    
    PFQuery *receivingUsers = [PFUser query];
    [receivingUsers whereKey:@"objectId" containedIn:[CentralityHelpers getArrayOfObjectIds:self.arrayOfUsers]];
    
    PFQuery *currentUser = [PFUser query];
    [currentUser whereKey:@"objectId" equalTo:PFUser.currentUser.objectId];
    
    PFQuery *allSharedUsers = [PFQuery orQueryWithSubqueries:@[sendingUser,receivingUsers,currentUser]];
    allSharedUsers.limit = kFeedLimit;
    
    return allSharedUsers;
}

- (void)fetchUsers{
    PFQuery *query = [self queryAllSharedUsers];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.arrayOfUsers = [users mutableCopy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.userTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = self.arrayOfUsers[indexPath.row];
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.userNameLabel.text = user.username;
    
    NSMutableArray* readAndWriteObjIds = [CentralityHelpers getArrayOfObjectIds:self.taskToUpdate.readAndWriteUsers];
    
    NSMutableArray* readOnlyObjIds = [CentralityHelpers getArrayOfObjectIds:self.taskToUpdate.readOnlyUsers];
    
    NSMutableArray* acceptedObjIds = [CentralityHelpers getArrayOfObjectIds:self.taskToUpdate.acceptedUsers];
    
    if ([acceptedObjIds containsObject:user.objectId]){
        if ([readAndWriteObjIds containsObject:user.objectId]){
            cell.privacyStatusLabel.text = @"Can Edit";
            cell.privacyStatusLabel.textColor = [UIColor systemTealColor];
        }
        if ([readOnlyObjIds containsObject:user.objectId]){
            cell.privacyStatusLabel.text = @"Read-Only";
            cell.privacyStatusLabel.textColor = [UIColor systemOrangeColor];
        }
    }
    else{
        cell.privacyStatusLabel.text = @"Pending";
        cell.privacyStatusLabel.textColor = [UIColor systemYellowColor];
    }
    if ([user.objectId isEqualToString:self.taskToUpdate.owner.objectId]){
        cell.privacyStatusLabel.text = @"Owner";
        cell.privacyStatusLabel.textColor = [UIColor systemPurpleColor];
    }
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFUser* selectedUser = self.arrayOfUsers[indexPath.row];
    NSMutableDictionary* dictOfReadOnlyUsers = [CentralityHelpers userDictionaryFromArray:self.taskToUpdate.readOnlyUsers];
    NSMutableDictionary* dictOfReadAndWriteUsers = [CentralityHelpers userDictionaryFromArray:self.taskToUpdate.readAndWriteUsers];
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Unshare" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        PFQuery *query = [self queryAllSharedUsers];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (users != nil) {
                [self.delegate didUpdateSharing:self.arrayOfUsers[indexPath.row] toFeed:self accessStatus:ReadAndWriteAccess updateType:MakeUnshared];
                [self.arrayOfUsers removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self fetchUsers];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        completionHandler(YES);
        
    }];
    
    UIContextualAction *readOnlyAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Read-Only" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        PFQuery *query = [self queryAllSharedUsers];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (users != nil) {
                [self.delegate didUpdateSharing:self.arrayOfUsers[indexPath.row] toFeed:self accessStatus:ReadOnlyAccess updateType:MakeReadOnly];
                if ([dictOfReadAndWriteUsers objectForKey:selectedUser.objectId]){
                    dictOfReadOnlyUsers[selectedUser.objectId] = selectedUser;
                    self.taskToUpdate.readOnlyUsers = [[dictOfReadOnlyUsers allValues] mutableCopy];
                    [dictOfReadAndWriteUsers removeObjectForKey:selectedUser.objectId];
                    self.taskToUpdate.readAndWriteUsers = [[dictOfReadAndWriteUsers allValues] mutableCopy];
                }
                [self fetchUsers];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        completionHandler(YES);
    }];
    
    UIContextualAction *allowEditingAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Writable" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        PFQuery *query = [self queryAllSharedUsers];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            if (users != nil) {
                [self.delegate didUpdateSharing:selectedUser toFeed:self accessStatus:ReadAndWriteAccess updateType:MakeWritable];
                if ([dictOfReadOnlyUsers objectForKey:selectedUser.objectId]){
                    dictOfReadAndWriteUsers[selectedUser.objectId] = selectedUser;
                    self.taskToUpdate.readAndWriteUsers = [[dictOfReadAndWriteUsers allValues] mutableCopy];
                    [dictOfReadOnlyUsers removeObjectForKey:selectedUser.objectId];
                    self.taskToUpdate.readOnlyUsers = [[dictOfReadOnlyUsers allValues] mutableCopy];
                }
                [self fetchUsers];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        completionHandler(YES);
    }];
    
    allowEditingAction.backgroundColor = [UIColor systemTealColor];
    readOnlyAction.backgroundColor = [UIColor systemOrangeColor];
    deleteAction.backgroundColor = [UIColor systemRedColor];
    
    UISwipeActionsConfiguration *swipeActions;
    if (![self.arrayOfUsers[indexPath.row].objectId isEqualToString: self.taskToUpdate.owner.objectId] && [PFUser.currentUser.objectId isEqualToString:self.taskToUpdate.owner.objectId]){
        swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, readOnlyAction, allowEditingAction]];
    }
    swipeActions.performsFirstActionWithFullSwipe = NO;
    return swipeActions;
}

- (IBAction)addUserAction:(id)sender {
    if ([self.userNameField.text isEqualToString:@""]){
        [CentralityHelpers showAlert:@"Empty username" alertMessage:@"Please enter a valid username" currentVC:self];
        return;
    }
    PFQuery* query = [self queryUserToAdd:self.userNameField.text];
    
    PFUser* userToAdd = [query getFirstObject];
    if (userToAdd){
        if (![userToAdd.objectId isEqualToString:PFUser.currentUser.objectId]){
            [self.delegate didUpdateSharing:userToAdd toFeed:self accessStatus:ReadAndWriteAccess updateType:MakeShared];
            [self.arrayOfUsers addObject:userToAdd];
            [self fetchUsers];
        }
        else{
            [CentralityHelpers showAlert:@"Cannot share task with yourself" alertMessage:@"You already own this task" currentVC:self];
        }
    }
    else{
        [CentralityHelpers showAlert:@"Invalid username" alertMessage:@"User could not be found" currentVC:self];
    }
}

- (PFQuery*)queryUserToAdd:(NSString*)receiverUsername{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:receiverUsername];
    query.limit = kFeedLimit;
    return query;
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
