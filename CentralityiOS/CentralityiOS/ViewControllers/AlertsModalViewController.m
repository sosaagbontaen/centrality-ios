//
//  AlertsModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/1/22.
//

#import "AlertsModalViewController.h"
#import "ReceiverCell.h"

@interface AlertsModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@end


static NSString * const kTaskClassName = @"TaskObject";

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
    ReceiverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell" forIndexPath:indexPath];
    return cell;
}

- (PFQuery*)queryAllReceivedTasks{
    PFQuery *receivedTasks = [PFQuery queryWithClassName:kTaskClassName];
    return receivedTasks;
}

- (void)fetchReceivedTasks{
    PFQuery *query = [self queryAllReceivedTasks];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.arrayOfPendingSharedTasks = [users mutableCopy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.receiverTableView reloadData];
    }];
}

@end
