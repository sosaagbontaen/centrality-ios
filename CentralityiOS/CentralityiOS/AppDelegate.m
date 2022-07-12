//
//  AppDelegate.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/8/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
NSString *path;
NSDictionary *dict;
NSString *applicationId;
NSString *clientKey;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
        dict = [NSDictionary dictionaryWithContentsOfFile: path];

        applicationId = [dict objectForKey: @"applicationId"];
        clientKey = [dict objectForKey: @"clientKey"];
        
        configuration.applicationId = [NSString stringWithFormat:@"%@", applicationId];
        configuration.clientKey = [NSString stringWithFormat: @"%@", clientKey];
        configuration.server = @"https://parseapi.back4app.com";
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
