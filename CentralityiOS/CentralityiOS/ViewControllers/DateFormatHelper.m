//
//  DateFormatHelper.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/22/22.
//

#import "DateFormatHelper.h"

@interface DateFormatHelper ()

@end

@implementation DateFormatHelper

+ (NSString*)formatDateAsString:(NSDate*)dateToFormat{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yy";
    return [formatter stringFromDate:dateToFormat];
}
@end
