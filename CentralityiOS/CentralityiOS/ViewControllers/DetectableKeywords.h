//
//  DetectableKeywords.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/26/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetectableKeywords : UIViewController
+(NSArray<NSString *> *)getTodayKeywords;
+(NSArray<NSString *> *)getTomorrowKeywords;
+(NSArray<NSString *> *)getYesterdayKeywords;
@end

NS_ASSUME_NONNULL_END
