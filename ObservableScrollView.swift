//
//  ObservableScrollView.swift
//  PhotoRoute
//
//  Created by Manuel Roth on 09.02.23.
//

import SwiftUI

// Simple preference that observes a CGFloat.
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}

// A ScrollView wrapper that tracks scroll offset changes.
struct ObservableScrollView<Content>: View where Content : View {
    @Namespace var scrollSpace
    
    @Binding var rowIndex: Int
    private var rowHeight: CGFloat
    
  let content: (ScrollViewProxy) -> Content

    init(rowIndex: Binding<Int>, rowHeight: CGFloat, @ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
        _rowIndex = rowIndex
        self.rowHeight = rowHeight
        self.content = content
    }

  var body: some View {
    ScrollView {
      ScrollViewReader { proxy in
        content(proxy)
          .background(GeometryReader { geo in
              let offset = -geo.frame(in: .named(scrollSpace)).minY
              Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
          })
      }
    }
    .coordinateSpace(name: scrollSpace)
    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
        let index = Int((value + rowHeight) / rowHeight) - 1
        self.rowIndex = max(0, index)
    }
  }
}
