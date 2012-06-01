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
@property (nonatomic, strong) NSArray *topicReplies;
@property (nonatomic, weak) IBOutlet UITableView* topicTableView;
@end

@implementation RCITopicDetailViewController
@synthesize topicId = _topicId;
@synthesize topicDetail = _topicDetail;
@synthesize topicReplies = _topicReplies;
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

- (NSArray *)topicReplies
{
    if (!_topicReplies) {
        _topicReplies = [self.topicDetail objectForKey:@"replies"];
    }
    
    return _topicReplies;
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
    //return [[self topicReplies] count] + 1;
    return [[self.topicDetail objectForKey:@"replies"] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *topicDetailCellIdentifier = @"Topic Detail";
        UITableViewCell *topicDetailCell = [tableView dequeueReusableCellWithIdentifier:topicDetailCellIdentifier];
        topicDetailCell.backgroundColor=[UIColor lightGrayColor];
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
        CGSize expectedLabelSize = [self labelSize:@"Topic Detail" withLabelTag:105 withBodyString:bodyString];
        NSLog(@"Body label size: %f", expectedLabelSize.height);
        //adjust the label the the new height.
        CGRect newFrame = bodyLabel.frame;
        newFrame.size.height = expectedLabelSize.height + 90.0f;
        bodyLabel.frame = newFrame;
        bodyLabel.text = bodyString;
        NSLog(@"%@", bodyString);
        
        UIImageView *imageView = (UIImageView *)[topicDetailCell viewWithTag:106];
        NSURL *gravatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://gravatar.com/avatar/%@.png?s=40", [[self.topicDetail objectForKey:@"user"] objectForKey:@"gravatar_hash"]]];
        [imageView setImageWithURL:gravatarUrl placeholderImage:[UIImage imageNamed:@"userPlaceHolder.png"]];
        
        return topicDetailCell;
    } else {
        static NSString *topicReplyCellIdentifier = @"Reply";
        UITableViewCell *topicReplyCell = [tableView dequeueReusableCellWithIdentifier:topicReplyCellIdentifier];
        topicReplyCell.backgroundColor=[UIColor lightGrayColor];
        NSDictionary *topicReply = [self.topicReplies objectAtIndex:(indexPath.row-1)];
        
        UILabel *titleLabel = (UILabel *)[topicReplyCell viewWithTag:101];
        titleLabel.text = [topicReply objectForKey:@"title"];
        UILabel *userLabel = (UILabel *)[topicReplyCell viewWithTag:102];
        userLabel.text = [[topicReply objectForKey:@"user"] objectForKey:@"login"];
        UILabel *nodeLabel = (UILabel *)[topicReplyCell viewWithTag:103];
        nodeLabel.text = [topicReply objectForKey:@"node_name"];
        UILabel *countLabel = (UILabel *)[topicReplyCell viewWithTag:104];
        countLabel.text = [[topicReply objectForKey:@"replies_count"] stringValue];
        
        UILabel *bodyLabel = (UILabel *)[topicReplyCell viewWithTag:105];
        NSString *bodyString = [topicReply objectForKey:@"body"];
        CGSize expectedLabelSize = [self labelSize:@"Reply" withLabelTag:105 withBodyString:bodyString];
        //adjust the label the the new height.
        CGRect newFrame = bodyLabel.frame;
        newFrame.size.height = expectedLabelSize.height + 30.0f;
        bodyLabel.frame = newFrame;
        bodyLabel.text = bodyString;
        
        UIImageView *imageView = (UIImageView *)[topicReplyCell viewWithTag:106];
        NSURL *gravatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://gravatar.com/avatar/%@.png?s=40", [[topicReply objectForKey:@"user"] objectForKey:@"gravatar_hash"]]];
        [imageView setImageWithURL:gravatarUrl placeholderImage:[UIImage imageNamed:@"userPlaceHolder.png"]];
        return topicReplyCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSString *bodyString = [self.topicDetail objectForKey:@"body"];
        NSString *titleString = [self.topicDetail objectForKey:@"title"];
        CGSize titleLabelSize = [self labelSize:@"Topic Detail" withLabelTag:101 withBodyString:titleString];
        CGSize bodyLabelSize = [self labelSize:@"Topic Detail" withLabelTag:105 withBodyString:bodyString];
        NSLog(@"Header size: %f", titleLabelSize.height + bodyLabelSize.height);
        return titleLabelSize.height + bodyLabelSize.height + 160.0f;
    } else {
        NSString *bodyString = [[self.topicReplies objectAtIndex:(indexPath.row-1)] objectForKey:@"body"];
        CGSize bodyLabelSize = [self labelSize:@"Reply" withLabelTag:105 withBodyString:bodyString];
        return bodyLabelSize.height + 85.0f;
    }
}

- (CGSize)labelSize:(NSString *)cellIdentifier withLabelTag:(NSInteger)tag withBodyString:(NSString *)bodyString
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *label = (UILabel *)[cell viewWithTag:tag];
    
    //Calculate the expected size based on the font and linebreak mode of body label
    //CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize maximumLabelSize = CGSizeMake(280,9000);
    
    CGSize expectedLabelSize = [bodyString sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    return expectedLabelSize;
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
