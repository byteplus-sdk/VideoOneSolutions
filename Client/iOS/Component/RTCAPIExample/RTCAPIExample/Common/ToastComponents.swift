//
//  ToastComponents.swift
//  ApiExample
//
//  Created by bytedance on 2023/11/3.
//  Copyright © 2021 bytedance. All rights reserved.
//

import UIKit
import SnapKit

class ToastComponents {

    weak var aboveToastView: ToastView?

    static let shared = ToastComponents()

    private init() { }

    func show(withMessage message: String, inView windowView: UIView, block: @escaping ((Bool) -> Void)) {
        guard message.count > 0 else { return }
        DispatchQueue.main.async { [weak self] in
            // 取消前一次的弹窗，避免多个 toast 同时堆叠
            self?.aboveToastView?.removeFromSuperview()
            self?.aboveToastView = nil
            
            let toastView = ToastView(message: message)
            windowView.addSubview(toastView)
            toastView.snp.makeConstraints { make in
                make.centerX.equalTo(windowView)
                make.top.equalToSuperview().offset(128)
            }
            
            self?.aboveToastView = toastView

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak toastView] in
                toastView?.removeFromSuperview()
            }
            block(true)
        }
    }

    func show(withMessage message: String, inView windowView: UIView) {
        show(withMessage: message, inView: windowView, block: { _ in })
    }
    
    func show(withMessage message: String) {
        DispatchQueue.main.async { [weak self] in
            // 兼容 iOS 13+ 的多 Scene 获取 Window 方式
            var window: UIWindow?
            if #available(iOS 13.0, *) {
                window = UIApplication.shared.connectedScenes
                    .filter({ $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive })
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows
                    .filter({ $0.isKeyWindow }).first
            }
            
            // 兜底方案
            if window == nil {
                window = UIApplication.shared.keyWindow
            }
            
            // 安全解包，避免应用在没有 Window 的状态下崩溃
            if let targetWindow = window {
                self?.show(withMessage: message, inView: targetWindow)
            } else {
                print("Toast warning: No valid window found to display message: \(message)")
            }
        }
    }

    func show(withMessage message: String, delay: TimeInterval) {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.show(withMessage: message)
            }
        } else {
            show(withMessage: message)
        }
    }
}
