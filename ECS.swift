import ModelIO
import simd

public typealias Entity = Int
public protocol System {
    associatedtype Signature

    var signatures: Signature { get }
    var entities: ContiguousArray<Entity> { get set }
	func Update<T>(dt: Float, ecs: inout ECS<T>)
}

public protocol Component {}

public struct ECS<Signatures: OptionSet> {
    // MARK: Public

    public mutating func AddEntity() -> Entity {
        let entity = entities.count
        entities.append(entity)
        return entity
    }

    public mutating func AddComponent(entity: Entity, component: any Component) {
        let currentComponents = components[entity]

        if currentComponents == nil {
            components[entity] = [component]
        } else {
            components[entity]!.append(component)
        }
    }

	public func GetComponent<T>(entity: Entity, component: T) -> T? {
        let currentComponents = components[entity]

        if currentComponents == nil {
            return nil
        }

        for component in currentComponents! {
			if let component = component as? T {
				return component.self
            }
        }

        return nil
    }

    public mutating func AddSystem(system: any System) {
        systems.append(system)
    }

    public mutating func Update() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let dt = Float(currentTime - lastTime)

        for var system in systems {
            // Get the entities that match the system's signature.
            system.entities = GetEntities(system.signatures as! Signatures)
            system.Update(dt: dt, ecs: &self)
        }
    }

    public func GetEntities(_: Signatures) -> ContiguousArray<Entity> {
        var entities = ContiguousArray<Entity>()

        for entity in entities {
            if components[entity] != nil {
                entities.append(entity)
            }
        }

        return entities
    }

    // MARK: Internal

    var entities: ContiguousArray<Entity> = .init(unsafeUninitializedCapacity: 1000) { buffer, count in
        for i in 0 ..< 1000 {
            buffer[i] = i
        }
        count = 1000
    }

    var lastTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var components: [Entity: [any Component]] = [:]
    var systems: ContiguousArray<any System> = []
}
