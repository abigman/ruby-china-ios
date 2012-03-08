//
//  RCIViewController.m
//  Ruby China
//
//  Created by 来 诺 on 3/4/12.
//  Copyright (c) 2012 lainuo.info. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RCITopicViewController.h"
#import "RCITopic.h"

NSString *const RCITopicPropertyNamedGravatar = @"user.gravatar";

@interface RCITopicViewController ()
@property (nonatomic, strong) NSArray *topics;
@property (nonatomic, weak) IBOutlet UITableView* topicTableView;
@property (nonatomic, strong) NSMutableArray *observedVisibleItems;
@end

@implementation RCITopicViewController
@synthesize topicTableView = _topicTableView;
@synthesize topics = _topics;
@synthesize observedVisibleItems = _observedVisibleItems;

- (NSMutableArray *)observedVisibleItems
{
    if (!_observedVisibleItems) {
        _observedVisibleItems = [[NSMutableArray alloc] init];
    }
    
    return _observedVisibleItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    RKObjectMapping *topicMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[RCITopic class]];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/api/topics.json" objectMapping:topicMapping delegate:self];

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

#pragma mark - RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray *)objects {
    self.topics = [objects copy];
    NSLog(@"KKKKKK");
    [self.topicTableView reloadData];
    [self stopLoading];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError *)error {
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
    
    RCITopic *topic = [self.topics objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
	titleLabel.text = topic.title;
    UILabel *userLabel = (UILabel *)[cell viewWithTag:102];
	userLabel.text = topic.user.login;
    UILabel *nodeLabel = (UILabel *)[cell viewWithTag:103];
	nodeLabel.text = topic.nodeName;
    UILabel *countLabel = (UILabel *)[cell viewWithTag:104];
	countLabel.text = topic.repliesCount.stringValue;
    countLabel.layer.cornerRadius = 4;
    // cell.textLabel.text = topic.title;

    if (![self.observedVisibleItems containsObject:topic.user]) {
        [topic addObserver:self forKeyPath:RCITopicPropertyNamedGravatar options:0 context:NULL];
        [topic.user loadGravatar];
        [self.observedVisibleItems addObject:topic.user];
    }
    
    UIActivityIndicatorView *progressIndicator = (UIActivityIndicatorView *)[cell viewWithTag:105];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:106];
    if (topic.user.gravatar == nil) {
        [progressIndicator setHidden:NO];
    } else {
        imageView.image = topic.user.gravatar;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)refresh
{
    RKObjectMapping *topicMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[RCITopic class]];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/api/topics.json" objectMapping:topicMapping delegate:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:RCITopicPropertyNamedGravatar]) {
        [self performSelectorOnMainThread:@selector(reloadRowForEntity:) withObject:object waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}

- (void)reloadRowForEntity:(id)object {
    NSInteger row = [self.topics indexOfObject:object];
    if (row != NSNotFound) {
        RCITopic *topic = [self.topics objectAtIndex:row];
        UITableViewCell *cell = [self.topicTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:106];
        imageView.image = topic.user.gravatar;
        UIActivityIndicatorView *progressIndicator = (UIActivityIndicatorView *)[cell viewWithTag:105];
        [progressIndicator setHidden:YES];
    }   
}

@end
