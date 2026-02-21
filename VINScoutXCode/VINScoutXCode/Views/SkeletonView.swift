import SwiftUI

// MARK: - Shimmer Modifier

/// Overlays a moving highlight gradient on any view to create a shimmer effect.
/// Apply with `.shimmering()` on any skeleton placeholder shape.
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1.5

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: .clear,                location: 0.0),
                        .init(color: .white.opacity(0.55),  location: 0.5),
                        .init(color: .clear,                location: 1.0),
                    ],
                    startPoint: UnitPoint(x: phase,       y: 0.0),
                    endPoint:   UnitPoint(x: phase + 1.0, y: 0.0)
                )
                .blendMode(.overlay)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1.5
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
