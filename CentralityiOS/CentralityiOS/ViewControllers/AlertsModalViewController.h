//
//  AlertsModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"

@class AlertsModalViewController;

@protocol AlertsModalViewControllerDelegate <NSObject>
- (void)didAcceptTask:(TaskObject *)acceptedTask toFeed:(AlertsModalViewController *)controller;
@end

@interface AlertsModalViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *receiverTableView;
@property NSMutableArray<TaskObject*>*arrayOfPendingSharedTasks;
@property (nonatomic, weak) id <AlertsModalViewControllerDelegate> delegate;
@end
