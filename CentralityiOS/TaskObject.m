//
//  TaskObject.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "TaskObject.h"

@implementation TaskObject
@dynamic taskID;
@dynamic owner;
@dynamic sharedOwners;
@dynamic readOnlyUsers;
@dynamic readAndWriteUsers;
@dynamic acceptedUsers;
@dynamic dateCompleted;
@dynamic dueDate;
@dynamic taskTitle;
@dynamic taskDesc;
@dynamic isCompleted;
@dynamic category;

+ (nonnull NSString *)parseClassName {
    return @"TaskObject";
}

@end
