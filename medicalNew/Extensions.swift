import SwiftUI

// MARK: - Helper Extensions

// 擴充 Color 類型，方便統一管理 App 的視覺風格和使用 Hex 色碼
extension Color {
    /// #e0e4eb - 一種淡雅的灰藍色，適合作為主要背景
    static let themeBackground = Color(hex: "#e0e4eb")
    
    /// #d6eeec - 一種柔和的淡青色，用於需要突出的元件背景，如日曆
    static let themeAccent = Color(hex: "#d6eeec")
    
    /// 一個較深的青色，用於需要強調的元素，如按鈕、當前日期等
    static let themeHighlight = Color(hex: "#5DB0A8")
    
    /// 主要文字顏色，提高可讀性
    static let themePrimaryText = Color.black.opacity(0.8)
    
    /// 次要文字顏色，用於輔助性文字
    static let themeSecondaryText = Color.gray
    
    /// 便利的 Color 擴充，可直接使用 Hex 色碼字串來建立顏色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 擴充 Date 類型，增加方便的輔助功能
extension Date {
    /// 回傳該日期的零點（午夜）
    var zerothHour: Date? {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)
    }
}
