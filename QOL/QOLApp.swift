//
//  QOLApp.swift
//  QOL
//
//  Created by Mate Tohai on 2022. 11. 11..
//

import SwiftUI
import Foundation
import Cocoa
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleShortcut = Self("toggleShortcut", default: .init(.e, modifiers: [.command]))
}


// MARK: - Appdel

class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationWillUpdate(_ notification: Notification) {
            DispatchQueue.main.async {
                let currentMainMenu = NSApplication.shared.mainMenu

                let removedMenus: [NSMenuItem?] = [currentMainMenu?.item(withTitle: "File"), currentMainMenu?.item(withTitle: "View"), currentMainMenu?.item(withTitle: "Window")]
                
                for menu in removedMenus {
                    if menu != nil {
                        NSApp.mainMenu?.removeItem(menu!)
                    }
                }
            }
        }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSApplication.shared.windows.first!
        window.titlebarAppearsTransparent = true
        window.backgroundColor = .white
        window.standardWindowButton(.closeButton)!.isHidden = true
        window.standardWindowButton(.miniaturizeButton)!.isHidden = true
        window.standardWindowButton(.zoomButton)!.isHidden = true
        
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            NSApp.hide(nil)
            return false
        }
    }
}


// MARK: - Funcs

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    return output
}

struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
    func updateNSView(_ nsView: NSView, context: Context) { }
}

func getScreenWithMouse() -> NSScreen? {
    let mouseLocation = NSEvent.mouseLocation
    let screens = NSScreen.screens
    let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })

    return screenWithMouse
}


// MARK: - Main

@available(macOS 13.0, *)
@main
struct QolApp: App {
    @StateObject private var appState = AppState()
    @State var windowContent: windowState = .main
    @State var screen = (getScreenWithMouse() ?? .main)
    
    @State var buttonShortcut: Int = 0
    
    @State var buttons: [button] = buttonSlides[0]
    @State var displayString: String = ""
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(currWinState: $windowContent, buttons: $buttons, displayString: $displayString)
                .hostingWindowPosition(
                    vertical: .top,
                    horizontal: .center,
                    padding: 150,
                    screen: screen)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") { windowContent = .setup }
                    .keyboardShortcut(",")
            }
            CommandMenu("Buttons") {
                Button("Back") {
                    if windowContent == .main {
                        buttons = buttonSlides[0]
                    }
                }
                    .keyboardShortcut("0", modifiers: [])
                Button("Button 1") {
                    if windowContent == .main && buttons.indices.contains(0) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[0], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("1", modifiers: [])
                
                Button("Button 2") {
                    if windowContent == .main && buttons.indices.contains(1) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[1], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("2", modifiers: [])
                
                Button("Button 3") {
                    if windowContent == .main && buttons.indices.contains(2) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[2], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("3", modifiers: [])
                
                Button("Button 4") {
                    if windowContent == .main && buttons.indices.contains(3) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[3], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("4", modifiers: [])
                
                Button("Button 5") {
                    if windowContent == .main && buttons.indices.contains(4) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[4], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("5", modifiers: [])
                
                Button("Button 6") {
                    if windowContent == .main && buttons.indices.contains(5) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[5], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("6", modifiers: [])
                
                Button("Button 7") {
                    if windowContent == .main && buttons.indices.contains(6) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[6], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("7", modifiers: [])
                
                Button("Button 8") {
                    if windowContent == .main && buttons.indices.contains(7) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[7], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("8", modifiers: [])
                
                Button("Button 9") {
                    if windowContent == .main && buttons.indices.contains(8) {
                        (windowContent, buttons, displayString) = buttonHandler(option: buttons[8], currSlide: buttons)
                    }
                }
                    .keyboardShortcut("9", modifiers: [])
            }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    init() {
        KeyboardShortcuts.onKeyUp(for: .toggleShortcut) {
            if NSApp.isHidden {
                NSApp.unhide(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
            else {
                NSApp.hide(nil)
            }
        }
    }
}
