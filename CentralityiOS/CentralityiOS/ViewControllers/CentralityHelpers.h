//
//  CentralityHelpers.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
NS_ASSUME_NONNULL_BEGIN

@interface CentralityHelpers : UIViewController
+ (void)showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage currentVC:(UIViewController*)currentVC;
+ (NSMutableArray*)getArrayOfObjectIds:(NSMutableArray<PFUser*>*)userArray;
@end

NS_ASSUME_NONNULL_END
