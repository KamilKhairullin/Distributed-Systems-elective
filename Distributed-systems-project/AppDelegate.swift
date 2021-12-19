import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else { return false }
        let vc = TyperacerViewController()
        let navController = UINavigationController(rootViewController: vc)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        
        return true
    }
}

