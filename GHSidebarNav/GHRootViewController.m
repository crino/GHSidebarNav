//
//  GHRootViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRootViewController.h"
#import "GHPushedViewController.h"


#pragma mark Private Interface
@interface GHRootViewController ()
- (void)pushViewController;
- (void)revealSidebar;
@end


#pragma mark Implementation
@implementation GHRootViewController

#pragma mark -
#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(void (^)())revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = title;
		_revealBlock = [revealBlock copy];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																							  target:self 
																							  action:@selector(revealSidebar)];
	}
	return self;
}

#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor lightGrayColor];
	UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[pushButton setTitle:@"Push" forState:UIControlStateNormal];
	[pushButton addTarget:self action:@selector(pushViewController) forControlEvents:UIControlEventTouchUpInside];
	[pushButton sizeToFit];
	[view addSubview:pushButton];
	[self.view addSubview:view];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Private Methods
- (void)pushViewController {
	[self.navigationController pushViewController:[[GHPushedViewController alloc] initWithTitle:[self.title stringByAppendingString:@" - Pushed"]] 
										 animated:YES];
}

- (void)revealSidebar {
	((void (^)()) _revealBlock)();
}

@end