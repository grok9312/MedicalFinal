import SwiftUI

// App 唯一的資料模型，包含了預約和看診後的所有資訊
struct MedicalRecord: Identifiable, Hashable {
    let id: UUID
    var hospital: String        // 原來的 clinicName
    var therapistName: String
    var appointmentTime: Date
    var affectedPart: String
    
    // 以下是看診後才需要填寫的資訊
    var treatmentContent: String
    var doctorsOrders: String
    
    // 提供一個初始化方法，方便我們建立一個空的 record 或帶有預設值的 record
    init(id: UUID = UUID(), hospital: String = "", therapistName: String = "", appointmentTime: Date = Date(), affectedPart: String = "", treatmentContent: String = "", doctorsOrders: String = "") {
        self.id = id
        self.hospital = hospital
        self.therapistName = therapistName
        self.appointmentTime = appointmentTime
        self.affectedPart = affectedPart
        self.treatmentContent = treatmentContent
        self.doctorsOrders = doctorsOrders
    }
}

// 您專案中其他的資料模型可以保留
struct MedicalDocument: Identifiable {
    var id = UUID()
    var name: String
    var type: DocumentType
    
    // ✅ 用來直接儲存圖片資料。
    // UIImage? 比 Data 在 SwiftUI 中更容易直接顯示。
    var image: UIImage?
    
    // --- 手動實現 Hashable & Equatable ---
    // 告訴 Swift 在比較兩個 MedicalDocument 時，只需要比較它們的 id。
    // 這是必要的，因為 UIImage 本身不符合 Hashable 協議。
    static func == (lhs: MedicalDocument, rhs: MedicalDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    // 告訴 Swift 在計算 Hash 值時，也只需要考慮 id。
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum DocumentType: String, CaseIterable {
    case receipt = "收據"
    case leaflet = "仿單"
    case consultationSheet = "醫囑照會單"
    case treatmentSlip = "治療單"
    case diagnosisCertificate = "診斷證明書"
}
