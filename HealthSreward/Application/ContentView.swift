// File: HealthGuardian/Application/ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MedicalRecordView()
                .tabItem {
                    Label("醫療紀錄", systemImage: "heart.text.square.fill")
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
    }
}
