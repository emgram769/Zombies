//
//  AppDelegate.h
//  triangle
//
//  Created by Bram Wasti on 1/25/13.
//  Copyright (c) 2013 MBAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    UIViewController *viewController;
    
}

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet UIViewController *viewController;

@end
