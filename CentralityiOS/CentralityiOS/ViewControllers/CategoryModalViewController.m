//
//  CategoryModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/20/22.
//

#import "CategoryModalViewController.h"
#import "CategoryCell.h"
#import "CentralityHelpers.h"

@interface CategoryModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation CategoryModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.categoryTableView.dataSource = self;
    self.categoryTableView.delegate = self;
    [self fetchCategories];
}


- (PFQuery*)makeQuery{
    PFQuery *query = [PFQuery queryWithClassName:kByCategoryClassName];
    [query orderByDescending:kByCreatedAtQueryKey];
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

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryObject *category = self.arrayOfCategories[indexPath.row];
    [self.delegate didChangeCategory:category toFeed:self];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        PFQuery *query = [self makeQuery];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
            if (tasks != nil) {
                [self.arrayOfCategories[indexPath.row] deleteInBackground];
                [self.arrayOfCategories removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self fetchCategories];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        completionHandler(YES);
        
    }];
    
    deleteAction.backgroundColor = [UIColor systemRedColor];
    
    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    swipeActions.performsFirstActionWithFullSwipe = NO;
    return swipeActions;
}

- (IBAction)addCategoryAction:(id)sender {
    if ([self.nameOfCategoryToAdd.text isEqualToString:@""]){
        [CentralityHelpers showAlert:@"Empty Category Name" alertMessage:@"Please name this category" currentVC:self];
        return;
    }
    
    CategoryObject *newCategory = [CategoryObject new];
    newCategory.categoryName = self.nameOfCategoryToAdd.text;
    newCategory.owner = [PFUser currentUser];
    
    [newCategory saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self fetchCategories];
            self.nameOfCategoryToAdd.text = @"";
        }
        else {
            NSLog(@"Category not added to Parse : %@", error.localizedDescription);
        }
    }];
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
