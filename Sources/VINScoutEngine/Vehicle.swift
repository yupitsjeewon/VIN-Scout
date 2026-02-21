import Foundation

/// A clean, internal representation of a vehicle decoded from a VIN.
/// Organised into the same categories shown in the UI: Year/Make/Model/Trim,
/// Body & Drive, and Engine & Transmission.
public struct Vehicle: Codable, Equatable, Hashable, CustomStringConvertible {

    // MARK: - Identity
    public let vin: String

    // MARK: - Year / Make / Model / Trim
    public let year: String?
    public let make: String?
    public let model: String?
    public let trim: String?
    public let series: String?

    // MARK: - Body & Drive
    public let bodyClass: String?
    public let driveType: String?
    public let doors: String?

    // MARK: - Engine
    public let engineHorsepower: String?        // e.g. "240"
    public let engineConfiguration: String?     // e.g. "V-Shaped"
    public let engineCylinders: String?         // e.g. "6"
    public let engineDisplacementL: String?     // e.g. "2.998832712"
    public let engineModel: String?             // e.g. "J30A4"
    public let fuelType: String?                // e.g. "Gasoline"
    public let valveTrainDesign: String?        // e.g. "Single Overhead Cam (SOHC)"
    public let isTurbocharged: Bool             // true if API returns "Yes"

    // MARK: - Transmission
    public let transmissionStyle: String?       // e.g. "Automatic"
    public let transmissionSpeeds: String?      // e.g. "5"

    // MARK: - Init
    // Explicitly public because Swift only generates an internal memberwise
    // initializer for public structs — external modules (e.g. the SwiftUI app)
    // cannot call it without this declaration.
    public init(
        vin: String,
        year: String? = nil,
        make: String? = nil,
        model: String? = nil,
        trim: String? = nil,
        series: String? = nil,
        bodyClass: String? = nil,
        driveType: String? = nil,
        doors: String? = nil,
        engineHorsepower: String? = nil,
        engineConfiguration: String? = nil,
        engineCylinders: String? = nil,
        engineDisplacementL: String? = nil,
        engineModel: String? = nil,
        fuelType: String? = nil,
        valveTrainDesign: String? = nil,
        isTurbocharged: Bool = false,
        transmissionStyle: String? = nil,
        transmissionSpeeds: String? = nil
    ) {
        self.vin = vin
        self.year = year
        self.make = make
        self.model = model
        self.trim = trim
        self.series = series
        self.bodyClass = bodyClass
        self.driveType = driveType
        self.doors = doors
        self.engineHorsepower = engineHorsepower
        self.engineConfiguration = engineConfiguration
        self.engineCylinders = engineCylinders
        self.engineDisplacementL = engineDisplacementL
        self.engineModel = engineModel
        self.fuelType = fuelType
        self.valveTrainDesign = valveTrainDesign
        self.isTurbocharged = isTurbocharged
        self.transmissionStyle = transmissionStyle
        self.transmissionSpeeds = transmissionSpeeds
    }

    // MARK: - CustomStringConvertible
    public var description: String {
        var lines: [String] = ["── Vehicle ──────────────────"]
        lines.append("  VIN             : \(vin)")
        if let y = year              { lines.append("  Year            : \(y)") }
        if let mk = make             { lines.append("  Make            : \(mk)") }
        if let mo = model            { lines.append("  Model           : \(mo)") }
        if let t = trim              { lines.append("  Trim            : \(t)") }
        if let s = series            { lines.append("  Series          : \(s)") }
        lines.append("  ── Body & Drive ─────────────")
        if let b = bodyClass         { lines.append("  Body Class      : \(b)") }
        if let d = driveType         { lines.append("  Drive Type      : \(d)") }
        if let dr = doors            { lines.append("  Doors           : \(dr)") }
        lines.append("  ── Engine ───────────────────")
        if let hp = engineHorsepower { lines.append("  Horsepower      : \(hp) hp") }
        if let cfg = engineConfiguration { lines.append("  Configuration   : \(cfg)") }
        if let c = engineCylinders   { lines.append("  Cylinders       : \(c)") }
        if let l = engineDisplacementL { lines.append("  Displacement    : \(l)L") }
        if let em = engineModel      { lines.append("  Engine Model    : \(em)") }
        if let vt = valveTrainDesign { lines.append("  Valve Train     : \(vt)") }
        if isTurbocharged            { lines.append("  Turbo           : Yes") }
        if let f = fuelType          { lines.append("  Fuel Type       : \(f)") }
        if let ts = transmissionStyle { lines.append("  Transmission    : \(ts)") }
        if let sp = transmissionSpeeds { lines.append("  Speeds          : \(sp)") }
        lines.append("─────────────────────────────")
        return lines.joined(separator: "\n")
    }

    // MARK: - Factory

    /// Maps a raw `NHTSAResult` to this clean model.
    public static func from(vin: String, result: NHTSAResult) -> Vehicle {
        Vehicle(
            vin:                  vin.uppercased(),
            year:                 nonEmpty(result.ModelYear),
            make:                 nonEmpty(result.Make),
            model:                nonEmpty(result.Model),
            trim:                 nonEmpty(result.Trim),
            series:               nonEmpty(result.Series),
            bodyClass:            nonEmpty(result.BodyClass),
            driveType:            nonEmpty(result.DriveType),
            doors:                nonEmpty(result.Doors),
            engineHorsepower:     nonEmpty(result.EngineHP),
            engineConfiguration:  nonEmpty(result.EngineConfiguration),
            engineCylinders:      nonEmpty(result.EngineCylinders),
            engineDisplacementL:  nonEmpty(result.DisplacementL),
            engineModel:          nonEmpty(result.EngineModel),
            fuelType:             nonEmpty(result.FuelTypePrimary),
            valveTrainDesign:     nonEmpty(result.ValveTrainDesign),
            isTurbocharged:       result.Turbo?.lowercased() == "yes",
            transmissionStyle:    nonEmpty(result.TransmissionStyle),
            transmissionSpeeds:   nonEmpty(result.TransmissionSpeeds)
        )
    }

    // MARK: - Private helpers

    /// Returns the string only if it's non-nil and non-empty.
    private static func nonEmpty(_ value: String?) -> String? {
        guard let v = value, !v.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return v.trimmingCharacters(in: .whitespaces)
    }
}
