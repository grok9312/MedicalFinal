// File: HealthGuardian/Application/ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MedicalRecordView()
                .tabItem {
                    Label("行事曆", systemImage: "heart.text.square.fill")
                }

            MedicalDocumentsView()
                .tabItem {
                    Label("醫療文件", systemImage: "doc.text.fill")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
        // ✅ **核心修改**：將 .tint() 修飾器應用在 TabView 上
        // 這會將「當前選中」的頁籤的圖示和文字顏色都設定為您的主題色。
        .tint(Color.themeHighlight) // <-- 新增這一行
    }
}


// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
