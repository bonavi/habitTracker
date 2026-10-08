import SwiftUI

struct ColorGrid: View {
    @Binding var selection: Int

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 14) {
            ForEach(HabitColor.palette.indices, id: \.self) { index in
                Button {
                    selection = index
                } label: {
                    Circle()
                        .fill(HabitColor.palette[index])
                        .frame(width: 36, height: 36)
                        .padding(4)
                        .overlay {
                            if selection == index {
                                Circle().stroke(Color(.systemGray3), lineWidth: 3)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == index ? .isSelected : [])
            }
        }
        .padding(.vertical, 6)
    }
}
