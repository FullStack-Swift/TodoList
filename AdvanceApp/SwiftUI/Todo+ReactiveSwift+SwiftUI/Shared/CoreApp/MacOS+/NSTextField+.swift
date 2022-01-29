import SwiftUI

extension NSTextField {
  open override var focusRingType: NSFocusRingType {
    get { .none }
    set { }
  }
}
