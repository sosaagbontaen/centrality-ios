//
//  CategoryModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/20/22.
//

#import "CategoryModalViewController.h"
#import "CategoryCell.h"

@interface CategoryModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

static const NSInteger kToDoFeedLimit = 20;
static NSString * const kCategoryClassName = @"CategoryObject";
static NSString * const kByOwnerQueryKey = @"owner";
static NSString * const kCreatedAtQueryKey = @"createdAt";

@implementation CategoryModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.categoryTableView.dataSource = self;
    self.categoryTableView.delegate = self;
    [self fetchCategories];
}


- (PFQuery*)makeQuery{
    PFQuery *query = [PFQuery queryWithClassName:kCategoryClassName];
    [query orderByDescending:kCreatedAtQueryKey];
    [query whereKey:kByOwnerQueryKey equalTo:[PFUser currentUser]];
    query.limit = kToDoFeedLimit;
    return query;
}

- (void)fetchCategories{
    PFQuery *query = [self makeQuery];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *categories, NSError *error) {
        if (categories != nil) {
            self.arrayOfCategories = [categories mutableCopy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.categoryTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryObject *category = self.arrayOfCategories[indexPath.row];
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    cell.category = category;
    cell.categoryNameLabel.text = category.categoryName;
    return cell;
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
