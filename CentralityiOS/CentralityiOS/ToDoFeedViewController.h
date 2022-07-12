//
//  ToDoFeedViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ToDoFeedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (strong, nonatomic) NSArray *arrayOfTasks;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

NS_ASSUME_NONNULL_END
