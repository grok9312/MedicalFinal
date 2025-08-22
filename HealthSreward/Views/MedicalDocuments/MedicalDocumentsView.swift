// File: HealthGuardian/Views/MedicalDocuments/MedicalDocumentsView.swift
import SwiftUI

struct MedicalDocumentsView: View {
    // 範例資料
    @State private var documents: [MedicalDocument] = [
        .init(name: "2025-08-21 收據", type: .receipt),
        .init(name: "膝蓋X光診斷書", type: .diagnosisCertificate)
    ]

    var body: some View {
        NavigationView {
            List(documents) { doc in
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.accentColor)
                    VStack(alignment: .leading) {
                        Text(doc.name)
                        Text(doc.type.rawValue).font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("醫療文件")
            .toolbar {
                Button {
                    // 之後會在這裡加入拍照或選取照片的功能
                    print("新增文件按鈕被點擊")
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}


struct MedicalDocuments_Previews: PreviewProvider {
    static var previews: some View {
        MedicalDocumentsView()
    }
}
