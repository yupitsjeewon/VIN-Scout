import SwiftUI
import VINScoutEngine

struct HomeView: View {

    @EnvironmentObject private var viewModel: VINScoutViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    vinSearchCard
                    if let error = viewModel.errorMessage {
                        errorBanner(message: error)
                    }
                    recentScansSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("VIN Scout")
            .navigationDestination(item: $viewModel.selectedVehicle) { vehicle in
                VehicleDetailView(vehicle: vehicle)
            }
        }
    }

    // MARK: - Search Card

    private var vinSearchCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Label
            Label("Enter VIN", systemImage: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(.primary)

            // Text field + character counter
            HStack(alignment: .center, spacing: 8) {
                TextField("e.g. 1HGCM82633A004352", text: $viewModel.vinInput)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced))
                    .keyboardType(.asciiCapable)
                    .submitLabel(.go)
                    .onSubmit {
                        Task { await viewModel.decode() }
                    }

                // Character counter badge
                Text("\(viewModel.characterCount)/17")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(viewModel.counterColor)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.counterColor)
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Inline warning for forbidden characters (I, O, Q)
            if let warning = viewModel.inlineWarning {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text(warning)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button {
                Task { await viewModel.decode() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text("Decoding…")
                        }
                    } else {
                        Label("Decode VIN", systemImage: "car.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.vinInput.isEmpty)
            .animation(.easeInOut(duration: 0.15), value: viewModel.isLoading)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Error Banner

    private func errorBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.title3)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(14)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: viewModel.errorMessage)
    }

    // MARK: - Recent Scans

    @ViewBuilder
    private var recentScansSection: some View {
        if !viewModel.recentVehicles.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Recent Scans", systemImage: "clock.arrow.circlepath")
                        .font(.headline)
                    Spacer()
                    Button("Clear", role: .destructive) {
                        withAnimation { viewModel.clearHistory() }
                    }
                    .font(.subheadline)
                }

                VStack(spacing: 1) {
                    ForEach(viewModel.recentVehicles, id: \.vin) { vehicle in
                        Button {
                            viewModel.select(vehicle)
                        } label: {
                            RecentScanRow(vehicle: vehicle)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Recent Scan Row

private struct RecentScanRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "car.fill")
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text([vehicle.year, vehicle.make, vehicle.model]
                    .compactMap { $0 }
                    .joined(separator: " "))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(vehicle.vin)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(.secondarySystemGroupedBackground))
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(VINScoutViewModel())
}
