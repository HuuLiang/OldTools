import Foundation

extension String {

  func g_localize(fallback: String) -> String {
    let string = NSLocalizedString(self, tableName: "HLImagePickerLocalizable", bundle: Bundle.main, value: "", comment: "")
    return string == self ? fallback : string
  }
}
