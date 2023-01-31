struct PhysicsSystem<Signature: OptionSet>: System {
    typealias Signature = Signatures
    var signatures: Signatures = .PhysicsBody
    var entities: ContiguousArray<Entity> = []

    func Update(dt _: Float, ecs _: inout ECS<some OptionSet>) {
        for entity in entities {}
    }
}

