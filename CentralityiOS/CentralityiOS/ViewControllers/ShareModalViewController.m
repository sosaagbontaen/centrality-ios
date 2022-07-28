//
//  ShareModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/27/22.
//

#import "ShareModalViewController.h"
#import "UserCell.h"

@interface ShareModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

static const NSInteger kFeedLimit = 20;
static NSString * const kCategoryClassName = @"CategoryObject";
static NSString * const kCreatedAtQueryKey = @"createdAt";

@implementation ShareModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userTableView.dataSource = self;
    self.userTableView.delegate = self;
    [self fetchUsers];
}

- (PFQuery*)makeQuery{
    PFQuery *query = [PFUser query];
    [query orderByDescending:kCreatedAtQueryKey];
    //[query whereKey:kByOwnerQueryKey equalTo:[PFUser currentUser]];
    query.limit = kFeedLimit;
    return query;
}

- (void)fetchUsers{
    PFQuery *query = [self makeQuery];
    
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
        NSLog(@"Empty username");
        return;
    }
    [self.delegate didUpdateSharing:PFUser.currentUser toFeed:self];
    NSLog(@"Added %@", PFUser.currentUser);
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
