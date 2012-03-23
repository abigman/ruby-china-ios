//
//  RCITopicDetailViewController.m
//  Ruby China
//
//  Created by 来 诺 on 3/23/12.
//  Copyright (c) 2012 lainuo.info. All rights reserved.
//

#import "RCITopicDetailViewController.h"
#import "AFNetworking.h"

NSString *const RCITopicBaseUrlString = @"http://ruby-china.org/api/topics/";

@interface RCITopicDetailViewController ()
@property (nonatomic, strong) NSDictionary *topicDetail;
@property (nonatomic, weak) IBOutlet UITableView* topicTableView;
@end

@implementation RCITopicDetailViewController
@synthesize topicId = _topicId;
@synthesize topicDetail = _topicDetail;
@synthesize topicTableView = _topicTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performTopicDetailRequest];
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
    NSLog(@"are we here?");
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *topicDetailCellIdentifier = @"Topic Detail";
    UITableViewCell *topicDetailCell = [tableView dequeueReusableCellWithIdentifier:topicDetailCellIdentifier];
    if (indexPath.row == 0) {        
        //NSDictionary *topic = [self.topicDetail objectAtIndex:indexPath.row];
        
        UILabel *titleLabel = (UILabel *)[topicDetailCell viewWithTag:101];
        titleLabel.text = [self.topicDetail objectForKey:@"title"];
        UILabel *userLabel = (UILabel *)[topicDetailCell viewWithTag:102];
        userLabel.text = [[self.topicDetail objectForKey:@"user"] objectForKey:@"login"];
        UILabel *nodeLabel = (UILabel *)[topicDetailCell viewWithTag:103];
        nodeLabel.text = [self.topicDetail objectForKey:@"node_name"];
        UILabel *countLabel = (UILabel *)[topicDetailCell viewWithTag:104];
        countLabel.text = [[self.topicDetail objectForKey:@"replies_count"] stringValue];
        
        UILabel *bodyLabel = (UILabel *)[topicDetailCell viewWithTag:105];
        NSString *bodyString = [self.topicDetail objectForKey:@"body"];
        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(296,9999);
        
        CGSize expectedLabelSize = [bodyString sizeWithFont:bodyLabel.font constrainedToSize:maximumLabelSize lineBreakMode:bodyLabel.lineBreakMode]; 
        
        //adjust the label the the new height.
        CGRect newFrame = bodyLabel.frame;
        newFrame.size.height = expectedLabelSize.height;
        bodyLabel.frame = newFrame;
        bodyLabel.text = bodyString;
        
        UIImageView *imageView = (UIImageView *)[topicDetailCell viewWithTag:106];
        NSURL *gravatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://gravatar.com/avatar/%@.png?s=40", [[self.topicDetail objectForKey:@"user"] objectForKey:@"gravatar_hash"]]];
        [imageView setImageWithURL:gravatarUrl placeholderImage:[UIImage imageNamed:@"userPlaceHolder.png"]];;
        
        return topicDetailCell;
    }
    return topicDetailCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *topicDetailCellIdentifier = @"Topic Detail";
        UITableViewCell *topicDetailCell = [tableView dequeueReusableCellWithIdentifier:topicDetailCellIdentifier];
        UILabel *bodyLabel = (UILabel *)[topicDetailCell viewWithTag:105];
        NSString *bodyString = [self.topicDetail objectForKey:@"body"];
        //Calculate the expected size based on the font and linebreak mode of your label
        CGSize maximumLabelSize = CGSizeMake(296,9999);

        CGSize expectedLabelSize = [bodyString sizeWithFont:bodyLabel.font constrainedToSize:maximumLabelSize lineBreakMode:bodyLabel.lineBreakMode]; 
        
        //adjust the label the the new height.
        return expectedLabelSize.height + 85.0f;
    }
    NSString *bodyString = [self.topicDetail objectForKey:@"body"];
    CGSize bodySize = [bodyString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13.0f] constrainedToSize:CGSizeMake(260.0f, MAXFLOAT)];

    CGFloat height = 85.0f;
    height = bodySize.height + 44.0f;
    return height;
}

- (void)refresh
{
    [self performTopicDetailRequest];
}

- (void)performTopicDetailRequest
{
    NSString *detailUrl = [RCITopicBaseUrlString stringByAppendingFormat:@"%@.json", self.topicId];
    NSURL *url = [NSURL URLWithString:detailUrl];
    NSLog(@"URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.topicDetail = [JSON copy];
        [self.topicTableView reloadData];
        [self stopLoading];
        
    } failure:nil];
    
    [operation start];
}

@end
