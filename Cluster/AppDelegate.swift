//
//  AppDelegate.swift
//  Cluster
//
//  Created by iMacbook on 9/30/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let masterViewControler = MasterViewController()
    let navigationController = UINavigationController(rootViewController: masterViewControler)
    window?.rootViewController = navigationController
    
    return true
  }


}

