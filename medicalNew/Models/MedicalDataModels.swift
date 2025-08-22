import SwiftUI

struct Appointment: Identifiable {
    let id = UUID()
    var clinicName: String
    var therapistName: String
    var appointmentTime: Date
}

struct MedicalRecord: Identifiable, Hashable {
    let id = UUID()
    var hospital: String
    var therapistName: String
    var affectedPart: String
    var treatmentContent: String
    var doctorsOrders: String
}

// 醫療文件 (為了簡化，先移除圖片相關部分)
struct MedicalDocument: Identifiable {
    var id = UUID()
    var name: String
    var type: DocumentType
}

// 文件類型
enum DocumentType: String, CaseIterable {
    case receipt = "收據"
    case leaflet = "仿單"
    case consultationSheet = "醫囑照會單"
    case treatmentSlip = "治療單"
    case diagnosisCertificate = "診斷證明書"
}
