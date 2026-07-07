import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var editingItem: GearItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.accent)
                        Text("No gear items yet")
                            .font(Theme.titleFont)
                            .foregroundStyle(.white)
                        Text("Tap + to add your first entry.")
                            .font(Theme.captionFont)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.itemName)
                                        .font(Theme.bodyFont.weight(.semibold))
                                        .foregroundStyle(.white)
                                    if !item.size.isEmpty {
                                        Text(item.size)
                                            .font(Theme.captionFont)
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.id)")
                            .listRowBackground(Theme.cardBackground)
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Babygear Registry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                EditItemView(item: nil) { newItem in
                    store.add(newItem)
                }
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    let item: GearItem?
    let onSave: (GearItem) -> Void

    @State private var field1: String = ""
    @State private var field2: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("ItemName") {
                    TextField("ItemName", text: $field1)
                        .accessibilityIdentifier("field1TextField")
                }
                Section("Size") {
                    TextField("Size", text: $field2)
                        .accessibilityIdentifier("field2TextField")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Gear Item" : "Edit Gear Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var new = item ?? GearItem(itemName: "", size: "")
                        new.itemName = field1
                        new.size = field2
                        onSave(new)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(field1.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    field1 = item.itemName
                    field2 = item.size
                }
            }
        }
    }
}
