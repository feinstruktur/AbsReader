//
//  WebViewController.m
//  AbsReader
//
//  Created by Sven A. Schmidt on 27.12.10.
//  Copyright 2010 abstracture GmbH & Co. KG. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

@synthesize webView;
@synthesize link;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
  NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
  
  NSRange pos = [self.link rangeOfString:@"://"];
  NSUInteger offset = pos.location + pos.length;
  NSString *protocol = [self.link substringToIndex:offset];
  NSString *remainder = [self.link substringFromIndex:offset];
  pos = [remainder rangeOfString:@"/"];
  offset = pos.location + pos.length;
  NSString *host = [remainder substringToIndex:offset-1];
  remainder = [remainder substringFromIndex:offset];

  NSString *base = [NSString stringWithFormat:@"%@%@:%@@%@", protocol, user, pass, host];
  NSURL *baseUrl = [NSURL URLWithString:base];  
  NSURL *fullUrl = [NSURL URLWithString:remainder relativeToURL:baseUrl];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:fullUrl];
  [self.webView loadRequest:request];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
  NSLog(@"started loading");
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
  NSLog(@"finished loading");
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSString * errorString = [NSString stringWithFormat:@"%@ (Error code %i)", [error description], [error code]];
	NSLog(@"Error loading page: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading page" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end