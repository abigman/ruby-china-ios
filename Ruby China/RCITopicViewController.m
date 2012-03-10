//
//  RCIViewController.m
//  Ruby China
//
//  Created by 来 诺 on 3/4/12.
//  Copyright (c) 2012 lainuo.info. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RCITopicViewController.h"
#import "AFNetworking.h"

NSString *const RCITopicUrlString = @"http://ruby-china.org/api/topics.json";

@interface RCITopicViewController ()
@property (nonatomic, strong) NSArray *topics;
@property (nonatomic, weak) IBOutlet UITableView* topicTableView;
@end

@implementation RCITopicViewController
@synthesize topicTableView = _topicTableView;
@synthesize topics = _topics;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performTopicsRequest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Topic Summary";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *topic = [self.topics objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text = [topic objectForKey:@"title"];
    UILabel *userLabel = (UILabel *)[cell viewWithTag:102];
    userLabel.text = [[topic objectForKey:@"user"] objectForKey:@"login"];
    UILabel *nodeLabel = (UILabel *)[cell viewWithTag:103];
    nodeLabel.text = [topic objectForKey:@"node_name"];
    UILabel *countLabel = (UILabel *)[cell viewWithTag:104];
    countLabel.text = [[topic objectForKey:@"replies_count"] stringValue];
    countLabel.layer.cornerRadius = 4;
    
    UIActivityIndicatorView *progressIndicator = (UIActivityIndicatorView *)[cell viewWithTag:105];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:106];
    NSURL *gravatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://gravatar.com/avatar/%@.png?s=40", [[topic objectForKey:@"user"] objectForKey:@"gravatar_hash"]]];
    [imageView setImageWithURL:gravatarUrl placeholderImage:[UIImage imageNamed:@"userPlaceHolder.png"]];;
    [progressIndicator stopAnimating];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)refresh
{
    [self performTopicsRequest];
}

- (void)performTopicsRequest
{    
    NSURL *url = [NSURL URLWithString:RCITopicUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.topics = [JSON copy];
        [self.topicTableView reloadData];
        [self stopLoading];
        
    } failure:nil];
    
    [operation start];
}
@end
