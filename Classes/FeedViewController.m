//
//  RootViewController.m
//  AbsReader
//
//  Created by Sven A. Schmidt on 27.12.10.
//  Copyright 2010 abstracture GmbH & Co. KG. All rights reserved.
//

#import "FeedViewController.h"
#import "SettingsViewController.h"
#import "WebViewController.h"


@implementation FeedViewController

@synthesize activityIndicator;
@synthesize feed;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
  [super viewDidLoad];
  
  /*
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)] autorelease];
   */
  self.navigationItem.leftBarButtonItem.isAccessibilityElement = YES;
  self.navigationItem.leftBarButtonItem.accessibilityLabel = @"refresh";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonPressed)];
  
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  CGFloat x = newsTable.bounds.size.width/2;
  CGFloat y = newsTable.bounds.size.height/2;
  CGPoint pos = CGPointMake(x, y);
  activityIndicator.center = pos;

  newsTable.rowHeight = 90;
  
  {
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTouchDoubleTap:)];
    gr.delaysTouchesBegan = YES;
    gr.numberOfTapsRequired = 2;
    gr.numberOfTouchesRequired = 1;
    gr.delaysTouchesBegan = YES;
    [newsTable addGestureRecognizer:gr];
  }
  {
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTouchDoubleTap:)];
    gr.delaysTouchesBegan = YES;
    gr.numberOfTapsRequired = 2;
    gr.numberOfTouchesRequired = 2;
    gr.delaysTouchesBegan = YES;
    [newsTable addGestureRecognizer:gr];
  }
  {
    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    gr.delaysTouchesBegan = YES;
    gr.direction = UISwipeGestureRecognizerDirectionRight;
    [newsTable addGestureRecognizer:gr];
  }
  {
    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    gr.delaysTouchesBegan = YES;
    gr.direction = UISwipeGestureRecognizerDirectionLeft;
    [newsTable addGestureRecognizer:gr];
  }
  
  NSMutableArray *buttons = [NSMutableArray array];
  [buttons addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check.png"] style:UIBarButtonItemStylePlain target:self action:@selector(markAllRead)]];
  self.toolbarItems = buttons;

  [[NSNotificationCenter defaultCenter] addObserverForName:kFeedInfoUpdated object:nil queue:nil usingBlock:^(NSNotification *notification) {
    self.title = self.feed.title;
  }];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
  [self.navigationController setToolbarHidden:NO animated:animated];
  [self.tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.feed.stories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *CellIdentifier = @"Cell";
    
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
		cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
  }
    
  [self configureCell:cell forIndexPath:indexPath];
  return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Workers


- (void)settingsButtonPressed {
  [self showSettings];
}


- (void)showSettings {
  SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
  vc.feed = self.feed;
  vc.isNew = NO;
  [self.navigationController pushViewController:vc animated:YES];
}


- (void)markCellAsUnread:(NSIndexPath *)indexPath {
  NSString *guid = [[self.feed.stories objectAtIndex:[indexPath row]] objectForKey:@"guid"];
  [self.feed markGuidUnread:guid];
  NSArray *indexes = [NSArray arrayWithObject:indexPath];
	[newsTable reloadRowsAtIndexPaths:indexes withRowAnimation:NO];
}


- (void)markCellAsRead:(NSIndexPath *)indexPath {
  NSString *guid = [[self.feed.stories objectAtIndex:[indexPath row]] objectForKey:@"guid"];
  NSDate *date = [[self.feed.stories objectAtIndex:[indexPath row]] objectForKey:@"pubDate"];
  [self.feed markGuidRead:guid forDate:date];
  NSArray *indexes = [NSArray arrayWithObject:indexPath];
	[newsTable reloadRowsAtIndexPaths:indexes withRowAnimation:NO];
}


- (void)markAllRead {
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Mark all read" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Mark Read" otherButtonTitles:nil];
  [sheet showFromBarButtonItem:[self.toolbarItems objectAtIndex:0] animated:YES];
}


#pragma mark -
#pragma mark Gesture Handlers


- (void)handleSingleTouchDoubleTap:(UIGestureRecognizer *)sender {
  CGPoint p = [sender locationInView:newsTable];
  NSIndexPath *indexPath = [newsTable indexPathForRowAtPoint:p];
  [self markCellAsRead:indexPath];
}


- (void)handleDoubleTouchDoubleTap:(UIGestureRecognizer *)sender {
  CGPoint p = [sender locationInView:newsTable];
  NSIndexPath *indexPath = [newsTable indexPathForRowAtPoint:p];
  [self markCellAsUnread:indexPath];
}


- (void)handleRightSwipe:(UIGestureRecognizer *)sender {
	CGPoint p = [sender locationInView:newsTable];
  NSIndexPath *indexPath = [newsTable indexPathForRowAtPoint:p];
  [self markCellAsRead:indexPath];
}


- (void)handleLeftSwipe:(UIGestureRecognizer *)sender {
	CGPoint p = [sender locationInView:newsTable];
  NSIndexPath *indexPath = [newsTable indexPathForRowAtPoint:p];
  [self markCellAsUnread:indexPath];
}


#pragma mark -
#pragma mark ArticleCacheDelegate


- (void)errorOccurred:(NSError *)error {
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];	
  newsTable.scrollEnabled = YES;

  if ([error code] == -1012) {
    // "user canceled authentication" (or rather we did, because there was no password given)
    // ignore this to prevent an additional alert sheet from popping up
    return;
  }
  
	NSString * errorString = [NSString stringWithFormat:@"Error fetching feed (Error code %i )", [error code]];
	NSLog(@"%@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error fetching feed" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}


- (void)didEndDocument {
	[newsTable reloadData];
	[self.activityIndicator stopAnimating];
	[self.activityIndicator removeFromSuperview];
  newsTable.scrollEnabled = YES;
}


#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSString * errorString = [NSString stringWithFormat:@"%@ (Error code %i)", [error description], [error code]];
	NSLog(@"Error loading feed: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading feed" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *link = [[self.feed.stories objectAtIndex:[indexPath row]] objectForKey: @"link"];
  
  WebViewController *vc = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
  vc.link = link;
  [self.navigationController pushViewController:vc animated:YES];

  [self markCellAsRead:indexPath];

  return;
}


#pragma mark -
#pragma mark Configuring table view cells


const CGFloat kRowWidth = 320;
const CGFloat kTopOffset = 10;

const CGFloat kRightOffset = 24;
const CGFloat kLeftOffset = 20;

const CGFloat kTopHeight = 15;
const CGFloat kMiddleHeight = 40;
const CGFloat kBottomHeight = 15;


- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier {
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  
  // author
  {
    CGFloat x = kLeftOffset +2;
    CGFloat y = kTopOffset;
    CGFloat width = 80;
    CGFloat height = kTopHeight;
    CGRect rect = CGRectMake(x, y, width, height);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.tag = 1;
    label.font = [UIFont systemFontOfSize:12];
    label.adjustsFontSizeToFitWidth = NO;
    label.textColor = [UIColor grayColor];
    label.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
  }
  
  // date
  {
    CGFloat x = 100;
    CGFloat y = kTopOffset;
    CGFloat width = kRowWidth - x - kRightOffset;
    CGFloat height = kTopHeight;
    CGRect rect = CGRectMake(x, y, width, height);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.tag = 2;
    label.font = [UIFont systemFontOfSize:12];
    label.adjustsFontSizeToFitWidth = NO;
    label.textColor = [UIColor grayColor];
    label.highlightedTextColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentRight;
    [cell.contentView addSubview:label];
  }
  
  // desc
  {
    CGFloat x = kLeftOffset;
    CGFloat y = kTopOffset + kTopHeight;
    CGFloat width = kRowWidth - x - kRightOffset;
    CGFloat height = kMiddleHeight;
    CGRect rect = CGRectMake(x, y, width, height);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.tag = 3;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.adjustsFontSizeToFitWidth = NO;
    label.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
  }
  
  // summary
  {
    CGFloat x = kLeftOffset +2;
    CGFloat y = kTopOffset + kTopHeight + kMiddleHeight;
    CGFloat width = kRowWidth - x - kRightOffset;
    CGFloat height = kBottomHeight;
    CGRect rect = CGRectMake(x, y, width, height);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.tag = 4;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.adjustsFontSizeToFitWidth = NO;
    label.textColor = [UIColor grayColor];
    label.highlightedTextColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
  }
  
  // bullet
  {
    CGFloat x = 3;
    CGFloat y = 38;
    CGFloat width = 15;
    CGFloat height = 15;
    CGRect rect = CGRectMake(x, y, width, height);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.tag = 5;
    label.font = [UIFont boldSystemFontOfSize:36];
    label.textColor = [UIColor grayColor];
    label.text = @"•";
    [cell.contentView addSubview:label];
  }
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
	return cell;
}


- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
  
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"LLL-dd HH:mm"];
	}
	
  NSDictionary *info = [self.feed.stories objectAtIndex:[indexPath row]];
  NSString *guid = [info objectForKey:@"guid"];

	// author
  {
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [info objectForKey:@"dc:creator"];
  }
	
	// date
	{
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    label.text = [dateFormatter stringFromDate:[info objectForKey:@"pubDate"]];
  }
  
	// title
  {
    UILabel *label = (UILabel *)[cell viewWithTag:3];
    label.text = [info objectForKey:@"title"];
    if ([self.feed alreadyVisited:guid]) {
      label.textColor = [UIColor grayColor];
    } else {
      label.textColor = [UIColor blackColor];
    }
  }
  
	// summary
  {
    UILabel *label = (UILabel *)[cell viewWithTag:4];
    label.text = [info objectForKey:@"description"];
  }
  
  // bullet
  {
    UILabel *label = (UILabel *)[cell viewWithTag:5];
    label.hidden = [self.feed alreadyVisited:guid];
  }
}    


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self.feed markAllRead];
    [newsTable reloadData];    
    [self.navigationController popViewControllerAnimated:YES];
  }
}


@end


