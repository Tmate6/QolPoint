//
//  QOLApp.swift
//  QOL
//
//  Created by Mate Tohai on 2022. 11. 11..
//

import SwiftUI
import Foundation
import Cocoa
import HotKey
import KeyboardShortcuts

var windowIsHidden: Bool = true

extension KeyboardShortcuts.Name {
    static let toggleShortcut = Self("toggleShortcut", default: .init(.e, modifiers: [.command]))
}

class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationWillUpdate(_ notification: Notification) {
            DispatchQueue.main.async {
                let currentMainMenu = NSApplication.shared.mainMenu

                let removedMenus: [NSMenuItem?] = [currentMainMenu?.item(withTitle: "File"), currentMainMenu?.item(withTitle: "Edit"), currentMainMenu?.item(withTitle: "View"), currentMainMenu?.item(withTitle: "Window")]
                
                for menu in removedMenus {
                    if menu != nil {
                        NSApp.mainMenu?.removeItem(menu!)
                    }
                }
            }
        }
    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["defaultButtons" : "0"])
        
        let window = NSApplication.shared.windows.first!
        window.titlebarAppearsTransparent = true
        window.backgroundColor = .white
        window.standardWindowButton(.closeButton)!.isHidden = true
        window.standardWindowButton(.miniaturizeButton)!.isHidden = true
        window.standardWindowButton(.zoomButton)!.isHidden = true
        
        NSApp.hide(nil)
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            NSApp.hide(nil)
            return false
        }
    }
}

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


@available(macOS 13.0, *)
@main
struct QolApp: App {
    @StateObject private var appState = AppState()
    @State var windowContent: windowState = .main
    @State var screen = (getScreenWithMouse() ?? .main)
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(currWinState: $windowContent)
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
