struct RenderSystem<Signature: OptionSet>: System {
    typealias Signature = Signatures
    var entities: ContiguousArray<Entity>
    var signatures: Signatures = [.Drawable]

    var device: MTLDevice
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!

    init() {
        device = device
        commandQueue = device.makeCommandQueue()!
    }

    func Update(dt _: Float, ecs: inout ECS<some OptionSet>) {
        for entity in entities {
            let drawable = ecs.GetComponent(entity: entity, component: Drawable.self)

            let vertexBuffer = device.makeBuffer(bytes: &drawable!.vertexes,
                                                 length: MemoryLayout<SIMD3<Float>>.stride * drawable!.vertexes.count,
                                                 options: .storageModeShared)

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
        }
    }
}

