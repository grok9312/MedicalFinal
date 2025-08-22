import SwiftUI

struct MedicalRecordView: View {

    // 🔴 把原本複雜的初始化，改成一個空的陣列
    // 這樣可以 100% 解決編譯問題
    @State private var appointments: [Appointment] = []
    @State private var medicalRecords: [MedicalRecord] = []
    
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            // ... body 裡面的程式碼 ...
        }
        // 👇 我們把範例資料放到 .onAppear 修飾符裡面
        .onAppear {
            // 這個 onAppear 會在畫面第一次出現時執行
            // 在這裡才把範例資料加進去
            
            // 如果列表是空的，才加入範例資料
            if medicalRecords.isEmpty {
                let sampleRecord = MedicalRecord(hospital: "台大醫院", therapistName: "陳治療師", affectedPart: "左膝", treatmentContent: "物理治療", doctorsOrders: "每日熱敷")
                medicalRecords.append(sampleRecord)
            }
            
            if appointments.isEmpty {
                let sampleAppointment = Appointment(clinicName: "復興診所", therapistName: "王醫師", appointmentTime: Date())
                appointments.append(sampleAppointment)
            }
        }
    }
}
