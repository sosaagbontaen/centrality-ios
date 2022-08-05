//
//  SuggestionObject.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/4/22.
//

#import <Parse/Parse.h>
#import "TaskObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface SuggestionObject : PFObject<PFSubclassing>
@property TaskObject *associatedTask;
@property (nonatomic, strong) PFUser *owner;
@end

NS_ASSUME_NONNULL_END
