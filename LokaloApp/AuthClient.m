//
//  AuthClient.m
//  AuthClient
//
//  Created by Ben Scheirman on 11/4/12.
//  Copyright (c) 2012 nsscreencast. All rights reserved.
//

#import "AuthClient.h"
#import "CredentialStore.h"

@implementation AuthClient

+ (id)sharedClient {
    static AuthClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:SERVER_URL];
        __instance = [[AuthClient alloc] initWithBaseURL:baseUrl];
    });
    return __instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setAuthTokenHeader];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenChanged:)
                                                     name:@"token-changed"
                                                   object:nil];
    }
    return self;
}

- (void)setAuthTokenHeader {
    CredentialStore *store = [[CredentialStore alloc] init];
    NSString *authToken = [store authToken];
    [self setDefaultHeader:@"X-API-TOKEN" value:authToken];
}

- (void)tokenChanged:(NSNotification *)notification {
    [self setAuthTokenHeader];
}

@end
