//
//  AppDelegate.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "ToDoFeedViewController.h"
#import "AddTaskModalViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic) ToDoFeedViewController *toDoFeedViewController;
@property (nonatomic) AddTaskModalViewController *addTaskModalViewController;
@end

