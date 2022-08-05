//
//  SuggestionObject.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/4/22.
//

#import "SuggestionObject.h"

@implementation SuggestionObject

@dynamic owner;
@dynamic associatedTask;
@dynamic suggestionType;

+ (nonnull NSString *)parseClassName {
    return @"SuggestionObject";
}

@end
