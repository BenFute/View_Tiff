//
//  PopOverModalViewController.m
//  viewTiff
//
//  Created by Ben Larrison on 11/21/22.
//

#import "PopOverModalViewController.h"

@implementation PopOverPresentationManager

-   (instancetype)initWithPresentingViewController:(UIViewController *)presenting PresentingViewController:(UIViewController *)presented
{
    self                        =           [super init];
    
    _presentedViewController    =           presented;
    _presentingViewController   =           presenting;
    
    return      self;
}

-   (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    PopOverPresentationController       *popOverPresentationController      =       [[PopOverPresentationController     alloc]initWithPresentedViewController:presented presentingViewController:presenting];
    
    return      popOverPresentationController;
}

-   (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return 0;
}

-   (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return 0;
}

-   (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return 0;
}

-   (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return 0;
}


@end


@implementation PopOverPresentationController

-   (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    popOverHeightRatio          =       0.3;
    self                        =       [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    
    return          self;
}

-   (CGRect)        frameOfPresentedViewInContainerView
{
    
    CGFloat         viewHeight  =       self.containerView.bounds.size.height * popOverHeightRatio;
    CGPoint         origin      =       CGPointMake(0,self.containerView.bounds.size.height - viewHeight);
    
    CGSize          size        =       CGSizeMake(self.containerView.bounds.size.width, viewHeight);
    
    return          CGRectMake(origin.x, origin.y, size.width, size.height);
}

@end


