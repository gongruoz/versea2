import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 设置网络监控
        NetworkManager.shared.setupNetworkMonitoring()
        
        // 设置通知
        setupNotifications()
        
        return true
    }
    
    private func setupNotifications() {
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            if let error = error {
//                print("Notification authorization error: \(error)")
            }
        }
        
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = self
        
        // 添加网络状态变化的观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkChange),
            name: Notification.Name("NetworkingReachabilityDidChange"),
            object: nil
        )
    }
    
    @objc private func handleNetworkChange() {
        // 处理网络状态变化
//        print("Network status changed")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
