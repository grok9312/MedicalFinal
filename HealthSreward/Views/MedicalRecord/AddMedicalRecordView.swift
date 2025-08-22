// File: HealthGuardian/Views/MedicalRecord/AddMedicalRecordView.swift
import SwiftUI

struct AddMedicalRecordView: View {
    // 透過 @Binding，可以直接修改上一頁的 medicalRecords 陣列
    @Binding var records: [MedicalRecord]
    
    @Environment(\.dismiss) var dismiss

    @State private var hospital: String = ""
    @State private var affectedPart: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新增紀錄")) {
                    TextField("醫院", text: $hospital)
                    TextField("患部", text: $affectedPart)
                }
            }
            .navigationTitle("新增醫療紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        let newRecord = MedicalRecord(hospital: hospital, therapistName: "", affectedPart: affectedPart, treatmentContent: "", doctorsOrders: "")
                        records.insert(newRecord, at: 0) // 加到陣列最前面
                        dismiss()
                    }
                }
            }
        }
    }
}
