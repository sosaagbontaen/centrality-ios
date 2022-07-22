//
//  DateFormatHelper.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/22/22.
//

#import "DateFormatHelper.h"
#import "DateTools.h"

@interface DateFormatHelper ()

@end

@implementation DateFormatHelper

+ (NSString*)formatDateAsString:(NSDate*)dateToFormat{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([dateToFormat isSameDay:NSDate.date]){
        return @"Today";
    }
    if ([dateToFormat isSameDay:[NSDate.date dateByAddingDays:1]]){
        return @"Tomorrow";
    }
    if ([dateToFormat isSameDay:[NSDate.date dateBySubtractingDays:1]]){
        return @"Yesterday";
    }
    if (dateToFormat.year == NSDate.date.year){
        formatter.dateFormat = @"MM/dd";
    }
    else{
        formatter.dateFormat = @"MM/dd/yy";
    }
    return [formatter stringFromDate:dateToFormat];
}
@end
