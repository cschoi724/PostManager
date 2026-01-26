//
//  NetworkMonitorImpl.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation
import Network

final class NetworkMonitorImpl: NetworkMonitor {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var _isOnline: Bool = false
    
    var isOnline: Bool {
        return _isOnline
    }
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let wasOnline = self._isOnline
            self._isOnline = path.status == .satisfied
            
            // 온라인 전환 시 알림
            if !wasOnline && self._isOnline {
                NotificationCenter.default.post(
                    name: .networkDidBecomeOnline,
                    object: nil
                )
            }
        }
        monitor.start(queue: queue)
        
        // 초기 상태 설정
        _isOnline = monitor.currentPath.status == .satisfied
    }
    
    deinit {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let networkDidBecomeOnline = Notification.Name("networkDidBecomeOnline")
}
