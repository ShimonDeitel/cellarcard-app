import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: BottleEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    Button(action: { editingEntry = entry }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.name)").font(Theme.headingFont)
                            Text("\(entry.vintage)").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                    .buttonStyle(.plain)
                }
                .onDelete(perform: store.delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Cellar Card")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if store.canAddMore {
                            showingAddSheet = true
                        } else {
                            showingPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .overlay {
                if store.entries.isEmpty {
                    ContentUnavailableView("No Bottles Yet", systemImage: "tray", description: Text("Tap + to add your first bottle."))
                }
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    let existing: BottleEntry?
    let onSave: (BottleEntry) -> Void

    @State private var name: String
    @State private var vintage: String
    @State private var drinkByYear: String
    @State private var notes: String

    init(entry: BottleEntry?, onSave: @escaping (BottleEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _name = State(initialValue: entry?.name ?? "")
        _vintage = State(initialValue: entry?.vintage ?? "")
        _drinkByYear = State(initialValue: entry?.drinkByYear ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_nameField")
                TextField("Vintage", text: $vintage)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_vintageField")
                TextField("DrinkByYear", text: $drinkByYear)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_drinkByYearField")
                TextField("Notes", text: $notes)
                    .focused($isFocused)
                    .accessibilityIdentifier("form_notesField")
            }
            .navigationTitle(existing == nil ? "Add Bottle" : "Edit Bottle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
    }

    private func save() {
        let id = existing?.id ?? UUID()
        let entry = BottleEntry(id: id, name: name, vintage: vintage, drinkByYear: drinkByYear, notes: notes)
        onSave(entry)
    }
}
