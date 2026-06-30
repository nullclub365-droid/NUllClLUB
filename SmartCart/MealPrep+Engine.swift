//
//  MealPrep+Engine.swift
//  SmartCart
//
//  Models, persistence, notifications, and the planning engine for the weekly
//  meal-prep cook session. Views live in WeeklyCookingWizard.swift.
//

import SwiftUI
import Foundation
import Combine
import UserNotifications

// MARK: - Step 3: Meal-Prep Session (consolidated phase timeline)

/// The five working phases of a batch meal-prep session, in order.
enum CookPhaseKind: Int, CaseIterable {
    case gamePlan, prep, slowCook, activeCook, assemble, store

    var title: String {
        switch self {
        case .gamePlan: return "Your game plan"
        case .prep: return "1 · Prep everything"
        case .slowCook: return "2 · Start the slow stuff"
        case .activeCook: return "3 · Active cooking"
        case .assemble: return "4 · Assemble & finish"
        case .store: return "5 · Portion & freeze"
        }
    }

    var subtitle: String {
        switch self {
        case .gamePlan: return "One cook session for the whole week"
        case .prep: return "Knock out all the chopping, seasoning & mixing at once"
        case .slowCook: return "Get the oven & pots going — these run by themselves"
        case .activeCook: return "Now cook everything on the stove while the slow stuff finishes"
        case .assemble: return "Bring each dish together"
        case .store: return "Cool, pack and label — then eat on the days below"
        }
    }

    var icon: String {
        switch self {
        case .gamePlan: return "list.clipboard.fill"
        case .prep: return "knife"
        case .slowCook: return "flame.fill"
        case .activeCook: return "frying.pan.fill"
        case .assemble: return "takeoutbag.and.cup.and.straw.fill"
        case .store: return "snowflake"
        }
    }

    var accent: Color {
        switch self {
        case .gamePlan: return AppTheme.primary
        case .prep: return AppTheme.tertiary
        case .slowCook: return AppTheme.secondary
        case .activeCook: return Color(red: 0.83, green: 0.33, blue: 0.30) // brand red — active heat
        case .assemble: return AppTheme.primary
        case .store: return AppTheme.tertiary
        }
    }
}

/// A single consolidated instruction inside a phase, sourced from a recipe's step.
/// `id` is stable across rebuilds so completion + timers can be persisted/resumed.
struct PhaseTask: Identifiable {
    let id: String          // "<recipeId>#<stepIndex>" or "preheat"
    let recipeId: Int64
    let recipeName: String
    let portionCount: Int
    let recipeOrder: Int    // keeps a recipe's steps contiguous within a phase
    let stepIndex: Int
    let title: String
    let instruction: String
    let durationSeconds: Int?
}

/// Per-recipe freezing / eat-by guidance for the storage phase.
struct StoragePlan: Identifiable {
    let id: Int64
    let recipeName: String
    let portionCount: Int
    let days: [String]
    let caloriesPerPortion: Int
    let proteinPerPortion: Int

    var fridgeDays: [String] { Array(days.prefix(3)) }
    var freezerDays: [String] { Array(days.dropFirst(3)) }
}

/// One entry in the suggested clock-based timeline shown on the game plan.
struct TimelineEntry: Identifiable {
    let id = UUID()
    let atMinute: Int
    let text: String
    let isHandsOff: Bool

    var clock: String { String(format: "%d:%02d", atMinute / 60, atMinute % 60) }
}

/// A timer anchored to a wall-clock end time, so it keeps counting while the app
/// is backgrounded and survives being saved/restored. Supports pause and ±adjust.
struct SessionTimer: Identifiable {
    let id: String          // == owning task id, or "custom-<uuid>"
    let label: String
    var totalSeconds: Int
    var endEpoch: Double
    var stopped: Bool = false
    var pausedRemaining: Int? = nil   // non-nil while paused

    var isPaused: Bool { pausedRemaining != nil }

    var remainingSeconds: Int {
        if let p = pausedRemaining { return p }
        guard !stopped else { return 0 }
        return max(0, Int(ceil(endEpoch - Date().timeIntervalSince1970)))
    }
    var isFinished: Bool { !isPaused && remainingSeconds == 0 }
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(1, 1.0 - Double(remainingSeconds) / Double(totalSeconds))
    }
    var timeString: String {
        let r = remainingSeconds
        return String(format: "%d:%02d", r / 60, r % 60)
    }

    var isCustom: Bool { id.hasPrefix("custom-") }
}

/// Consolidated, gather-once ingredient with per-dish (scaled) quantities.
struct PrepIngredient: Identifiable {
    let id: Int64
    let name: String
    let category: String
    let contributions: [(dish: String, qty: String)]

    var dishesLabel: String { contributions.map(\.dish).joined(separator: ", ") }
    var qtyLabel: String {
        contributions.map { $0.qty.isEmpty ? $0.dish : "\($0.qty) (\($0.dish))" }.joined(separator: " + ")
    }

    /// A single summed amount when every dish uses the same unit ("750 g total"), else nil.
    var combinedTotal: String? {
        let qtys = contributions.map(\.qty).filter { !$0.isEmpty }
        guard qtys.count == contributions.count else { return nil }
        return QtyScaler.combine(qtys)
    }
}

// MARK: - Persistence

struct SavedTimer: Codable {
    var taskId: String
    var label: String
    var totalSeconds: Int
    var endEpoch: Double
    var stopped: Bool
    var pausedRemaining: Int? = nil
}

struct SavedMealPrepSession: Codable {
    var templateId: Int64
    var selectedRecipeIds: [Int64]
    var phaseIndex: Int
    var completedTaskIds: [String]
    var timers: [SavedTimer]
    var savedAtEpoch: Double
    var firedTimerIds: [String] = []   // timers that already rang — don't re-alert on relaunch
}

enum MealPrepSessionStore {
    private static let key = "smartcart_mealprep_session"
    /// A cook session can legitimately span a weekend (start Sat, resume Sun). We keep it for a
    /// week and never silently delete it mid-flow — only an explicit "Start over" clears it.
    static let staleAfter: TimeInterval = 7 * 86400

    static func save(_ session: SavedMealPrepSession) {
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    static func load() -> SavedMealPrepSession? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let s = try? JSONDecoder().decode(SavedMealPrepSession.self, from: data) else { return nil }
        // Past the window, ignore it (but don't destructively wipe — the user may still want it).
        if Date().timeIntervalSince1970 - s.savedAtEpoch > staleAfter { return nil }
        return s
    }
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

/// Read-only status other screens (e.g. Home) can surface without touching the private store.
enum MealPrepStatus {
    static var hasInProgressSession: Bool {
        guard let data = UserDefaults.standard.data(forKey: "smartcart_mealprep_session"),
              let s = try? JSONDecoder().decode(SavedMealPrepSession.self, from: data) else { return false }
        return Date().timeIntervalSince1970 - s.savedAtEpoch <= MealPrepSessionStore.staleAfter
    }

    /// Names of dishes from the most recent completed prep, if within the last 7 days.
    static var recentStash: [String] {
        let completed = UserDefaults.standard.double(forKey: "smartcart_mealprep_last_completed")
        guard completed > 0, Date().timeIntervalSince1970 - completed <= 7 * 86400 else { return [] }
        return UserDefaults.standard.stringArray(forKey: "smartcart_mealprep_last_stash") ?? []
    }
}

/// Observable wrapper so Home (and others) react to meal-prep state changes instead of
/// reading UserDefaults inside `body`. Call `refresh()` whenever the session changes.
@MainActor
final class MealPrepStatusModel: ObservableObject {
    static let shared = MealPrepStatusModel()
    @Published var hasInProgressSession = false
    @Published var recentStash: [String] = []

    func refresh() {
        hasInProgressSession = MealPrepStatus.hasInProgressSession
        recentStash = MealPrepStatus.recentStash
    }
}

// MARK: - Timer notifications

enum MealPrepTimerNotifier {
    static func schedule(taskId: String, label: String, fireAfter seconds: Int) {
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Timer done ⏰"
        content.body = "\(label) is ready — come back and continue your meal prep."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(seconds), repeats: false)
        let req = UNNotificationRequest(identifier: notifId(taskId), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
    static func cancel(taskId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifId(taskId)])
    }
    private static func notifId(_ taskId: String) -> String { "smartcart_mealprep_timer_\(taskId)" }
}

// MARK: - Planner

/// Builds a consolidated, phase-organised meal-prep plan from the selected recipes.
/// Reads each recipe's real steps, keeps every recipe's steps in their original order
/// (monotonic phases), front-loads the longest hands-off work, and derives a suggested
/// clock timeline plus the equipment you'll need.
enum MealPrepPlanner {
    struct Plan {
        var tasks: [CookPhaseKind: [PhaseTask]]
        var storage: [StoragePlan]
        var timeline: [TimelineEntry]
        var equipment: [String]
        var ovenWarning: String?
        var noCookItems: [String]   // single-step / no-cook dishes made fresh, kept out of the flow
        var mergeHints: [String] = [] // "cook pasta once for X + Y" — keeps the per-recipe steps intact
    }

    static func build(from groups: [BatchCookGroup], household: Int = 1) -> Plan {
        // Split out trivial "no-cook" dishes (overnight oats, shakes) so they don't clutter the flow.
        let cookGroups = groups.filter { !isNoCook($0.recipe) }
        let noCookItems = groups.filter { isNoCook($0.recipe) }.map(\.recipe.name)

        var tasks: [CookPhaseKind: [PhaseTask]] = [:]
        var needsOven = false
        var ovenDishCount = 0
        var potDishCount = 0
        var needsSkillet = false
        var needsBlender = false
        var needsSheetPan = false

        for (recipeOrder, group) in cookGroups.enumerated() {
            var maxPhase = CookPhaseKind.prep.rawValue
            var recipeUsesOven = false
            var recipeUsesPot = false
            for (stepIndex, step) in group.recipe.steps.enumerated() {
                // Clamp each recipe's steps to non-decreasing phases so its internal order never breaks.
                let raw = max(classify(step).rawValue, maxPhase)
                maxPhase = raw
                let phase = CookPhaseKind(rawValue: raw) ?? .prep

                let t = step.title.lowercased()
                if t.contains("bake") || t.contains("roast") { needsOven = true; recipeUsesOven = true; needsSheetPan = true }
                if t.contains("boil") || t.contains("simmer") || t.contains("braise") || t.contains("broth") || t.contains("poach") { recipeUsesPot = true }
                if t.contains("sauté") || t.contains("saute") || t.contains("sear") || t.contains("fry") || t.contains("scramble") || t.contains("brown") || t.contains("cook chicken") || t.contains("cook beef") { needsSkillet = true }
                if t.contains("blend") { needsBlender = true }

                tasks[phase, default: []].append(PhaseTask(
                    id: "\(group.recipe.id)#\(stepIndex)",
                    recipeId: group.recipe.id,
                    recipeName: group.recipe.name,
                    portionCount: group.portionCount,
                    recipeOrder: recipeOrder,
                    stepIndex: stepIndex,
                    title: step.title,
                    instruction: step.description,
                    durationSeconds: step.durationSeconds
                ))
            }
            if recipeUsesOven { ovenDishCount += 1 }
            if recipeUsesPot { potDishCount += 1 }
        }

        // Slow phase: longest hands-off first so they overlap. We surface a "cook these together"
        // hint instead of merging the tasks, so each recipe keeps its own timer/quantities/quick-look.
        let mergeHints = techniqueHints(tasks[.slowCook] ?? [])
        tasks[.slowCook]?.sort { ($0.durationSeconds ?? 0) > ($1.durationSeconds ?? 0) }
        // Prep: marinades to the very top (they need to sit), then recipe order.
        tasks[.prep]?.sort {
            let m0 = isMarinate($0), m1 = isMarinate($1)
            if m0 != m1 { return m0 }
            return ($0.recipeOrder, $0.stepIndex) < ($1.recipeOrder, $1.stepIndex)
        }
        for phase in [CookPhaseKind.activeCook, .assemble] {
            tasks[phase]?.sort { ($0.recipeOrder, $0.stepIndex) < ($1.recipeOrder, $1.stepIndex) }
        }

        if needsOven {
            tasks[.slowCook, default: []].insert(PhaseTask(
                id: "preheat",
                recipeId: -1,
                recipeName: "All baked dishes",
                portionCount: 1,
                recipeOrder: -1,
                stepIndex: -1,
                title: "Preheat the oven",
                instruction: "Turn the oven on now so it's hot when you're ready — match the temperature in your bake/roast steps below.",
                durationSeconds: nil
            ), at: 0)
        }

        let storage = cookGroups.map {
            StoragePlan(
                id: $0.recipe.id,
                recipeName: $0.recipe.name,
                portionCount: $0.portionCount,
                days: $0.appearances.map(\.day),
                caloriesPerPortion: $0.recipe.calories,
                proteinPerPortion: $0.recipe.protein
            )
        }

        var equipment: [String] = []
        if needsOven { equipment.append("Oven") }
        if potDishCount > 0 {
            // Cooking for a bigger household may need a bigger/extra pot.
            let pots = min(potDishCount + (household > 4 ? 1 : 0), 4)
            equipment.append("\(pots) pot\(pots == 1 ? "" : "s")")
        }
        if needsSkillet { equipment.append(household > 4 ? "Large skillet (or two)" : "Large skillet") }
        if needsSheetPan { equipment.append("Sheet pan") }
        if needsBlender { equipment.append("Blender") }
        let containers = storage.reduce(0) { $0 + $1.portionCount }
        equipment.append(household > 1
            ? "\(containers) containers (each feeds \(household))"
            : "Containers for \(containers) portions")

        let ovenWarning = ovenDishCount > 2
            ? "\(ovenDishCount) dishes need the oven — bake them in 2–3 batches if they don't all fit."
            : nil

        let timeline = buildTimeline(tasks: tasks, needsOven: needsOven)

        return Plan(tasks: tasks, storage: storage, timeline: timeline, equipment: equipment, ovenWarning: ovenWarning, noCookItems: noCookItems, mergeHints: mergeHints)
    }

    /// A dish is "no-cook" when it has no steps, or a single step that isn't a cooking action.
    private static func isNoCook(_ recipe: Recipe) -> Bool {
        guard recipe.steps.count <= 1 else { return false }
        guard let only = recipe.steps.first else { return true }
        let t = only.title.lowercased() + " " + only.description.lowercased()
        let cookWords = ["bake", "roast", "boil", "simmer", "grill", "fry", "sauté", "saute", "sear", "cook", "braise", "poach", "scramble", "brown", "toast", "heat"]
        return !cookWords.contains(where: t.contains)
    }

    private static func isMarinate(_ task: PhaseTask) -> Bool {
        task.title.lowercased().contains("marinat")
    }

    /// A shared cooking technique that can be done in one vessel for several recipes at once.
    private static func techniqueKey(_ task: PhaseTask) -> String? {
        let t = (task.title + " " + task.instruction).lowercased()
        if t.contains("pasta") || t.contains("noodle") { return "pasta" }
        if t.contains("rice") { return "rice" }
        if t.contains("boil") && (t.contains("water") || t.contains("egg")) { return "boil" }
        return nil
    }

    /// Produces "cook these together" hints for techniques shared across recipes, WITHOUT
    /// merging the tasks — each recipe keeps its own step, timer, quantities and quick-look.
    private static func techniqueHints(_ tasks: [PhaseTask]) -> [String] {
        var grouped: [String: [String]] = [:]
        let pretty = ["pasta": "Pasta", "rice": "Rice", "boil": "Boiling water"]
        for task in tasks {
            if let key = techniqueKey(task), task.recipeId > 0 {
                if !(grouped[key]?.contains(task.recipeName) ?? false) {
                    grouped[key, default: []].append(task.recipeName)
                }
            }
        }
        return grouped.compactMap { key, names in
            guard names.count > 1 else { return nil }
            return "\(pretty[key] ?? key.capitalized): cook one big batch for \(names.joined(separator: " + "))."
        }
    }

    /// A readable suggested schedule with running clock offsets.
    private static func buildTimeline(tasks: [CookPhaseKind: [PhaseTask]], needsOven: Bool) -> [TimelineEntry] {
        var entries: [TimelineEntry] = []
        var clock = 0 // minutes
        func mins(_ secs: Int?) -> Int { max(1, (secs ?? 150) / 60) }

        // Prep block
        let prep = tasks[.prep] ?? []
        if !prep.isEmpty {
            entries.append(TimelineEntry(atMinute: clock, text: "Prep & lay out all ingredients (\(prep.count) tasks)", isHandsOff: false))
            clock += prep.reduce(0) { $0 + mins($1.durationSeconds) }
        }

        // Slow / hands-off: started here, run in the background.
        let slow = (tasks[.slowCook] ?? []).filter { $0.id != "preheat" }
        if needsOven {
            entries.append(TimelineEntry(atMinute: clock, text: "Preheat oven", isHandsOff: true))
        }
        for item in slow {
            let ready = clock + mins(item.durationSeconds)
            entries.append(TimelineEntry(
                atMinute: clock,
                text: "Start \(item.recipeName) — \(item.title.lowercased()). Ready ~\(String(format: "%d:%02d", ready / 60, ready % 60))",
                isHandsOff: true
            ))
            clock += 2 // ~2 min hands-on to get each going
        }

        // Active cooking
        for item in tasks[.activeCook] ?? [] {
            entries.append(TimelineEntry(atMinute: clock, text: "\(item.recipeName): \(item.title.lowercased())", isHandsOff: false))
            clock += mins(item.durationSeconds)
        }

        // Assemble
        let assemble = tasks[.assemble] ?? []
        if !assemble.isEmpty {
            entries.append(TimelineEntry(atMinute: clock, text: "Assemble & finish all dishes (\(assemble.count) tasks)", isHandsOff: false))
            clock += assemble.reduce(0) { $0 + mins($1.durationSeconds) }
        }

        entries.append(TimelineEntry(atMinute: clock, text: "Cool, portion, label & freeze", isHandsOff: false))
        return entries
    }

    static func estimateMinutes(_ tasks: [CookPhaseKind: [PhaseTask]]) -> (handsOn: Int, total: Int) {
        func sum(_ kind: CookPhaseKind) -> Int {
            (tasks[kind] ?? []).reduce(0) { $0 + ($1.durationSeconds ?? 150) }
        }
        let handsOn = sum(.prep) + sum(.activeCook) + sum(.assemble)
        let longestSlow = (tasks[.slowCook] ?? []).map { $0.durationSeconds ?? 0 }.max() ?? 0
        return (handsOn / 60, (handsOn + longestSlow) / 60)
    }

    private static func classify(_ step: RecipeStep) -> CookPhaseKind {
        let t = step.title.lowercased()
        // Note: "marinate" is intentionally NOT here — it's handled as a prep-phase task
        // that sorts to the very top so it can sit while everything else is prepped.
        let slow = ["boil", "bake", "roast", "braise", "simmer", "poach", "broth", "cook rice", "cook pasta", "cook noodle", "rest", "chill", "proof"]
        let assemble = ["assemble", "top", "finish", "layer", "wrap", "roll", "garnish", "arrange", "dress", "toss", "serve", "glaze", "stuff", "fill", "spread", "add sauce", "add broth", "add liquid"]
        let active = ["cook", "grill", "fry", "sauté", "saute", "sear", "brown", "scramble", "bacon", "warm tortilla", "toast", "add veg", "add egg", "stir fry"]

        if slow.contains(where: t.contains) { return .slowCook }
        if assemble.contains(where: t.contains) { return .assemble }
        if active.contains(where: t.contains) { return .activeCook }
        return .prep
    }
}

// MARK: - Quantity scaling

enum QtyScaler {
    private static let unicodeFractions: [Character: Double] = [
        "½": 0.5, "⅓": 1.0/3, "⅔": 2.0/3, "¼": 0.25, "¾": 0.75,
        "⅕": 0.2, "⅖": 0.4, "⅗": 0.6, "⅘": 0.8, "⅙": 1.0/6, "⅛": 0.125
    ]

    /// Scales a free-text quantity for batch cooking. Handles whole numbers, decimals,
    /// "a/b" and unicode fractions, and ranges ("2-3"). Leaves vague amounts
    /// ("to taste", "a pinch", "as needed") untouched.
    static func scale(_ qty: String, by mult: Int) -> String {
        let trimmed = qty.trimmingCharacters(in: .whitespaces)
        guard mult > 1, !trimmed.isEmpty else { return qty }

        let lower = trimmed.lowercased()
        for vague in ["to taste", "as needed", "pinch", "drizzle", "splash", "for serving", "optional"] where lower.contains(vague) {
            return qty // don't scale vague amounts
        }

        // Range like "2-3 cloves" or "2–3" → scale both ends.
        if let rangeMatch = trimmed.range(of: #"^\s*(\d+\.?\d*)\s*[-–]\s*(\d+\.?\d*)"#, options: .regularExpression) {
            let nums = trimmed[rangeMatch].components(separatedBy: CharacterSet(charactersIn: "-–")).compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            if nums.count == 2 {
                let scaled = "\(fmt(nums[0] * Double(mult)))–\(fmt(nums[1] * Double(mult)))"
                return trimmed.replacingCharacters(in: rangeMatch, with: scaled)
            }
        }

        // Unicode fraction, optionally with a leading whole number ("1½").
        if let idx = trimmed.firstIndex(where: { unicodeFractions[$0] != nil }) {
            let frac = unicodeFractions[trimmed[idx]] ?? 0
            let leading = trimmed[trimmed.startIndex..<idx].trimmingCharacters(in: .whitespaces)
            let whole = Double(leading) ?? 0
            let total = (whole + frac) * Double(mult)
            let after = trimmed[trimmed.index(after: idx)...]
            return "\(fmt(total))\(after)"
        }

        // "a/b" fraction ("1/2 cup").
        if let m = trimmed.range(of: #"^\s*(\d+)\s*/\s*(\d+)"#, options: .regularExpression) {
            let parts = trimmed[m].components(separatedBy: "/").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            if parts.count == 2, parts[1] != 0 {
                let scaled = parts[0] / parts[1] * Double(mult)
                return trimmed.replacingCharacters(in: m, with: fmt(scaled))
            }
        }

        // Plain number / decimal.
        if let range = trimmed.range(of: #"\d+\.?\d*"#, options: .regularExpression),
           let value = Double(trimmed[range]) {
            return trimmed.replacingCharacters(in: range, with: fmt(value * Double(mult)))
        }

        return "\(qty) ×\(mult)"
    }

    private static func fmt(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(v)) : String(format: "%g", v)
    }

    /// Sums several quantities into one total when they share the same unit
    /// ("500 g" + "250 g" → "750 g", "2 breasts" + "4 breasts" → "6 breasts").
    /// Returns nil when units differ or any amount can't be parsed, so the caller
    /// can fall back to listing them separately.
    static func combine(_ quantities: [String]) -> String? {
        guard quantities.count > 1 else { return nil }
        var total = 0.0
        var unit: String? = nil
        for q in quantities {
            guard let (value, u) = parse(q) else { return nil }
            if let existing = unit {
                if existing.lowercased() != u.lowercased() { return nil }
            } else {
                unit = u
            }
            total += value
        }
        let u = unit ?? ""
        return u.isEmpty ? fmt(total) : "\(fmt(total)) \(u)"
    }

    /// Parses a leading number (int/decimal/unicode or a/b fraction) plus a trailing unit string.
    private static func parse(_ qty: String) -> (Double, String)? {
        let trimmed = qty.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        if let idx = trimmed.firstIndex(where: { unicodeFractions[$0] != nil }) {
            let frac = unicodeFractions[trimmed[idx]] ?? 0
            let whole = Double(trimmed[trimmed.startIndex..<idx].trimmingCharacters(in: .whitespaces)) ?? 0
            let unit = trimmed[trimmed.index(after: idx)...].trimmingCharacters(in: .whitespaces)
            return (whole + frac, unit)
        }
        if let m = trimmed.range(of: #"^\s*(\d+)\s*/\s*(\d+)"#, options: .regularExpression) {
            let parts = trimmed[m].components(separatedBy: "/").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            guard parts.count == 2, parts[1] != 0 else { return nil }
            let unit = String(trimmed[m.upperBound...]).trimmingCharacters(in: .whitespaces)
            return (parts[0] / parts[1], unit)
        }
        if let r = trimmed.range(of: #"^\d+\.?\d*"#, options: .regularExpression),
           let value = Double(trimmed[r]) {
            let unit = String(trimmed[r.upperBound...]).trimmingCharacters(in: .whitespaces)
            return (value, unit)
        }
        return nil
    }
}

// MARK: - Cooking session view

