//
//  CategoryObject.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/20/22.
//

#import "CategoryObject.h"

@implementation CategoryObject

@dynamic categoryName;
@dynamic owner;

+ (nonnull NSString *)parseClassName {
    return @"CategoryObject";
}

@end
