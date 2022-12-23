//
//  AppDelegate.h
//  MyWeather
//
//  Created by Stefano Ruggiero on 11/11/22.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

