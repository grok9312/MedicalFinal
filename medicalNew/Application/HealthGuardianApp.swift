// File: HealthGuardian/Application/HealthGuardianApp.swift
import SwiftUI

@main
struct HealthGuardianApp: App {
    @AppStorage("hasSeenWelcomeView") private var hasSeenWelcomeView: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenWelcomeView {
                // 如果使用者已经看过欢迎页 (hasSeenWelcomeView 为 true)，
                // 就直接显示主画面。
                ContentView()
            } else {
                // 否则 (第一次打开 App)，就显示欢迎页。
                // 我们需要将 hasSeenWelcomeView 的「控制权」(@Binding) 传递给 WelcomeView，
                // 这样 WelcomeView 里的按钮才能修改这个值。
                WelcomeView(hasSeenWelcomeView: $hasSeenWelcomeView)
            }
        }
    }
}
