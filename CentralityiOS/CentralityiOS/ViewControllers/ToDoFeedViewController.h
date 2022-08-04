//
//  ToDoFeedViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "Parse/Parse.h"
#import "ModifyTaskModalViewController.h"
#import "CategoryModalViewController.h"
#import "AlertsModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ToDoFeedViewController : UIViewController <ModifyTaskModalViewControllerDelegate, AlertsModalViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *alertButton;
@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (strong, nonatomic) NSMutableArray *arrayOfTasks;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *addTaskButton;
@property (weak, nonatomic) IBOutlet UILabel *feedMessageLabel;
-(void) fetchTasks;
@end

NS_ASSUME_NONNULL_END
