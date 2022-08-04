//
//  CategoryModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "TaskObject.h"

@class CategoryModalViewController;

@protocol CategoryModalViewControllerDelegate <NSObject>
- (void)didChangeCategory:(CategoryObject *)item toFeed:(CategoryModalViewController *)controller;
@end

@interface CategoryModalViewController : UIViewController
@property (nonatomic, weak) id <CategoryModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (strong, nonatomic) NSMutableArray *arrayOfCategories;
@property (weak, nonatomic) IBOutlet UIButton *addCategoryButton;
@property (weak, nonatomic) IBOutlet UITextField *nameOfCategoryToAdd;
@property CategoryObject *currentTaskCategory;
-(void) fetchCategories;
@end
