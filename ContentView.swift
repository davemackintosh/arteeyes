import MetalKit
import ModelIO
import SwiftUI

struct Signatures: OptionSet {
    let rawValue: Int

    static let Transform = Signatures(rawValue: 1 << 0)
    static let RigidBody = Signatures(rawValue: 1 << 1)
    static let Gravity = Signatures(rawValue: 1 << 2)
    static let Drawable = Signatures(rawValue: 1 << 3)

    static let PhysicsBody: Signatures = [.RigidBody, .Gravity, .Transform]
}

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
                .border(.yellow, width: 5)
        }
    }
}
