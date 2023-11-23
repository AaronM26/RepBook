import SwiftUI

struct TodoListView: View {
    @State private var todoItems = [String]()
    @State private var newItemTitle = ""

    var body: some View {
        VStack {
            TextField("Add new item", text: $newItemTitle, onCommit: {
                addItem()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            List {
                ForEach(todoItems, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        Button(action: {
                            removeItem(item: item)
                        }, label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        })
                    }
                }
            }
        }
        .navigationTitle("To-do List")
    }

    private func addItem() {
        if !newItemTitle.isEmpty {
            todoItems.append(newItemTitle)
            newItemTitle = ""
        }
    }

    private func removeItem(item: String) {
        if let index = todoItems.firstIndex(of: item) {
            todoItems.remove(at: index)
        }
    }
}

