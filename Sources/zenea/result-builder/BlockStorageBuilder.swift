/// Builds a single- or multi-source ``BlockStorage`` from a resultBuilder function.
@resultBuilder
public enum BlockStorageBuilder {
    public static func buildPartialBlock<Component>(first component: Component) -> some BlockStorage where Component: BlockStorage {
        return component
    }
    
    public static func buildPartialBlock<Accumulated, Next>(accumulated: Accumulated?, next: Next) -> some BlockStorage where Accumulated: BlockStorage, Next: BlockStorage {
        BlockStorageTuple(source1: accumulated, source2: next)
    }
    
    public static func buildArray<Component>(_ components: [Component]) -> some BlockStorage where Component: BlockStorage {
        BlockStorageList(sources: components)
    }
    
    public static func buildEither<TrueContent, FalseContent>(first content: TrueContent) -> some BlockStorage where TrueContent: BlockStorage, FalseContent: BlockStorage {
        BlockStorageConditional<TrueContent, FalseContent>.true(content)
    }
    
    public static func buildEither<TrueContent, FalseContent>(second content: FalseContent) -> some BlockStorage where TrueContent: BlockStorage, FalseContent: BlockStorage {
        BlockStorageConditional<TrueContent, FalseContent>.false(content)
    }
    
    public static func buildBlock<C1, C2>(_ c1: C1, _ c2: C2) -> some BlockStorage where C1: BlockStorage, C2: BlockStorage {
        BlockStorageTuple(source1: c1, source2: c2)
    }
}
