import Preferences

struct SpecifierFactory {
    static func add(
        _ cells: [SpecifierCell],
        to specifiers: inout NSMutableArray,
        in target: PSListController
    ) {
        _ = cells.map {
            specifiers.add($0.specifier(for: target))
        }
    }
}
