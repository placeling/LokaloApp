//
//  Location.h
//  LokaloApp
//
//  Created by Ian MacKinnon on 2013-10-03.
//  Copyright (c) 2013 Ian MacKinnon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * last_seen;
@property (nonatomic, retain) NSNumber * auto_checkin;
@property (nonatomic, retain) NSNumber * block_checkin;

@end
