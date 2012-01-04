//
//  GHSidebarViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRevealViewController.h"
#import "GHMenuCell.h"
#import "GHSidebarSearchViewController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark -
#pragma mark Constants
const CGFloat kSidebarAnimationDuration = 0.3f;
const CGFloat kSidebarWidth = 260.0f;


#pragma mark -
#pragma mark Private Interface
@interface GHRevealViewController ()
@property (nonatomic, readwrite, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readwrite, getter = isSearching) BOOL searching;
@property (nonatomic, strong) UIView *searchView;
- (void)hideSidebar;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHRevealViewController

#pragma mark Properties
@synthesize sidebarShowing;
@synthesize searching;
@synthesize sidebarViewController;
@synthesize contentViewController;
@synthesize searchView;

- (void)setSidebarViewController:(UIViewController *)svc {
	svc.view.frame = _sidebarView.bounds;
	if (sidebarViewController == nil) {
		sidebarViewController = svc;
		[self addChildViewController:sidebarViewController];
		[_sidebarView addSubview:sidebarViewController.view];
		[sidebarViewController didMoveToParentViewController:self];
	} else if (sidebarViewController != svc) {
		[sidebarViewController willMoveToParentViewController:nil];
		[self addChildViewController:svc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:sidebarViewController 
						  toViewController:svc 
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{} 
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[sidebarViewController removeFromParentViewController];
									sidebarViewController = svc;
								}
		 ];
		[sidebarViewController didMoveToParentViewController:self];
	}
}

- (void)setContentViewController:(UIViewController *)cvc {
	cvc.view.frame = _contentView.bounds;
	if (contentViewController == nil) {
		contentViewController = cvc;
		[self addChildViewController:contentViewController];
		[_contentView addSubview:contentViewController.view];
		[contentViewController didMoveToParentViewController:self];
	} else if (contentViewController != cvc) {
		[contentViewController willMoveToParentViewController:nil];
		[self addChildViewController:cvc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:contentViewController 
						  toViewController:cvc 
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[contentViewController removeFromParentViewController];
									contentViewController = cvc;
								}
		];
		[contentViewController didMoveToParentViewController:self];
	}
}

#pragma mark Memory Management
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.sidebarShowing = NO;
		self.searching = NO;
		_tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSidebar)];
		_tapRecog.cancelsTouchesInView = YES;
		
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		_sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSidebarWidth, CGRectGetHeight(self.view.bounds))];
		_sidebarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
		_sidebarView.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_sidebarView];
		
		_contentView = [[UIView alloc] initWithFrame:self.view.bounds];
		_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_contentView.layer.masksToBounds = NO;
		_contentView.layer.shadowColor = [UIColor blackColor].CGColor;
		_contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		_contentView.layer.shadowOpacity = 1.0f;
		_contentView.layer.shadowRadius = 2.5f;
		_contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_contentView.bounds].CGPath;
		[self.view addSubview:_contentView];
    }
    return self;
}

#pragma mark UIViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	BOOL doAutorotate = NO;
	switch (orientation) {
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationPortrait:
			doAutorotate = YES;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			doAutorotate = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
			break;
	}
	if (doAutorotate && self.isSearching && self.interfaceOrientation != orientation) {
		_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
		_sidebarView.frame = self.view.bounds;
	}
	return doAutorotate;
}

#pragma mark Public Methods
- (void)toggleSidebar:(BOOL)show animated:(BOOL)animated {
	[self toggleSidebar:show animated:animated completion:^(BOOL finshed){}];
}

- (void)toggleSidebar:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finsihed))completion {
	void (^animations)(void) = ^{
		if (show) {
			_contentView.frame = CGRectOffset(_contentView.bounds, kSidebarWidth, 0.0f);
			[_contentView addGestureRecognizer:_tapRecog];
		} else {
			if (self.isSearching) {
				_sidebarView.frame = CGRectMake(0.0f, 0.0f, kSidebarWidth, CGRectGetHeight(self.view.bounds));
			} else {
				[_contentView removeGestureRecognizer:_tapRecog];
			}
			_contentView.frame = _contentView.bounds;
		}
		self.sidebarShowing = show;
	};
	if (animated) {
		[UIView animateWithDuration:kSidebarAnimationDuration
						 animations:animations
						 completion:completion];
	} else {
		animations();
		completion(YES);
	}
}

- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)srchView animated:(BOOL)animated {
	[self toggleSearch:showSearch withSearchView:srchView animated:animated completion:^(BOOL finished){}];
}

- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)srchView animated:(BOOL)animated completion:(void (^)(BOOL finsihed))completion {
	if (showSearch) {
		srchView.frame = self.view.bounds;
	} else {
		_contentView.frame = CGRectOffset(self.view.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
		[self.view addSubview:_contentView];
	}
	void (^animations)(void) = ^{
		if (showSearch) {
			_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
			[_contentView removeGestureRecognizer:_tapRecog];
			[_sidebarView removeFromSuperview];
			self.searchView = srchView;
			[self.view insertSubview:self.searchView atIndex:0];
		} else {
			_sidebarView.frame = CGRectMake(0.0f, 0.0f, kSidebarWidth, CGRectGetHeight(self.view.bounds));
			[self.view insertSubview:_sidebarView atIndex:0];
			self.searchView.frame = _sidebarView.frame;
			_contentView.frame = CGRectOffset(_contentView.bounds, kSidebarWidth, 0.0f);
		}
	};
	void (^fullCompletion)(BOOL) = ^(BOOL finished){
		if (showSearch) {
			[_contentView removeFromSuperview];
		} else {
			[_contentView addGestureRecognizer:_tapRecog];
			[self.searchView removeFromSuperview];
			self.searchView = nil;
		}
		self.sidebarShowing = YES;
		self.searching = showSearch;
		completion(finished);
	};
	if (animated) {
		[UIView animateWithDuration:kSidebarAnimationDuration
						 animations:animations
						 completion:fullCompletion];
	} else {
		animations();
		fullCompletion(YES);
	}
}

#pragma mark Private Methods
- (void)hideSidebar {
	[self toggleSidebar:NO animated:YES];
}

@end