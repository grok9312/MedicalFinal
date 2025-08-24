import SwiftUI
import PhotosUI // 導入 Apple 最新的 PhotosUI 框架

// MARK: - 1. UIKit -> SwiftUI Image Picker Bridge
// 這是 SwiftUI 使用系統照片選擇器的標準方法。

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1 // 只允許選擇一張照片
        config.filter = .images    // 只顯示圖片
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // 首先關閉選擇器
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    // 加載是異步操作，必須在主線程更新 UI
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}


// MARK: - 2. Add/Edit Form View

struct AddOrEditDocumentView: View {
    @Binding var document: MedicalDocument
    @Environment(\.dismiss) var dismiss
    
    @State private var showingImagePicker = false
    
    private var isFormValid: Bool { !document.name.isEmpty }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("文件資訊")) {
                    TextField("文件名稱 (例如：2025-08-23 收據)", text: $document.name)
                    Picker("文件類型", selection: $document.type) {
                        ForEach(DocumentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("附加圖片")) {
                    if let uiImage = document.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .cornerRadius(8)
                            .onTapGesture { // 允許點擊圖片來更換
                                showingImagePicker = true
                            }
                    }
                    
                    Button(document.image == nil ? "從相簿選擇圖片" : "更換圖片") {
                        showingImagePicker = true
                    }
                }
                
                Section {
                    Button("儲存") { dismiss() }
                    .disabled(!isFormValid)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(document.name.isEmpty ? "新增文件" : "編輯文件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .tint(Color.themeHighlight)
        // 當 showingImagePicker 為 true 時，彈出我們的 ImagePicker 橋接視圖
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $document.image)
        }
    }
}
