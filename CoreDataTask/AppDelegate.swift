//
//  AppDelegate.swift
//  CoreDataTask
//
//  Created by Kenan Memmedov on 20.09.24.
//

import UIKit
import CoreData
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataModel.shared.saveContext()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataModel.shared.saveContext()
    }
}

