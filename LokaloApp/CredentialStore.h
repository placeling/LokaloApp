//
//  CredentialStore.h
//  Winterfell
//
//  Created by Ian MacKinnon on 2013-08-18.
//  Copyright (c) 2013 Ian MacKinnon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject

- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;
- (NSString *)authToken;
- (void)setAuthToken:(NSString *)authToken;

@end