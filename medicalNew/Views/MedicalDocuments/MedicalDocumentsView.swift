import SwiftUI

struct MedicalDocumentsView: View {
    // 使用 @State 來儲存和觀察 documents 陣列的變化
    @State private var documents: [MedicalDocument] = [
        // 提供一些範例資料，使用 SF Symbols 作為預設圖片
        .init(name: "範例收據", type: .receipt, image: UIImage(systemName: "doc.text.image")),
        .init(name: "範例診斷書", type: .diagnosisCertificate, image: UIImage(systemName: "photo.artframe"))
    ]
    
    // 控制新增視窗 (sheet) 的顯示狀態
    @State private var showingAddSheet = false
    // 用於「新增」流程的臨時變數
    @State private var newDocument = MedicalDocument(name: "", type: .receipt, image: nil)

    var body: some View {
        NavigationStack {
            List {
                // 使用 ForEach($documents) 來獲得每個文件的綁定 ($doc)
                ForEach($documents) { $doc in
                    // NavigationLink 可以在點擊時，推入編輯視圖
                    NavigationLink(destination: AddOrEditDocumentView(document: $doc)) {
                        HStack(spacing: 15) {
                            // 根據是否有圖片，顯示縮圖或預設圖示
                            if let uiImage = doc.image {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .clipped() // 避免圖片超出圓角範圍
                            } else {
                                // 沒有圖片時的佔位圖示
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(doc.name)
                                    .fontWeight(.medium)
                                Text(doc.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteDocument) // 啟用滑動刪除
            }
            .toolbar {
                // ✅ **核心修改**：我們新增一個 ToolbarItem 來放置自訂的標題
                ToolbarItem(placement: .principal) {
                    Text("醫療文件")
                        .font(.headline) // 讓字體大小和系統樣式接近
                        .fontWeight(.bold)
                        .foregroundColor(Color.themeHighlight) // <-- 2. 設定為您的主題色
                }
                
                // 這是原本的 "+" 按鈕，我們把它放到 navigationBarTrailing 位置
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .tint(Color.themeHighlight) // 設定整個視圖的主題色
        .sheet(isPresented: $showingAddSheet, onDismiss: {
            // 當新增視窗關閉時，檢查使用者是否確實輸入了名稱
            if !newDocument.name.isEmpty {
                documents.append(newDocument)
            }
            // 無論是否儲存，都重置 newDocument 以備下次使用
            newDocument = MedicalDocument(name: "", type: .receipt, image: nil)
        }) {
            // 將對 newDocument 的綁定傳入，讓新增頁面去填寫它
            AddOrEditDocumentView(document: $newDocument)
        }
    }
    
    /// 用於處理 .onDelete 的輔助函式
    private func deleteDocument(at offsets: IndexSet) {
        documents.remove(atOffsets: offsets)
    }
}


// MARK: - Previews
struct MedicalDocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalDocumentsView()
    }
}
