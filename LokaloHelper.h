//
//  LokaloHelper.h
//  LokaloApp
//
//  Created by Ian MacKinnon on 2013-10-03.
//  Copyright (c) 2013 Ian MacKinnon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LokaloHelper : NSObject

+(void) handleRangedBeacon:(CLBeacon*)beacon;
+(void) handleUserCheckinResponse:(NSInteger)buttonIndex for:(NSDictionary*)userInfo;

@end
