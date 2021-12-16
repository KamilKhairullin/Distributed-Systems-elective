import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        let vc = TyperacerViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.prefersLargeTitles = true        
        window?.rootViewController = navController
    }
}
