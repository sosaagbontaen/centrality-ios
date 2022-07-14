//
//  ToDoFeedViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "Parse/Parse.h"
#import "AddTaskModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ToDoFeedViewController : UIViewController <AddTaskModalViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (strong, nonatomic) NSMutableArray *arrayOfTasks;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *addTaskButton;
-(void) fetchData;
@end

NS_ASSUME_NONNULL_END
