//
//  AppDelegate.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/8/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"

static NSString * const kapplicationIdObj = @"applicationId";
static NSString * const kclientKeyObj = @"clientKey";
static NSString * const kserverURL = @"https://parseapi.back4app.com";
static NSString * const kFileName = @"Keys";
static NSString * const kFileExtension = @"plist";

@implementation AppDelegate
    

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        NSString *path = [[NSBundle mainBundle] pathForResource: kFileName ofType: kFileExtension];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

        NSString *applicationId = [dict objectForKey: kapplicationIdObj];
        NSString *clientKey = [dict objectForKey: kclientKeyObj];
        
        configuration.applicationId = [NSString stringWithFormat:@"%@", applicationId];
        configuration.clientKey = [NSString stringWithFormat: @"%@", clientKey];
        configuration.server = kserverURL;
    }];

    [Parse initializeWithConfiguration:config];
    return YES;
}


#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}
@end
