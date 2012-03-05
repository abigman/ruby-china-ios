//
//  RCIUser.h
//  Ruby China
//
//  Created by 来 诺 on 3/4/12.
//  Copyright (c) 2012 lainuo.info. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCIUser : NSObject

@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *githubUrl;
@property (nonatomic, strong) NSString *gravatarHash;

@property (assign) BOOL loadingGravatar;
@property (nonatomic, strong) UIImage *gravatar;

- (void)loadGravatar;

@end
