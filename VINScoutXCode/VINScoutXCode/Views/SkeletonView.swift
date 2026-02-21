import SwiftUI

// MARK: - Shimmer Modifier

/// Overlays a moving highlight gradient on any view to create a shimmer effect.
/// Apply with `.shimmering()` on any skeleton placeholder shape.
///
/// The animation drives gradient *stop locations* rather than UnitPoint
/// coordinates, so all values stay within [0, 1] and CoreGraphics never
/// receives an out-of-range numeric value.
struct Shimmer: ViewModifier {
    /// 0 = highlight fully off the left edge; 1 = highlight fully off the right edge.
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    // The highlight band is 30 % of the view width.
                    // We map `phase` [0, 1] → stops that sweep left-to-right.
                    let bandWidth: CGFloat = 0.3
                    let leading  = phase - bandWidth / 2          // centre - half-band
                    let trailing = phase + bandWidth / 2          // centre + half-band
                    // Clamp stop locations to [0, 1] so CoreGraphics is always happy.
                    let lo = max(0, min(1, leading))
                    let hi = max(0, min(1, trailing))
                    let mid = max(0, min(1, phase))

                    LinearGradient(
                        stops: [
                            .init(color: .clear,               location: lo),
                            .init(color: .white.opacity(0.55), location: mid),
                            .init(color: .clear,               location: hi),
                        ],
                        startPoint: .leading,
                        endPoint:   .trailing
                    )
                    .blendMode(.overlay)
                    // Suppress the unused-variable warning; geo is only here
                    // to make the overlay fill the parent naturally.
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            )
            .onAppear {
                // Start just past the left edge and finish just past the right edge.
                phase = 0
                withAnimation(
                    .linear(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Adds a left-to-right shimmer highlight animation — use on skeleton placeholders.
    func shimmering() -> some View {
        modifier(Shimmer())
    }
}

// MARK: - Skeleton Shapes

/// A single rounded rectangle placeholder with a shimmer animation.
struct SkeletonBlock: View {
    var height: CGFloat = 72
    var cornerRadius: CGFloat = 12

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.secondarySystemGroupedBackground))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .shimmering()
    }
}

// MARK: - Skeleton Result Card

/// Mimics the shape of VehicleDetailView while the API call is in-flight.
/// Shown on HomeView below the search card whenever `isLoading == true`.
struct SkeletonResultCard: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── Hero placeholder ──────────────────────────────
            SkeletonBlock(height: 140, cornerRadius: 16)

            // ── Body & Drive section ──────────────────────────
            sectionPlaceholder(rows: 2)

            // ── Engine section ────────────────────────────────
            sectionPlaceholder(rows: 4)
        }
        .padding(16)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .transition(
            .opacity.combined(with: .scale(scale: 0.97, anchor: .top))
        )
    }

    /// One labelled section + a 2-column grid of placeholder spec cards.
    private func sectionPlaceholder(rows: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section label placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray4))
                .frame(width: 130, height: 14)
                .shimmering()

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0 ..< rows * 2, id: \.self) { _ in
                    SkeletonBlock(height: 68)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
