// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

/// Connection status view
class ConnectionStatusIndicatorView: UIView {
    enum State {
        case disconnected
        case connecting
        case connected
    }

    var state: State = .disconnected {
        didSet {
            self.setNeedsDisplay()
            if self.state == .connecting {
                if self.displayLink == nil {
                    let selector = #selector(setNeedsDisplay as () -> Void)
                    self.displayLink = CADisplayLink(target: self, selector: selector)
                }
                self.displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            } else {
                self.displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
                self.displayLink = nil
            }
        }
    }

    var displayLink: CADisplayLink?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.clearsContextBeforeDrawing = true
        self.backgroundColor = UIColor.clear
    }

    override func draw(_: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let size = self.bounds.size
        let path = CGMutablePath()

        path.__addRoundedRect(
            transform: nil,
            rect: self.bounds,
            cornerWidth: size.width / 2,
            cornerHeight: size.height / 2
        )
        context.addPath(path)

        context.setFillColor(self.fillColor())
        context.fillPath()
    }

    private func timebasedValue() -> CGFloat {
        return CGFloat(abs(sin(Date().timeIntervalSinceReferenceDate * 4)))
    }

    private func fillColor() -> CGColor {
        switch self.state {
        case .disconnected:
            return UIColor.red.cgColor
        case .connecting:
            return UIColor.orange.withAlphaComponent(0.5 + self.timebasedValue() * 0.3).cgColor
        case .connected:
            return UIColor.green.cgColor
        }
    }
}
