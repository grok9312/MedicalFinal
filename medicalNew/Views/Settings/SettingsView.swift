// File: HealthGuardian/Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @State private var pushEnabled = false

    var body: some View {
        // 建議使用 NavigationStack 取代舊的 NavigationView
        NavigationStack {
            Form {
                // ✅ 修改 Section Header 顏色
                Section {
                    Toggle("啟用個人化提醒", isOn: $pushEnabled)
                        // ✅ Toggle 的顏色會自動繼承 tint color
                        .onChange(of: pushEnabled) {
                            oldValue, newValue in
                            if newValue {
                                print("提醒被啟用 (新值是 \(newValue))")
                            } else {
                                print("提醒被關閉 (新值是 \(newValue))")
                            }
                        }
                } header: {
                    Text("個人化推播管理")
                        .foregroundColor(Color.themeHighlight) // <-- 修改點
                }

                Section {
                     Text("您可以在主畫面長按，選擇「編輯主畫面」，並透過左上角的「+」將健康管家小工具加入畫面。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Apple 小工具")
                        .foregroundColor(Color.themeHighlight) // <-- 修改點
                }

                 Section {
                     Button("立即同步預約至行事曆") {
                         // 在此呼叫 CalendarManager 進行同步
                         print("正在同步行事曆...")
                     }
                     // ✅ Button 的顏色也會自動繼承 tint color
                 } header: {
                     Text("Apple 行事曆整合")
                        .foregroundColor(Color.themeHighlight) // <-- 修改點
                 }
                
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("關於")
                        .foregroundColor(Color.themeHighlight) // <-- 修改點
                }
            }
            // .navigationTitle("設定") // <-- 1. 移除這一行
            .toolbar {
                // ✅ **核心修改**：新增 ToolbarItem 來自訂標題
                ToolbarItem(placement: .principal) {
                    Text("設定")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.themeHighlight) // <-- 2. 設定為您的主題色
                }
            }
        }
        // ✅ **核心修改**：將整個視圖的 tint 顏色設定為您的主題色
        // 這會統一改變 Toggle、Button 和返回按鈕的顏色
        .tint(Color.themeHighlight) // <-- 3. 新增這一行
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
