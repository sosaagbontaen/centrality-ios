//
//  CategoryObject.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/20/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryObject : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) PFUser *owner;
@end

NS_ASSUME_NONNULL_END
