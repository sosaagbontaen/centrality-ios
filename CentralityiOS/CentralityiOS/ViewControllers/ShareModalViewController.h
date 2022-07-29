//
//  ShareModalViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/27/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "TaskObject.h"

@class ShareModalViewController;

@protocol ShareModalViewControllerDelegate <NSObject>
- (void)didUpdateSharing:(PFUser *)user toFeed:(ShareModalViewController *)controller;
@end

@interface ShareModalViewController : UIViewController
@property (nonatomic, weak) id <ShareModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property NSMutableArray<PFUser*>*arrayOfUsers;
+ (NSMutableArray<NSString*>*)getArrayOfObjectIds:(NSMutableArray<PFUser*>*)userArray;
@end
