import SwiftUI

/// Catalog of custom 24x24 icons ported from the React Native prototype's
/// `Icon.tsx`. Each case maps to a template-rendered Image Set in
/// `Assets.xcassets`. Cases with kebab-case asset names supply explicit raw
/// values so the Swift identifier stays camelCase.
enum IconName: String, CaseIterable {
    case alertTriangle = "alert-triangle"
    case check
    case chevronLeft = "chevron-left"
    case chevronRight = "chevron-right"
    case clock
    case cloudOff = "cloud-off"
    case droplet
    case hammer
    case lightning
    case mapPin = "map-pin"
    case phone
    case play
    case plus
    case refreshCw = "refresh-cw"
    case snowflake
    case wrench

    var assetName: String { rawValue }
}

/// Renders a custom icon from the asset catalog using template rendering so
/// callers can tint with `.foregroundStyle(_:)`. Hidden from accessibility by
/// default — supply an explicit accessibility label on the parent control.
struct IconView: View {
    let name: IconName
    var size: CGFloat = 24

    var body: some View {
        Image(name.assetName)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
