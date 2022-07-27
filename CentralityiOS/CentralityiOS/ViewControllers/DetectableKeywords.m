//
//  DetectableKeywords.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/26/22.
//

#import "DetectableKeywords.h"

@interface DetectableKeywords ()

@end

@implementation DetectableKeywords

+ (NSArray<NSString *> *)getTodayKeywords{
    NSArray<NSString *> *todayKeywords = @[@"today", @"now", @"EOD"];
    return todayKeywords;
}

+ (NSArray<NSString *> *)getTomorrowKeywords{
    NSArray<NSString *> *tomorrowKeywords = @[@"tmrw", @"tomorrow", @"2mrw"];
    return tomorrowKeywords;
}

+ (NSArray<NSString *> *)getYesterdayKeywords{
    NSArray<NSString *> *yesterdayKeywords = @[@"yesterday"];
    return yesterdayKeywords;
}

@end
