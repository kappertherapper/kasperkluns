import Foundation

enum DateRangeType {
    case thisMonth
    case lastMonth
    case thisWeek
    case today
}

extension Calendar {
    func dateRange(for type: DateRangeType) -> (start: Date, end: Date)? {
        let now = Date()
        
        switch type {
        case .thisMonth:
            guard let start = self.date(from: dateComponents([.year, .month], from: now)),
                  let end = self.date(byAdding: DateComponents(month: 1, day: -1), to: start)
            else { return nil }
            return (start, end)
            
        case .lastMonth:
            guard let start = self.date(byAdding: .month, value: -1, to: now),
                  let startOfLast = self.date(from: dateComponents([.year, .month], from: start)),
                  let end = self.date(byAdding: DateComponents(month: 1, day: -1), to: startOfLast)
            else { return nil }
            return (startOfLast, end)
            
        case .thisWeek:
            guard let start = self.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
                  let end = self.date(byAdding: .day, value: 6, to: start)
            else { return nil }
            return (start, end)
            
        case .today:
            let start = startOfDay(for: now)
            guard let end = self.date(byAdding: .day, value: 1, to: start)
            else { return nil }
            return (start, end)
        }
    }
}
