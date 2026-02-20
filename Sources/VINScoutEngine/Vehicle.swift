import Foundation

/// A clean, internal representation of a vehicle decoded from a VIN.
/// This struct decouples the rest of the app from the raw NHTSA JSON shape.
public struct Vehicle: Codable, Equatable, CustomStringConvertible {

    // MARK: - Properties
    public let vin: String
    public let year: String?
    public let make: String?
    public let model: String?
    public let trim: String?
    public let bodyClass: String?
    public let driveType: String?
    public let engineCylinders: String?
    public let engineDisplacementL: String?
    public let fuelType: String?
    public let manufacturer: String?
    public let plantCountry: String?
    public let vehicleType: String?

    // MARK: - CustomStringConvertible
    public var description: String {
        var lines: [String] = ["── Vehicle ──────────────────"]
        lines.append("  VIN          : \(vin)")
        if let y = year         { lines.append("  Year         : \(y)") }
        if let mk = make        { lines.append("  Make         : \(mk)") }
        if let mo = model       { lines.append("  Model        : \(mo)") }
        if let t = trim, !t.isEmpty  { lines.append("  Trim         : \(t)") }
        if let b = bodyClass    { lines.append("  Body Class   : \(b)") }
        if let d = driveType    { lines.append("  Drive Type   : \(d)") }
        if let c = engineCylinders  { lines.append("  Cylinders    : \(c)") }
        if let l = engineDisplacementL { lines.append("  Displacement : \(l)L") }
        if let f = fuelType     { lines.append("  Fuel Type    : \(f)") }
        if let m = manufacturer { lines.append("  Manufacturer : \(m)") }
        if let p = plantCountry { lines.append("  Plant Country: \(p)") }
        if let v = vehicleType  { lines.append("  Vehicle Type : \(v)") }
        lines.append("─────────────────────────────")
        return lines.joined(separator: "\n")
    }

    // MARK: - Factory

    /// Maps a raw `NHTSAResult` to this clean model.
    /// - Parameters:
    ///   - vin: The original VIN string that was looked up.
    ///   - result: The decoded `NHTSAResult` from the API.
    public static func from(vin: String, result: NHTSAResult) -> Vehicle {
        Vehicle(
            vin:                  vin.uppercased(),
            year:                 nonEmpty(result.ModelYear),
            make:                 nonEmpty(result.Make),
            model:                nonEmpty(result.Model),
            trim:                 nonEmpty(result.Trim),
            bodyClass:            nonEmpty(result.BodyClass),
            driveType:            nonEmpty(result.DriveType),
            engineCylinders:      nonEmpty(result.EngineCylinders),
            engineDisplacementL:  nonEmpty(result.DisplacementL),
            fuelType:             nonEmpty(result.FuelTypePrimary),
            manufacturer:         nonEmpty(result.Manufacturer),
            plantCountry:         nonEmpty(result.PlantCountry),
            vehicleType:          nonEmpty(result.VehicleType)
        )
    }

    // MARK: - Private helpers

    /// Returns the string only if it's non-nil and non-empty.
    private static func nonEmpty(_ value: String?) -> String? {
        guard let v = value, !v.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return v.trimmingCharacters(in: .whitespaces)
    }
}
