class Renderer: NSObject, MTKViewDelegate {
    // MARK: Lifecycle

    init(device _: MTLDevice) {
        ecs = .init()
        cube = Cube(&ecs)
        triangle = Drawable(vertexes: [
            SIMD3<Float>(-0.8, 0.4, 0.0),
            SIMD3<Float>(0.4, -0.8, 0.0),
            SIMD3<Float>(0.8, 0.8, 0.0),
        ])

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

    func makeResources() {}

    // MARK: Internal

    var ecs: ECS<Signatures>
    var cube: Entity

    var triangle: Drawable

    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {
        // Do nothing
    }

    func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}

