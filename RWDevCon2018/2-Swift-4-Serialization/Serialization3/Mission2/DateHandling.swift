// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation

extension DateFormatter {
  // Handles dates of the form "2018-04-07"
  public static let yearMonthDay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  // Handles dates of the form "2018-02-22T23:35:48.945-0800"
  public static let iso8601Milliseconds: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  // Handles dates of the form "2018-02-22T23:35:48-0800"
  public static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

public
func dateStringDecode<C>(forKey key: C.Key, from container: C, with formatters: DateFormatter...) throws -> Date
  where C: KeyedDecodingContainerProtocol {
    let dateString = try container.decode(String.self, forKey: key)

    for formatter in formatters {
      if let date = formatter.date(from: dateString) {
        return date
      }
    }
    throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: dateString)
}
