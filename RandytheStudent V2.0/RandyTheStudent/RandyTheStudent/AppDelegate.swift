//
//  AppDelegate.swift
//  RandyTheStudent
//
//  Swift port of the original AppDelegate.m + main.m (Objective-C).
//  `@main` replaces main.m's `UIApplicationMain(...)` call entirely —
//  standard for a UIKit app with no Scene Delegate / no
//  UIApplicationSceneManifest in Info.plist (this project has neither),
//  so main.m has been removed from the project.
//
//  This is the last file in the Objective-C -> Swift migration: with
//  this converted, the whole app target is pure Swift, and the bridging
//  header / prefix header are no longer needed.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewController1: RandyMenu
        if UIDevice.current.userInterfaceIdiom == .phone {
            viewController1 = RandyMenu(nibName: "RandyMenu_Iphone", bundle: nil)
        } else {
            viewController1 = RandyMenu(nibName: "RandyMenu", bundle: nil)
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController1
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
