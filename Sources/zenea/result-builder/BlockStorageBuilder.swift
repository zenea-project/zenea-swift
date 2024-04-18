@resultBuilder
public enum BlockStorageBuilder {
    public static func buildPartialBlock<Component>(first component: Component) -> some BlockStorage where Component: BlockStorage {
        return component
    }
    
    public static func buildPartialBlock<Accumulated, Next>(accumulated: Accumulated, next: Next) -> some BlockStorage where Accumulated: BlockStorage, Next: BlockStorage {
        BlockStorageTuple(source1: accumulated, source2: next)
    }
    
    public static func buildArray<Component>(_ components: [Component]) -> some BlockStorage where Component: BlockStorage {
        BlockStorageList(sources: components)
    }
    
    public static func buildEither<Component>(first component: Component) -> some BlockStorage where Component: BlockStorage {
        component
    }
    
    public static func buildEither<Component>(second component: Component) -> some BlockStorage where Component: BlockStorage {
        component
    }
}
