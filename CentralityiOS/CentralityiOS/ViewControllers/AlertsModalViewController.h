//
//  AlertsModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"
#import "SuggestionObject.h"

@class AlertsModalViewController;

@protocol AlertsModalViewControllerDelegate <NSObject>
- (void)didAcceptOrDeclineTask:(TaskObject *)acceptedTask toFeed:(AlertsModalViewController *)controller;
- (void)didRespondToSuggestion: (AlertsModalViewController *)controller;
@end

@interface AlertsModalViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *modalTitle;
@property (weak, nonatomic) IBOutlet UITableView *receiverTableView;
@property NSMutableArray<TaskObject*>*arrayOfPendingSharedTasks;
@property NSMutableArray<SuggestionObject*>*arrayOfSuggestions;
@property (weak, nonatomic) IBOutlet UITabBar *modeTabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *shareRequestsTabBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *taskSuggestionsTabBarItem;
@property (nonatomic, weak) id <AlertsModalViewControllerDelegate> delegate;
@end

typedef NS_ENUM(NSInteger, AlertViewMode) {
    ShareViewMode,
    SuggestionViewMode
};
