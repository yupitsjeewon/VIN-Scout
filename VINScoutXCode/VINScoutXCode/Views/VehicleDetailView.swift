import SwiftUI
import VINScoutEngine

struct VehicleDetailView: View {

    let vehicle: Vehicle

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroHeader
                bodyDriveSection
                engineSection
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
            LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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

                // Edition badge: trim / series / series2 combined
                if let edition = vehicle.editionBadge {
                    Text(edition.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.25))
                        .clipShape(Capsule())
                        .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Body & Drive Section

    @ViewBuilder
    private var bodyDriveSection: some View {
        let cards: [(icon: String, label: String, value: String?)] = [
            ("car.side",        "Body Style",  vehicle.bodyClass),
            ("arrow.triangle.2.circlepath", "Drive Type", vehicle.driveType),
            ("door.left.hand.open", "Doors",   vehicle.doors),
        ]
        let filtered = cards.filter { $0.value != nil }

        if !filtered.isEmpty {
            SpecSection(title: "Body & Drive", icon: "car") {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered, id: \.label) { card in
                        SpecCard(icon: card.icon, label: card.label, value: card.value)
                    }
                }
            }
        }
    }

    // MARK: - Engine Section

    @ViewBuilder
    private var engineSection: some View {
        // Build turbo display string only if true
        let turboValue: String? = vehicle.isTurbocharged ? "Yes" : nil

        let cards: [(icon: String, label: String, value: String?)] = [
            ("bolt.fill",           "Horsepower",    vehicle.engineHorsepower.map { "\($0) hp" }),
            ("engine.combustion",   "Configuration", vehicle.engineConfiguration),
            ("cylinder.split.1x2",  "Cylinders",     vehicle.engineCylinders),
            ("gauge.with.dots.needle.67percent", "Displacement",
             vehicle.engineDisplacementL.map { "\($0)L" }),
            ("tag",                 "Engine Model",  vehicle.engineModel),
            ("waveform.path",       "Valve Train",   vehicle.valveTrainDesign),
            ("wind",                "Turbocharged",  turboValue),
            ("fuelpump.fill",       "Fuel Type",     vehicle.fuelType),
            ("gearshift.layout.automatic", "Transmission", vehicle.transmissionStyle),
            ("number",              "Speeds",        vehicle.transmissionSpeeds),
        ]
        let filtered = cards.filter { $0.value != nil }

        if !filtered.isEmpty {
            SpecSection(title: "Engine & Drivetrain", icon: "engine.combustion") {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered, id: \.label) { card in
                        SpecCard(icon: card.icon, label: card.label, value: card.value)
                    }
                }
            }
        }
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
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Spec Section Container

private struct SpecSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
            content()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Spec Card

private struct SpecCard: View {
    let icon: String
    let label: String
    let value: String?

    var body: some View {
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
            doors: "2",
            engineHorsepower: "240",
            engineConfiguration: "V-Shaped",
            engineCylinders: "6",
            engineDisplacementL: "3.0",
            engineModel: "J30A4",
            fuelType: "Gasoline",
            valveTrainDesign: "Single Overhead Cam (SOHC)",
            isTurbocharged: false,
            transmissionStyle: "Automatic",
            transmissionSpeeds: "5"
        ))
    }
}
