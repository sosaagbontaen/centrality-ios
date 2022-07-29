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

static const NSInteger kFeedLimit = 20;
static NSString * const kCategoryClassName = @"CategoryObject";
static NSString * const kCreatedAtQueryKey = @"createdAt";
static NSString * const kSharedUsersQueryKey = @"sharedOwners";

@implementation ShareModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userTableView.dataSource = self;
    self.userTableView.delegate = self;
    [self fetchUsers];
}

+ (NSMutableArray*)getArrayOfObjectIds:(NSMutableArray<PFUser*>*)userArray{
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    for (PFUser* user in userArray) {
        [returnArray addObject:user.objectId];
    }
    return returnArray;
}

- (PFQuery*)querySharedUsers{
    PFQuery *query = [PFUser query];
    [query orderByDescending:kCreatedAtQueryKey];
    [query whereKey:@"objectId" containedIn:[ShareModalViewController getArrayOfObjectIds:self.arrayOfUsers]];
    query.limit = kFeedLimit;
    return query;
}

- (void)fetchUsers{
    PFQuery *query = [self querySharedUsers];
    
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
    return cell;
}

- (IBAction)addUserAction:(id)sender {
    if ([self.userNameField.text isEqualToString:@""]){
        [CentralityHelpers showAlert:@"Empty username" alertMessage:@"Please enter a valid username" currentVC:self];
        return;
    }
    PFQuery* query = [self queryUserToAdd:self.userNameField.text];
    
    PFUser* userToAdd = [query getFirstObject];
    if (userToAdd){
        [self.delegate didUpdateSharing:userToAdd toFeed:self];
        [self dismissViewControllerAnimated:YES completion:^{}];
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

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
