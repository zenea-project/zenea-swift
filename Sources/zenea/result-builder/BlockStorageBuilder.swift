/// Builds a single- or multi-source ``BlockStorage`` from a resultBuilder function.
@resultBuilder
public enum BlockStorageBuilder {
    public static func buildArray<Component>(_ components: [Component]) -> BlockStorageList<Component> where Component: BlockStorage {
        BlockStorageList(sources: components)
    }
    
    public static func buildEither<TrueContent, FalseContent>(first content: TrueContent) -> BlockStorageConditional<TrueContent, FalseContent> where TrueContent: BlockStorage, FalseContent: BlockStorage {
        .true(content)
    }
    
    public static func buildEither<TrueContent, FalseContent>(second content: FalseContent) -> BlockStorageConditional<TrueContent, FalseContent> where TrueContent: BlockStorage, FalseContent: BlockStorage {
        .false(content)
    }
    
    public static func buildBlock<Component>(_ component: Component) -> Component where Component: BlockStorage {
        component
    }
    
    public static func buildBlock<C1, C2>(_ c1: C1, _ c2: C2) -> BlockStorageTuple<C1, C2> where C1: BlockStorage, C2: BlockStorage {
        BlockStorageTuple(source1: c1, source2: c2)
    }
}
