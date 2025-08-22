// File: HealthGuardian/Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @State private var pushEnabled = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("個人化推播管理")) {
                    Toggle("啟用個人化提醒", isOn: $pushEnabled)
                        .onChange(of: pushEnabled) {
                            oldValue, newValue in
                            
                            if newValue {
                                print("提醒被啟用 (新值是 \(newValue))")
                            } else {
                                print("提醒被關閉 (新值是 \(newValue))")
                            }
                        }
                }

                Section(header: Text("Apple 小工具")) {
                     Text("您可以在主畫面長按，選擇「編輯主畫面」，並透過左上角的「+」將健康管家小工具加入畫面。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                 Section(header: Text("Apple 行事曆整合")) {
                     Button("立即同步預約至行事曆") {
                         // 在此呼叫 CalendarManager 進行同步
                         print("正在同步行事曆...")
                     }
                 }
                
                Section(header: Text("關於")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
