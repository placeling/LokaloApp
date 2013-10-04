//
//  LokaloHelper.m
//  LokaloApp
//
//  Created by Ian MacKinnon on 2013-10-03.
//  Copyright (c) 2013 Ian MacKinnon. All rights reserved.
//

#import "LokaloHelper.h"
#import "Location.h"

@implementation LokaloHelper

+(void) promptForAuthorization:(Location*)location{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = [NSString stringWithFormat:@"Do you want to checkin to %@", location.name];
    NSDictionary *userInfo = @{@"major":location.major, @"minor":location.minor, @"name":location.name};
    
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
}

+(void) handleUserCheckinResponse:(NSInteger)buttonIndex for:(NSDictionary*)userInfo{
    
    NSArray *locations = [Location MR_findByAttribute:@"major" withValue:[userInfo objectForKey:@"major"]];
    Location *location  = [locations objectAtIndex:0];
    
    switch (buttonIndex) {
        case 0: {
            //yes
            [LokaloHelper performCheckin:location];
            break;
            
        }case 1: {
            //no
            break;
        }
        case 2: {
            //Always
            location.auto_checkin = [NSNumber numberWithBool:true];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [LokaloHelper performCheckin:location];
            break;
            
        }
        case 3: {
            //never
            location.block_checkin = [NSNumber numberWithBool:true];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            break;
        }

    }
    
}


+(void) performCheckin:(Location*)location{
   
    NSString *fb_token = FBSession.activeSession.accessTokenData.accessToken;
    NSString *major = [location.major stringValue];
    NSString *minor = [location.minor stringValue];
    
    NSDictionary *dict = @{@"fb_token":fb_token,
                           @"major": major,
                           @"minor":minor};
    
    
    [[AuthClient sharedClient] postPath:@"/api/checkin" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        notification.alertBody = [NSString stringWithFormat:@"You were checked in to %@", location.name];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
}

+(void)clearCheckins{
    //[Location MR_truncateAll];// for testing
    NSString *fb_token = FBSession.activeSession.accessTokenData.accessToken;
    
    NSDictionary *dict = @{@"fb_token":fb_token};
    [[AuthClient sharedClient] postPath:@"/api/clear" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"cleared checkins");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

+(void) grabNameData:(Location*)location  withPrompt:(bool)prompt{
    
    NSDictionary *dict = @{@"major": location.major,
                           @"minor": location.minor};
    
    [[AuthClient sharedClient] getPath:@"/locations/lookup" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = responseObject;
        NSArray *location_dict = [dict objectForKey:@"locations"];
        if ([location_dict count] == 1){
            NSDictionary *raw_loc = [location_dict objectAtIndex:0];
            location.name = [raw_loc objectForKey:@"name"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            if (prompt){
                [LokaloHelper promptForAuthorization:location];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


+(void) handleRangedBeacon:(CLBeacon*)beacon {
    NSLog(@"Ranged a beacon major:%@ minor:%@", beacon.major, beacon.minor);
    
    NSArray *locations = [Location MR_findByAttribute:@"major" withValue:beacon.major];
    if ( [locations count] > 0){
        Location *location = [locations objectAtIndex:0];
        NSTimeInterval interval = [location.last_seen timeIntervalSinceNow];
        
        if ( (-1*interval) > 1*60 && ![location.block_checkin boolValue]){
            if ( [location.auto_checkin boolValue]){
                [LokaloHelper performCheckin:(Location*)location];
            } else {
                [LokaloHelper promptForAuthorization:location];
            }
            location.last_seen = [NSDate date];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        
        
    } else {
        Location *location = [Location MR_createEntity];
        location.major = beacon.major;
        location.minor = beacon.minor;
        location.last_seen = [NSDate date];
        location.auto_checkin = [NSNumber numberWithBool:false];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [LokaloHelper grabNameData:location withPrompt:true];
    }
    
    
    
}

@end
