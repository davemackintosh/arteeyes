import MetalKit
import ModelIO
import SwiftUI

struct Signatures: OptionSet {
    let rawValue: Int

    static let Transform = Signatures(rawValue: 1 << 0)
    static let RigidBody = Signatures(rawValue: 1 << 1)
    static let Gravity = Signatures(rawValue: 1 << 2)

    static let PhysicsBody: Signatures = [.RigidBody, .Gravity, .Transform]
}

struct Transform: Component {
    var translate: SIMD4<Float>
}

struct Rigidbody: Component {
    var velocity: SIMD3<Float>
    var acceleration: SIMD3<Float>
}

struct Gravity: Component {
    var gravity: SIMD3<Float>
}

struct PhysicsSystem<Signature: OptionSet>: System {
    typealias Signature = Signatures
    var signatures: Signatures = .PhysicsBody
    var entities: ContiguousArray<Entity> = []

    func Update(dt: Float) {
        print(dt)
    }
}

func Cube(_ ecs: inout ECS<Signatures>) -> Entity {
    let entity = ecs.AddEntity()
    ecs.AddComponent(entity: entity, component: Transform(translate: SIMD4<Float>(0, 0, 0, 1)))
    ecs.AddComponent(entity: entity, component: Gravity(gravity: SIMD3<Float>(0, -9.8, 0)))
    ecs.AddComponent(entity: entity, component: Rigidbody(velocity: SIMD3<Float>(0, 0, 0), acceleration: SIMD3<Float>(0, 0, 0)))
    return entity
}

class Renderer: NSObject, MTKViewDelegate {
    // MARK: Lifecycle

    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!

        ecs = .init()
        cube = Cube(&ecs)

        super.init()

        makePipeline()
        makeResources()
    }

    private func makePipeline() {
        let library = try! device.makeLibrary(source: basicShaderCode, options: nil)
        let vertexFunction = library.makeFunction(name: "vertex_main")!
        let fragmentFunction = library.makeFunction(name: "fragment_main")!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            fatalError("Error while creating render pipeline state: \(error)")
        }

        try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }

    func makeResources() {
        var positions = [
            SIMD2<Float>(-0.8, 0.4),
            SIMD2<Float>(0.4, -0.8),
            SIMD2<Float>(0.8, 0.8),
        ]
        vertexBuffer = device.makeBuffer(bytes: &positions,
                                         length: MemoryLayout<SIMD2<Float>>.stride * positions.count,
                                         options: .storageModeShared)
    }

    // MARK: Internal

    var ecs: ECS<Signatures>
    var cube: Entity
    var device: MTLDevice
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!

    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {
        // Do nothing
    }

    func draw(in view: MTKView) {
		ecs.Update()
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        ecs.Update()
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer,
                                             offset: 0,
                                             index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle,
                                            vertexStart: 0,
                                            vertexCount: 3)
        renderCommandEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

struct MetalView: UIViewRepresentable {
    // MARK: Lifecycle

    init() {
        let device = MTLCreateSystemDefaultDevice()!
        renderer = .init(device: device)

        view = MTKView()
        view.preferredFramesPerSecond = 60
        view.clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.device = device
        view.contentMode = .scaleAspectFit
        view.contentScaleFactor = UIScreen.main.scale
        view.delegate = renderer
    }

    // MARK: Internal

    let renderer: Renderer!

    private(set) var view: MTKView!

    func makeUIView(context _: Context) -> MTKView {
        view
    }

    func updateUIView(_: MTKView, context _: Context) {}
}

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
                .border(.yellow, width: 5)
        }
    }
}
