import SwiftUI
import VINScoutEngine

struct VehicleDetailView: View {

    let vehicle: Vehicle

    // 2-column flexible grid for the specs
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroHeader
                specsGrid
                vinFooter
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(vehicle.vin)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Content
            VStack(alignment: .leading, spacing: 4) {
                if let year = vehicle.year {
                    Text(year)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                }

                Text([vehicle.make, vehicle.model]
                    .compactMap { $0 }
                    .joined(separator: " "))
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                if let trim = vehicle.trim, !trim.isEmpty {
                    Text(trim)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.top, 2)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Specs Grid

    private var specsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Specifications", systemImage: "list.bullet.rectangle")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                SpecCard(
                    icon: "car.side",
                    label: "Body",
                    value: vehicle.bodyClass
                )
                SpecCard(
                    icon: "arrow.triangle.2.circlepath",
                    label: "Drive Type",
                    value: vehicle.driveType
                )
                SpecCard(
                    icon: "cylinder.split.1x2",
                    label: "Cylinders",
                    value: vehicle.engineCylinders
                )
                SpecCard(
                    icon: "gauge.with.dots.needle.67percent",
                    label: "Displacement",
                    value: vehicle.engineDisplacementL.map { "\($0)L" }
                )
                SpecCard(
                    icon: "fuelpump.fill",
                    label: "Fuel Type",
                    value: vehicle.fuelType
                )
                SpecCard(
                    icon: "building.2",
                    label: "Manufacturer",
                    value: vehicle.manufacturer
                )
                SpecCard(
                    icon: "globe",
                    label: "Plant Country",
                    value: vehicle.plantCountry
                )
                SpecCard(
                    icon: "tag",
                    label: "Vehicle Type",
                    value: vehicle.vehicleType
                )
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - VIN Footer

    private var vinFooter: some View {
        VStack(spacing: 6) {
            Text("VIN")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(vehicle.vin)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.primary)
                .textSelection(.enabled)   // Long-press to copy
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Spec Card Component

private struct SpecCard: View {
    let icon: String
    let label: String
    let value: String?

    var body: some View {
        // Don't render cards whose value is nil
        if let value {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundStyle(.tint)
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VehicleDetailView(vehicle: Vehicle(
            vin: "1HGCM82633A004352",
            year: "2003",
            make: "HONDA",
            model: "Accord",
            trim: "EX-V6",
            bodyClass: "Coupe",
            driveType: "FWD",
            engineCylinders: "6",
            engineDisplacementL: "2.998832712",
            fuelType: "Gasoline",
            manufacturer: "AMERICAN HONDA MOTOR CO., INC.",
            plantCountry: "UNITED STATES (USA)",
            vehicleType: "PASSENGER CAR"
        ))
    }
}
