import Preferences

protocol SpecifierCell {
    func specifier(for target: PSListController) -> PSSpecifier
}
