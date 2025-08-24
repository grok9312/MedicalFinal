import SwiftUI

struct AddOrEditRecordView: View {
    @Binding var record: MedicalRecord
    @Environment(\.dismiss) var dismiss
    
    var isAppointmentOnly: Bool
    
    // isEditing 的邏輯現在只用來判斷標題
    private var isEditing: Bool { !record.hospital.isEmpty }
    
    private var isFormValid: Bool {
        !record.hospital.isEmpty && !record.therapistName.isEmpty && !record.affectedPart.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("預約資訊").foregroundColor(.themeHighlight)) {
                    TextField("診所/醫院名稱", text: $record.hospital)
                    TextField("醫師/治療師姓名", text: $record.therapistName)
                    TextField("患部", text: $record.affectedPart)
                    DatePicker("預約時間", selection: $record.appointmentTime)
                        .tint(.themeHighlight)
                }

                // ✅ **核心修改**：只有在不是「純預約模式」時，才顯示這個區塊
                if !isAppointmentOnly {
                    Section(header: Text("看診紀錄").foregroundColor(.themeHighlight)) {
                        TextField("治療狀況", text: $record.treatmentContent)
                        
                        VStack(alignment: .leading) {
                            Text("醫囑:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $record.doctorsOrders)
                                .frame(height: 100)
                        }
                    }
                }
                
                Section {
                    Button(action: { dismiss() }) {
                        HStack {
                            Spacer()
                            Text("儲存")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.themeHighlight)
                }
            }
            // 標題會根據模式和狀態自動變化
            .navigationTitle(navigationTitleText())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 輔助函式，讓標題邏輯更清晰
    private func navigationTitleText() -> String {
        if isAppointmentOnly {
            return isEditing ? "編輯預約" : "新增預約"
        } else {
            return "記錄就診狀況"
        }
    }
}

// MARK: - Previews
struct AddOrEditRecordView_Previews: PreviewProvider {
    static var previews: some View {
        // 預覽「新增預約」模式
        AddOrEditRecordView(record: .constant(MedicalRecord()), isAppointmentOnly: true)
            .previewDisplayName("新增預約")
        
        // 預覽「記錄就診狀況」模式
        AddOrEditRecordView(record: .constant(MedicalRecord(hospital: "測試醫院")), isAppointmentOnly: false)
            .previewDisplayName("記錄就診狀況")
    }
}
