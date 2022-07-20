//
//  TaskObject.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import <Parse/Parse.h>
#import "CategoryObject.h"

NS_ASSUME_NONNULL_BEGIN
@interface TaskObject : PFObject<PFSubclassing>
@property (nonatomic) NSInteger taskID;
@property (nonatomic, strong) PFUser *owner;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSString *taskTitle;
@property (nonatomic, strong) NSString *taskDesc;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic, strong) CategoryObject *category;
@end

NS_ASSUME_NONNULL_END
