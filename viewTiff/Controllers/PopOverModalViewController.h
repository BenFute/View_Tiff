//
//  PopOverModalViewController.h
//  viewTiff
//
//  Created by Ben Larrison on 11/21/22.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface  PopOverPresentationManager : NSObject        <UIViewControllerTransitioningDelegate>
@property   UIViewController        *presentedViewController;
@property   UIViewController        *presentingViewController;

-   (instancetype)initWithPresentingViewController:(UIViewController *)presenting PresentingViewController:(UIViewController *)presented;

-   (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source;

-   (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
-   (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed;

-   (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator;
-   (id<UIViewControllerAnimatedTransitioning>)interactionControllerForDismissal: (id<UIViewControllerAnimatedTransitioning>)animator;
@end

@interface PopOverPresentationController : UIPresentationController
{
    CGFloat         popOverHeightRatio;
}
-   (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController;
-   (CGRect)        frameOfPresentedViewInContainerView;
//-   (void)          containerViewDidLayoutSubviews;

@end

