func Cube(_ ecs: inout ECS<Signatures>) -> Entity {
    let entity = ecs.AddEntity()
    ecs.AddComponent(entity: entity, component: Transform(translate: SIMD4<Float>(0, 0, 0, 1)))
    ecs.AddComponent(entity: entity, component: Gravity(gravity: SIMD3<Float>(0, -9.8, 0)))
    ecs.AddComponent(entity: entity, component: Rigidbody(velocity: SIMD3<Float>(0, 0, 0), acceleration: SIMD3<Float>(0, 0, 0)))
    return entity
}

