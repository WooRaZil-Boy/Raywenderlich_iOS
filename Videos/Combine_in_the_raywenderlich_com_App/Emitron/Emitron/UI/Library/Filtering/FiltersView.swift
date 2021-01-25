// Copyright (c) 2019 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI

struct FiltersView: View {
  @ObservedObject var libraryRepository: LibraryRepository
  @ObservedObject var filters: Filters
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  //@ObservedObject은 SwiftUI framework 이지만, ObservableObject protocol은 Combine에 있다.
  //ObservableObject는 objectWillChange를 호출한다.
  //objectWillChange는 아무런 data를 내보내지 않고 절대로 실패하지 않는 단순한 notification이다.
  //ObservableObject 외부에서 해당 notification에 대한 subscription으로
  //ObservableObject 속성에 대한 일종의 query를 발생시킨다.
  //objectWillChange를 subscribe하는 것도 가능하지만, 일반적으로는 @ObservedObject를 사용한다.
  //해당 property wrapper를 사용하면 objectWillChange가 emit 됐을 때, View를 re-render한다.

  
  var body: some View {
    VStack {
      
      HStack(alignment: .center) {
        
        Rectangle()
          .frame(width: 27, height: 27, alignment: .center)
          .foregroundColor(.clear)
          .padding([.leading], 18)
        
        Spacer()
        
        Text(String.filters)
          .font(.uiTitle5)
          .foregroundColor(.titleText)
        
        Spacer()
        
        Button(action: {
          if Set(libraryRepository.nonPaginationParameters) != Set(filters.appliedParameters) {
            revertBackToPreviousFilters()
          }
          presentationMode.wrappedValue.dismiss()
        }) {
          Image.close
            .frame(width: 27, height: 27, alignment: .center)
            .padding(.trailing, 18)
            .foregroundColor(.iconButton)
        }
      }
      .padding(.top, 20)
      
      constructScrollView()
        .padding([.leading, .trailing, .top], 20)
      
      HStack {
        
        MainButtonView(title: "Reset Filters", type: .secondary(withArrow: false)) {
          filters.removeAll()
          libraryRepository.filters = filters
          presentationMode.wrappedValue.dismiss()
        }
        .padding([.trailing], 10)
        
        // TODO: Figure out how best to handle NOT updating filters, but seeing which ones SHOULD get updated to compare to
        // Which ones are currently being applied to the content listing
        applyFiltersButton()
      }
      .padding([.leading, .trailing, .bottom], 18)
    }
    .background(Color.backgroundColor)
  }
  
  private func constructScrollView() -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(filters.filterGroups, id: \.self) { filterGroup in
          constructFilterView(filterGroup: filterGroup)
        }
      }
        .padding([.bottom], 30)
    }
  }
  
  private func constructFilterView(filterGroup: FilterGroup) -> FiltersHeaderView {
    FiltersHeaderView(
      filterGroup: filterGroup,
      filters: filters,
      isExpanded: filterGroup.numApplied > 0
    )
  }
  
  private func applyFiltersButton() -> MainButtonView {
    let title = "Apply Filters"
    
    let buttonView = MainButtonView(title: title, type: .primary(withArrow: false)) {
      libraryRepository.filters = filters
      presentationMode.wrappedValue.dismiss()
    }
    
    return buttonView
  }
  
  private func revertBackToPreviousFilters() {
    // Update filters with the currentFilters on contentsMC, to keep them in sync (aka, remove them)
    
    // First, turn all applied off
    filters.applied.forEach { filter in
      filter.isOn = false
      filters.all.update(with: filter)
    }
    
    // Then, turn all the currentAppliedFilters things on
    libraryRepository.currentAppliedFilters.forEach { filter in
      filter.isOn = true
      filters.all.update(with: filter)
    }
  }
}
