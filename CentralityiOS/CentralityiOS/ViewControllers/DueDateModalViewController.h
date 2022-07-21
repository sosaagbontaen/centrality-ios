//
//  DueDateModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/21/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "TaskObject.h"
#import "FSCalendar.h"

@class DueDateModalViewController;

@protocol DueDateModalViewControllerDelegate <NSObject>
- (void)didChangeDuedate:(NSDate *)item toFeed:(DueDateModalViewController *)controller;
@end

@interface DueDateModalViewController : UIViewController
@property (nonatomic, weak) id <DueDateModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@end
