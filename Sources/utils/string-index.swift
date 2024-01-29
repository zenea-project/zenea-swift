extension String {
    public subscript<Range: RangeExpression<Int>>(range: Range) -> Substring {
        let indexOffsets = self.indices.map { $0.utf16Offset(in: self) }
        let relativeRange = range.relative(to: indexOffsets)
        let indexRange = Index(utf16Offset: relativeRange.lowerBound, in: self) ..< Index(utf16Offset: relativeRange.upperBound, in: self)
        return self[indexRange]
    }
}
