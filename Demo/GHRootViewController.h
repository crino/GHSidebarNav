//
//  GHRootViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

@interface GHRootViewController : UIViewController {
@private
	id _revealBlock;
}

- (id)initWithTitle:(NSString *)title withRevealBlock:(void (^)())revealBlock;

@end