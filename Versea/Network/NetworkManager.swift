//
//  NetworkManager.swift
//  Versea
//
//  Created by Hazel Gong on 2024/11/10.
//

import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()
    private var monitor: NWPathMonitor?
    
    private init() {}
    
    func setupNetworkMonitoring() {
        if #available(iOS 10.0, *) {
            checkNetworkStatus()
        } else {
            setupReachabilityMonitoring()
        }
    }

    private func handleNetworkStatusChange() {
        NotificationManager.shared.postNetworkChangeNotification()
    }
    
    private func checkNetworkStatus() {
        monitor = NWPathMonitor()
        
        monitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                switch path.status {
                case .unsatisfied:
                    self?.handleNetworkRestricted()
                case .satisfied:
                    self?.handleNetworkNotRestricted()
                case .requiresConnection:
                    break
                @unknown default:
                    break
                }
                
                if path.usesInterfaceType(.wifi) || path.usesInterfaceType(.cellular) {
                    self?.getInitialInfo()
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
    }
    
    private func setupReachabilityMonitoring() {
        // 处理旧版本的网络监控
    }
    
    private func handleNetworkRestricted() {
        NotificationCenter.default.post(
            name: NSNotification.Name("NetworkRestricted"),
            object: nil
        )
    }
    
    private func handleNetworkNotRestricted() {
        NotificationCenter.default.post(
            name: NSNotification.Name("NetworkNotRestricted"),
            object: nil
        )
    }
    
    private func getInitialInfo() {
        checkForUpdates()
        NotificationCenter.default.post(
            name: NSNotification.Name("NetworkingReachabilityDidChange"),
            object: nil
        )
    }
    
    private func checkForUpdates() {
        // 实现应用更新检查逻辑
    }
    
    func stopMonitoring() {
        monitor?.cancel()
    }
}
