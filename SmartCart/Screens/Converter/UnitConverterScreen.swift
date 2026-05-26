//
//  UnitConverterScreen.swift
//  SmartCart
//

import SwiftUI

enum ConversionCategory: String, CaseIterable {
    case volume = "Volume"
    case weight = "Weight"
    case temperature = "Temperature"
}

enum VolumeUnit: String, CaseIterable {
    case ml, liter, tsp, tbsp, flOz, cup, pint, quart, gallon
    var toMl: Double {
        switch self {
        case .ml: return 1
        case .liter: return 1000
        case .tsp: return 4.92892
        case .tbsp: return 14.7868
        case .flOz: return 29.5735
        case .cup: return 236.588
        case .pint: return 473.176
        case .quart: return 946.353
        case .gallon: return 3785.41
        }
    }
    var label: String {
        switch self {
        case .flOz: return "fl oz"
        default: return rawValue.capitalized
        }
    }
}

enum WeightUnit: String, CaseIterable {
    case g, kg, mg, oz, lb
    var toGrams: Double {
        switch self {
        case .g: return 1
        case .kg: return 1000
        case .mg: return 0.001
        case .oz: return 28.3495
        case .lb: return 453.592
        }
    }
    var label: String { rawValue.uppercased() }
}

struct UnitConverterScreen: View {
    var onBack: () -> Void

    @State private var category: ConversionCategory = .volume
    @State private var inputValue = "1"
    @State private var fromVolume: VolumeUnit = .cup
    @State private var toVolume: VolumeUnit = .ml
    @State private var fromWeight: WeightUnit = .oz
    @State private var toWeight: WeightUnit = .g
    @State private var fromTemp = "celsius"
    @State private var toTemp = "fahrenheit"

    private var outputValue: String {
        guard let val = Double(inputValue.replacingOccurrences(of: ",", with: ".")) else { return "—" }
        switch category {
        case .volume:
            let ml = val * fromVolume.toMl / toVolume.toMl
            return format(ml)
        case .weight:
            let g = val * fromWeight.toGrams / toWeight.toGrams
            return format(g)
        case .temperature:
            let c: Double
            switch fromTemp {
            case "celsius": c = val
            case "fahrenheit": c = (val - 32) * 5/9
            case "kelvin": c = val - 273.15
            default: c = val
            }
            let out: Double
            switch toTemp {
            case "celsius": out = c
            case "fahrenheit": out = c * 9/5 + 32
            case "kelvin": out = c + 273.15
            default: out = c
            }
            return format(out)
        }
    }

    private func format(_ d: Double) -> String {
        if d >= 1000 || (d < 0.01 && d > 0) { return String(format: "%.4g", d) }
        return String(format: "%.2f", d)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("🍳")
                    .font(.system(size: 56))
                    .frame(maxWidth: .infinity)
                Text("Kitchen Converter")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                    .frame(maxWidth: .infinity)

                Picker("Category", selection: $category) {
                    ForEach(ConversionCategory.allCases, id: \.rawValue) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Amount", text: $inputValue)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)

                switch category {
                case .volume:
                    HStack(spacing: 12) {
                        Picker("From", selection: $fromVolume) {
                            ForEach(VolumeUnit.allCases, id: \.rawValue) { Text($0.label).tag($0) }
                        }
                        .pickerStyle(.menu)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                        Picker("To", selection: $toVolume) {
                            ForEach(VolumeUnit.allCases, id: \.rawValue) { Text($0.label).tag($0) }
                        }
                        .pickerStyle(.menu)
                    }
                case .weight:
                    HStack(spacing: 12) {
                        Picker("From", selection: $fromWeight) {
                            ForEach(WeightUnit.allCases, id: \.rawValue) { Text($0.label).tag($0) }
                        }
                        .pickerStyle(.menu)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                        Picker("To", selection: $toWeight) {
                            ForEach(WeightUnit.allCases, id: \.rawValue) { Text($0.label).tag($0) }
                        }
                        .pickerStyle(.menu)
                    }
                case .temperature:
                    HStack(spacing: 12) {
                        Picker("From", selection: $fromTemp) {
                            Text("°C").tag("celsius")
                            Text("°F").tag("fahrenheit")
                            Text("K").tag("kelvin")
                        }
                        .pickerStyle(.menu)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                        Picker("To", selection: $toTemp) {
                            Text("°C").tag("celsius")
                            Text("°F").tag("fahrenheit")
                            Text("K").tag("kelvin")
                        }
                        .pickerStyle(.menu)
                    }
                }

                Text("= \(outputValue)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primary)
                    .frame(maxWidth: .infinity)
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Unit Converter")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        UnitConverterScreen(onBack: {})
    }
}
