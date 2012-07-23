//
//  RCITopicDetailViewController.m
//  Ruby China
//
//  Created by 来 诺 on 3/23/12.
//  Copyright (c) 2012 lainuo.info. All rights reserved.
//

#import "RCITopicDetailViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "DTCoreText.h"
#import "DTAttributedTextView.h"

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
    
    [SVProgressHUD showWithStatus:@"Loading..."];
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

- (NSAttributedString *)attributedStringFromHtml:(NSString *)htmlBodyString
{
    NSData *htmlBodyData = [htmlBodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create attributed string from HTML
    CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, nil];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:htmlBodyData options:options documentAttributes:NULL];
    
    return string;
}

#pragma mark - UITableViewDataSource
- (void)setBodyHtmlView:(UITableViewCell *)cell attributedHtmlString:(NSAttributedString *)attributedHtmlString
{
    DTAttributedTextView *bodyView = (DTAttributedTextView *)[cell viewWithTag:105];
    bodyView.contentView.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    bodyView.attributedString = attributedHtmlString;
    bodyView.scrollEnabled = NO;
    [bodyView setShowsHorizontalScrollIndicator:NO];
    [bodyView setShowsVerticalScrollIndicator:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
        
        NSString *htmlBodyString = [self.topicDetail objectForKey:@"body_html"];
        NSAttributedString *attributedHtmlString = [self attributedStringFromHtml:htmlBodyString];
        [self setBodyHtmlView:topicDetailCell attributedHtmlString:attributedHtmlString];
        
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
        
        NSString *htmlBodyString = [topicReply objectForKey:@"body_html"];
        NSAttributedString *attributedHtmlString = [self attributedStringFromHtml:htmlBodyString];
        [self setBodyHtmlView:topicReplyCell attributedHtmlString:attributedHtmlString];
        
        UIImageView *imageView = (UIImageView *)[topicReplyCell viewWithTag:106];
        NSURL *gravatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://gravatar.com/avatar/%@.png?s=46", [[topicReply objectForKey:@"user"] objectForKey:@"gravatar_hash"]]];
        [imageView setImageWithURL:gravatarUrl placeholderImage:[UIImage imageNamed:@"userPlaceHolder.png"]];
        return topicReplyCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat contentWidth = tableView.frame.size.width;
    CGFloat height = 0.0f;
    
    if (indexPath.row == 0) {
        NSString *htmlBodyString = [self.topicDetail objectForKey:@"body_html"];
        NSAttributedString *attributedHtmlString = [self attributedStringFromHtml:htmlBodyString];
        DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:attributedHtmlString width:contentWidth];
        CGSize expectedSize = [contentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth];
        height = expectedSize.height;
    } else {
        NSString *htmlBodyString = [[self.topicReplies objectAtIndex:(indexPath.row-1)] objectForKey:@"body_html"];
        NSAttributedString *attributedHtmlString = [self attributedStringFromHtml:htmlBodyString];
        DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithAttributedString:attributedHtmlString width:contentWidth];
        CGSize expectedSize = [contentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth];
        height = expectedSize.height;
    }
    
    if (height < 180.0f) {
        height += 130.0f;
    } else {
        height += 155.0f;
    }
    
    return height;
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
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.topicDetail = [JSON copy];
        [self.topicTableView reloadData];
        [self stopLoading];
        [SVProgressHUD dismiss];
        
    } failure:nil];
    
    [operation start];
}

@end
