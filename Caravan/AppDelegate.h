//
//  AppDelegate.h
//  Caravan
//
//  Created by Ravi Chaudhary on 17/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PKRevealController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PKRevealing>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PKRevealController * revealController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)configureViewOfController : (UIViewController *)viewController;
-(void)revealToggle;

@end
