//
//  RCIUser.m
//  Ruby China
//
//  Created by 来 诺 on 3/4/12.
//  Copyright (c) 2012 lainuo.info. All rights reserved.
//

#import "RCIUser.h"

@implementation RCIUser

@synthesize login = _login;
@synthesize name = _name;
@synthesize location = _location;
@synthesize bio = _bio;
@synthesize tagline = _tagline;
@synthesize website = _website;
@synthesize githubUrl = _githubUrl;
@synthesize gravatarHash = _gravatarHash;

@synthesize loadingGravatar = _loadingGravatar;
@synthesize gravatar = _gravatar;

static NSOperationQueue *sharedGravatarOperationQueue() {
    static NSOperationQueue *sharedGravatarOperationQueue = nil;
    if (sharedGravatarOperationQueue == nil) {
        sharedGravatarOperationQueue = [[NSOperationQueue alloc] init];
    }
    return sharedGravatarOperationQueue;    
}

- (NSURL *)gravatarUrl {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://gravatar.com/avatar/%@.png?s=40", self.gravatarHash]];
}

- (void)loadGravatar {
    @synchronized (self) {
        if (self.gravatar == nil && !self.loadingGravatar) {
            self.loadingGravatar = YES;
            [sharedGravatarOperationQueue() addOperationWithBlock:^(void) {
                NSData *imageData = [NSData dataWithContentsOfURL:[self gravatarUrl]];
                UIImage *image = [UIImage imageWithData:imageData];
                if (image != nil) {
                    @synchronized (self) {
                        self.loadingGravatar = NO;
                        self.gravatar = image;
                    }
                } else {
                    @synchronized (self) {
                        self.gravatar = nil;
                    }
                }
            }];
        }
    }
}

@end
