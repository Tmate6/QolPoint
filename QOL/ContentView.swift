//
//  ContentView.swift
//  QOL
//
//  Created by Mate Tohai on 2022. 11. 11..
//

import SwiftUI
import KeyboardShortcuts


// MARK: - Enum

enum windowState {
    case main
    case fileCreate
    case setup
    case getText
}

enum btnType: Int {
    case none = -1
    case folder = 0
    case command = 1
    case popup = 2
    case window = 3
    case shortcut = 4
    case custom = 5
}


// MARK: - Hashables

struct mainMenu: Hashable {
    let no: Character
    let image: String
    let text: String
}

struct button: Hashable {
    let no: Int
    let type: btnType
    var text: String
    let image: String
    let about: String?
    var info: String?
}


// MARK: - Btn-related

var allButtons: [button] = [
    // Command
    button(no: 1, type: .command, text: "Sleep", image: "sleep", about: "Sleeps mac"),
    button(no: 10, type: .command, text: "Sleep disp", image: "display", about: "Sleeps displays"),
    button(no: 6, type: .command, text: "Shut down", image: "power", about: "Shuts down mac"),
    button(no: 7, type: .command, text: "Restart", image: "repeat", about: "Restarts mac"),
    button(no: 9, type: .command, text: "Log out", image: "person", about: "Logs out of current user"),
    button(no: 2, type: .command, text: "New Finder", image: "macwindow.badge.plus", about: "Opens new finder window"),
    button(no: 3, type: .command, text: "Get Path", image: "location.viewfinder", about: "Copies active finder window's path to clipboard"),
    button(no: 4, type: .command, text: "Eject disks", image: "eject", about: "Ejects all available disks"),
    button(no: 5, type: .command, text: "Eject all", image: "eject.fill", about: "Force ejects all volumes"),
    button(no: 8, type: .command, text: "Empty bin", image: "trash", about: "Empties the trash folder"),
    button(no: 11, type: .command, text: "Terminal", image: "terminal", about: "Opens new terminal at active finder window"),
    // Popup
    button(no: 1, type: .popup, text: "New File", image: "doc.badge.plus", about: "Creates a new file at active finder window"),
    button(no: 2, type: .popup, text: "Wifi Pass", image: "wifi", about: "Displays current wifi network's password"),
    // Window
    button(no: 1, type: .window, text: "Settings", image: "gear", about: "Opens QolPoint settings")
]

var buttonSlides: [[button]] = loadBtns()

var noOfSlides: Int = 0


// MARK: - Setup/Helper

func commandAction(id: Int) {
    if id == 1 { // Sleep
        let _ = shell("pmset sleepnow")
    }
    if id == 2 { // New Window
        let _ = shell("osascript -e 'tell app \"Finder\" to make new Finder window'")
    }
    if id == 3 { // Get path
        var path = shell("osascript -e 'tell application \"Finder\"\nset temp to selection as alias list\nrepeat with i from 1 to length of temp\nset the_item to item i of temp\nset the_result to POSIX path of the_item\nreturn the_result\nend repeat\nend tell'")
        if path == "" {
            path = shell("osascript -e 'tell application \"Finder\" to return POSIX path of (target of window 1 as alias)'")
        }
        if path.contains("error") {
            path = String("/Users/" + NSUserName() + "/Desktop/")
        }
        let _ = shell("osascript -e 'set the clipboard to \"" + String(path) + "\"'")
    }
    if id == 4 { // Eject all
        let _ = shell("osascript -e 'tell application \"Finder\" to eject (every disk whose ejectable is true)'")
    }
    if id == 5 { // Force eject all
        let _ = shell("osascript -e 'tell application \"Finder\" to eject (every disk)'")
    }
    if id == 6 { // Shut down
        let _ = shell("osascript -e 'tell app \"System Events\" to shut down'")
    }
    if id == 7 { // Restart
        let _ = shell("osascript -e 'tell app \"System Events\" to restart'")
    }
    if id == 8 { // Empty trash
        let _ = shell("osascript -e 'tell application \"Finder\" to empty trash'")
    }
    if id == 9 { // Log out
        let _ = shell("osascript -e 'tell application \"System Events\"' -e 'log out' -e 'keystroke return' -e end")
    }
    if id == 10 { // Sleep disp
        let _ = shell("pmset displaysleepnow")
    }
    if id == 11 { // Terminal
        var path = shell("osascript -e 'tell application \"Finder\" to return POSIX path of (target of window 1 as alias)'")
        if path.contains("error") {
            path = String("/Users/" + NSUserName() + "/Desktop/")
        }
        print(shell("osascript -e 'tell application \"Terminal\" to activate (do script \"cd " + path + "\")'"))
    }
}

func loadBtns() -> [[button]] {
    noOfSlides = 0
    var buttonReturn: [[button]] = [[]]
    print(UserDefaults.standard.string(forKey: "defaultButtons")!)
    
    noOfSlides = 1
    for array in UserDefaults.standard.string(forKey: "defaultButtons")!.components(separatedBy: ":::") {
        if array == "" { buttonReturn.append([]) }
        var itemNo: Int = 0
        var returnSlide: [button] = []
        
        for item in array.components(separatedBy: ",,,") {
            if item == "" { continue }
            
            else if item.contains("***") {
                let itemInfoTransition = item.components(separatedBy: ";;;")
                let itemInfo = String(itemInfoTransition[1]).components(separatedBy: "***")
                returnSlide.append(button(no: Int(itemInfoTransition[0].dropLast())!, type: .shortcut, text: itemInfo[0], image: "link", about: "Opens a set path", info: itemInfo[1]))
            }
            
            else if item.contains("///") {
                let itemInfoTransition = item.components(separatedBy: ";;;")
                let itemInfo = String(itemInfoTransition[1]).components(separatedBy: "///")
                returnSlide.append(button(no: Int(itemInfoTransition[0].dropLast())!, type: .custom, text: itemInfo[0], image: "terminal", about: "Executes a custom command", info: itemInfo[1]))
            }
            
            else if item.contains(";;;") {
                let itemInfo = item.components(separatedBy: ";;;")
                returnSlide.append(button(no: noOfSlides, type: .folder, text: itemInfo[1], image: "folder", about: nil))
                noOfSlides += 1
            }
            
            else {
                returnSlide.append(allButtons[allButtons.firstIndex(where: { String(String($0.no) + String($0.type.rawValue)) == item }) ?? 0 ])
            }
            itemNo += 1
        }
        
        if buttonReturn == [[]] {
            print("buttonReturn == [[]]")
            buttonReturn = [returnSlide]
        }
        else {
            print("else")
            buttonReturn.append(returnSlide)
        }
        
    }
    print("Slides" + String(noOfSlides))
    return buttonReturn
}

func changeSlide(slide: Int, changeTo: [button]) {
    buttonSlides[slide] = changeTo
}

struct ContentView: View {
    @Binding var currWinState: windowState
    
    @Binding var buttons: [button]
    
    @Binding var displayString: String
    
    var body: some View {
        switch currWinState {
        case .main:
            withAnimation {
                mainView(currWinState: $currWinState, buttons: $buttons, displayString: $displayString)
                    .navigationTitle("QolPoint")
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification), perform: { _ in
                        NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.closeButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    })
            }
        case .fileCreate:
            withAnimation {
                fileCreateView(currWinState: $currWinState)
                    .navigationTitle("QolPoint")
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification), perform: { _ in
                        NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.closeButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    })
            }
        case .setup:
            withAnimation {
                setupView(currWinState: $currWinState, buttons: $buttons)
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification), perform: { _ in
                        NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.closeButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    })
                /*setupViewPreview()
                    .edgesIgnoringSafeArea(.vertical)*/
            }
        case .getText:
            withAnimation {
                getTextView(currWinState: $currWinState, text: displayString)
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification), perform: { _ in
                        NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.closeButton)?.isHidden = true
                        NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    })
            }
        }
    }
}

func checkForCharacters(input: String) -> Bool {
    if input.contains(":::") || input.contains(",,,") || input.contains("***") || input.contains("///") || input.contains(";;;") { return true }
    else { return false }
}


// MARK: - Main Views

func buttonHandler(option: button, currSlide: [button]) -> (windowState, [button], String) {
    if option.type == .popup {
        if option.no == 1 {
            return (.fileCreate, currSlide, "")
        }
        if option.no == 2 {
            let wifiName = shell("/Sy*/L*/Priv*/Apple8*/V*/C*/R*/airport -I | awk '/ SSID:/ {print $2}'")
            if wifiName != "" {
                let wifiPassword = shell("security find-generic-password -wa \"" + wifiName.dropLast() + "\"")
                return (.getText, currSlide, wifiPassword)
            }
        }
    }
    
    else if option.type == .window {
        if option.no == 1 {
            return (.setup, currSlide, "")
        }
    }
    
    else if option.type == .folder {
        print(option.no)
        return (.main, buttonSlides[option.no], "")
    }
    
    else if option.type == .command {
        NSApp.hide(nil)
        commandAction(id: Int(exactly: option.no)!)
    }
    
    else if option.type == .shortcut {
        NSApp.hide(nil)
        let infoChange = String(option.info ?? ".").split(separator: " ")
        var optionInfo: String = ""
        
        for option in infoChange {
            optionInfo += option
            optionInfo += "\\ "
        }
        optionInfo.removeLast()
        let _ = shell("open " + (optionInfo))
    }
    
    else if option.type == .custom {
        NSApp.hide(nil)
        let _ = shell(option.info ?? "")
    }
    
    return (.main, currSlide, "")
}

struct mainView: View {
    @State private var textOpacities: [button: Double] = [:]
    
    @Binding var currWinState: windowState
    
    @Binding var buttons: [button]
    @Binding var displayString: String
    
    @State private var fadeTime: Double = UserDefaults.standard.double(forKey: "fadeTime")
    
    var body: some View {
        HSplitView {
            HStack {
                if buttonSlides[0] != buttons {
                    GroupBox {
                        HStack {
                            VStack {
                                Image(systemName: "arrowshape.left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30.0, height: 30)
                                    .padding(.all, 3.0)
                                
                                Text("Back")
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .padding([.leading, .bottom, .trailing], 1.0)
                                    .frame(width: 50)
                                    .font(/*@START_MENU_TOKEN@*/.callout/*@END_MENU_TOKEN@*/)
                            }
                        }
                    }
                    .onTapGesture {
                        buttons = buttonSlides[0]
                    }
                    .frame(width: 57)
                }
                ForEach(buttons, id: \.self) { option in
                    if option.no != 0 {
                        VStack {
                            Spacer()
                            GroupBox {
                                ZStack {
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Text(String(buttons.firstIndex(where: { $0.no == option.no && $0.type == option.type })! + 1))
                                                .padding(1)
                                                .padding(.trailing, 2)
                                                .opacity(textOpacities[option] ?? 1)
                                                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                                                    self.textOpacities[option] = 1.0
                                                    withAnimation(.easeOut(duration: fadeTime)) {
                                                        self.textOpacities[option] = 0.0
                                                    }
                                                }
                                                .onAppear {
                                                    self.textOpacities[option] = 1.0
                                                    withAnimation(.easeOut(duration: fadeTime)) {
                                                        self.textOpacities[option] = 0.0
                                                    }
                                                }
                                            Spacer()
                                        }
                                    }
                                    VStack {
                                        Image(systemName: option.image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30.0, height: 30)
                                            .padding(.all, 3.0)
                                        
                                        Text(option.text)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.center)
                                            .padding([.leading, .bottom, .trailing], 1.0)
                                            .frame(width: 73)
                                            .font(/*@START_MENU_TOKEN@*/.callout/*@END_MENU_TOKEN@*/)
                                        
                                    }
                                }
                            }
                            .onHover { over in
                                if over {
                                    self.textOpacities[option] = 1.0
                                } else {
                                    withAnimation(.easeOut(duration: fadeTime)) {
                                        self.textOpacities[option] = 0.0
                                    }
                                }
                            }
                            .onTapGesture {
                                (currWinState, buttons, displayString) = buttonHandler(option: option, currSlide: buttons)
                            }
                            .frame(width: 80)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.all, 10.0)
            .frame(height: 98)
            .background(VisualEffect().ignoresSafeArea())
            .edgesIgnoringSafeArea(.vertical)
            
        }
        .frame(height: 58)
    }
}

struct fileCreateView: View {
    @Binding var currWinState: windowState
    
    var path: String = shell("osascript -e 'tell application \"Finder\" to return POSIX path of (target of window 1 as alias)'")
    var errorRetruned = false
    
    init(currWinState: Binding<windowState>) {
        self._currWinState = currWinState
        if path.contains("error") {
            path = String("Users/" + NSUserName() + "/Desktop/")
            errorRetruned = true
        }
    }
    
    @State var input = ""
    
    
    @State var backImage: String = "arrowtriangle.backward"
    
    var body: some View {
        HSplitView {
            VStack {
                HStack {
                    Image(systemName: backImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onHover {hover in
                            if hover {
                                withAnimation(.linear(duration: 0.2)) {
                                    backImage = "arrowtriangle.backward.fill"
                                }
                            }
                            else {
                                withAnimation(.linear(duration: 0.2)) {
                                    backImage = "arrowtriangle.backward"
                                }
                            }
                        }
                        .frame(width: 20, height: 19)
                        .padding([.top, .bottom, .trailing], 1)
                        .onTapGesture {
                            currWinState = .main
                        }
                    
                    TextField(String(path), text: $input)
                        .padding(.trailing, 1.0)
                        .onSubmit {
                            if !checkForCharacters(input: String(path)) {
                                if errorRetruned {
                                    FileManager.default.createFile(atPath: path + input, contents: nil)
                                    NSWorkspace.shared.open(URL(fileURLWithPath: path + input))
                                    currWinState = .main
                                    NSApp.hide(nil)
                                }
                                else {
                                    FileManager.default.createFile(atPath: path.dropLast() + input, contents: nil)
                                    NSWorkspace.shared.open(URL(fileURLWithPath: path.dropLast() + input))
                                    currWinState = .main
                                    NSApp.hide(nil)
                                }
                            }
                        }
                }
            }
            .padding(.all, 10.0)
            .frame(height: 40)
            .background(VisualEffect().ignoresSafeArea())
            .edgesIgnoringSafeArea(.vertical)
        }
        .frame(height: 10)
    }
}

struct getTextView: View {
    @Binding var currWinState: windowState
    
    @State var backImage: String = "arrowtriangle.backward"
    var text: String
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                ZStack {
                    HStack {
                        Image(systemName: backImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onHover {hover in
                                if hover {
                                    withAnimation(.linear(duration: 0.2)) {
                                        backImage = "arrowtriangle.backward.fill"
                                    }
                                }
                                else {
                                    withAnimation(.linear(duration: 0.2)) {
                                        backImage = "arrowtriangle.backward"
                                    }
                                }
                            }
                            .frame(width: 20, height: 19)
                            .padding([.top, .bottom, .trailing], 1)
                            .onTapGesture {
                                currWinState = .main
                            }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Text(text.dropLast())
                        .lineLimit(2)
                        .padding([.top, .leading, .trailing], 2)
                        .font(.title)
                        
                }
                .padding([.top, .leading, .trailing], 2)
                .padding(.bottom, -5.0)
                HStack {
                    GroupBox {
                        VStack {
                            Image(systemName: "doc.on.clipboard")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 10)
                                .padding(.all, 3.0)
                            
                            Text("Copy")
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .padding([.leading, .bottom, .trailing], 1.0)
                                .frame(width: 73)
                                .font(.callout)
                        }
                    }
                    .onTapGesture {
                        let _ = shell("osascript -e 'set the clipboard to \"" + text.dropLast() + "\"'")
                        currWinState = .main
                    }
                    /*GroupBox {
                        VStack {
                            Image(systemName: "square.and.arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 10)
                                .padding(.all, 3.0)
                            
                            Text("Paste")
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .padding([.leading, .bottom, .trailing], 1.0)
                                .frame(width: 73)
                                .font(/*@START_MENU_TOKEN@*/.callout/*@END_MENU_TOKEN@*/)
                        }
                    }*/
                }
                .padding(.top, -2)
                .padding([.leading, .bottom, .trailing], 2)
                .frame(minWidth: 200, minHeight: 70)
                Spacer()
            }
            .background(VisualEffect().ignoresSafeArea())
            .edgesIgnoringSafeArea(.top)
        }
        .frame(height: 80)
    }
}

// Button slides save to memory when back button is pressed - in this struct //

struct setupView: View {
    @Binding var currWinState: windowState
    @Binding var buttons: [button]
    @State var currOpt = 0
    
    let mainMenuItems: [mainMenu] = [
        .init(no: "0", image: "gear", text: "Main Settings"),
        .init(no: "1", image: "plus.app", text: "Manage Buttons"),
    ]
    
    @State var backImage: String = "arrowtriangle.backward"
    
    @State var itemsShownErrorAlert = false

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        HSplitView {
            VSplitView {
                ZStack {
                    HStack {
                        Image(systemName: backImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 19, height: 50)
                            .onHover {hover in
                                if hover {
                                    withAnimation(.linear(duration: 0.2)) {
                                        backImage = "arrowtriangle.backward.fill"
                                    }
                                }
                                else {
                                    withAnimation(.linear(duration: 0.2)) {
                                        backImage = "arrowtriangle.backward"
                                    }
                                }
                            } // Saving //
                            .onTapGesture {
                                buttons = buttonSlides[0]
                                let defaults = UserDefaults.standard
                                var buttonsSave: String = ""
                                
                                for array in buttonSlides {
                                    for item in array {
                                        buttonsSave += String(item.no) + String(item.type.rawValue)
                                        if item.type == .folder {
                                            buttonsSave += ";;;" + String(item.text)
                                        }
                                        if item.type == .shortcut {
                                            buttonsSave += ";;;" + String(item.text)
                                            buttonsSave += "***" + String(item.info ?? "Shortcut")
                                        }
                                        if item.type == .custom {
                                            buttonsSave += ";;;" + String(item.text)
                                            buttonsSave += "///" + String(item.info ?? "Custom")
                                        }
                                        buttonsSave += ",,,"
                                    }
                                    if array != [] {
                                        buttonsSave += ":::"
                                    }
                                }
                                
                                print(buttonsSave)
                                defaults.set(buttonsSave, forKey: "defaultButtons")
                                UserDefaults.standard.synchronize()
                                
                                print(buttonsSave)
                                if buttons.count <= 1 {
                                    if buttons.firstIndex(where: { $0.no == 0 }) == 0 {
                                        itemsShownErrorAlert = true
                                    }
                                    else {
                                        currWinState = .main
                                    }
                                }
                                else {
                                    for option in buttons {
                                        if option.no == 0 {
                                            let currSlide: Int = buttonSlides.firstIndex(of: buttons)!
                                            buttons.remove(at: buttons.firstIndex(where: { $0.no == 0 })!)
                                            buttonSlides[currSlide] = buttons
                                        }
                                    }
                                    currWinState = .main
                                }
                            }
                            .padding(.top, 19)
                            .padding(.leading, 10)
                            .edgesIgnoringSafeArea(.vertical)
                            .alert(isPresented: $itemsShownErrorAlert) {
                                    Alert(
                                        title: Text("Error - No buttons found"),
                                        message: Text("You must have atleast one button added to save.")
                                    )
                                }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        VStack {
                            Image("QolPoint_fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(minWidth: 300)
                                .padding(.top, 15)
                        }
                        Spacer()
                    }
                    .edgesIgnoringSafeArea(.vertical)
                }
                .background(VisualEffect().ignoresSafeArea())
                .frame(height: 60)
                    
                HSplitView {
                    ScrollView {
                        Spacer()
                            .frame(height: 10)
                        ForEach(mainMenuItems, id: \.self) { option in
                            HStack {
                                Image(systemName: option.image)
                                    .resizable()
                                    .aspectRatio(contentMode:ContentMode.fit)
                                    .padding(.leading, 1.0)
                                    .padding(.trailing, -5.0)
                                    .padding(5)
                                    .frame(width: 30, height: 30)
                                
                                Text(option.text)
                                Spacer()
                            }
                            .onTapGesture {currOpt = option.no.wholeNumberValue!}
                            .foregroundColor(currOpt == option.no.wholeNumberValue ?
                                             Color(colorScheme == .dark ? .white : .black) :
                                                Color(colorScheme == .dark ? .lightGray : .darkGray))
                            Divider()
                        }
                        
                        .padding(3)
                        Spacer()
                        Spacer()
                    }
                    .frame(width: 160)
                    .background(VisualEffect().ignoresSafeArea())
                    
                    VStack {
                        Spacer()
                        switch currOpt {
                        case 0:
                            mainSettingsView(buttons: $buttons)
                        default:
                            selectBtnView(buttons: $buttons, currSelectedSlide: buttonSlides.firstIndex(of: buttons)!)
                        }
                    }
                    .background(BackgroundStyle())
                }
            }
        }
        .padding(.bottom, -30)
        .frame(width: CGFloat(buttons.count)*91 > 364 ? CGFloat(buttons.count)*91 + 160 : 364 + 160, height: 600)
        .edgesIgnoringSafeArea(.vertical)
        .background(VisualEffect().ignoresSafeArea())
    }
}


// MARK: - Settings views

struct mainSettingsView: View {
    @Binding var buttons: [button]
    
    enum FocusField: Hashable {
        case field
        case noneFocused
      }
    
    @State var resetConfirmation = false
    @State var currWinState: windowState = .main
    
    @State var copiedToClipboard = false
    @State var buttonsImported = false
    
    @State var importButtonsInput: String = ""
    
    @State private var fadeTime: String = String(round(UserDefaults.standard.double(forKey: "fadeTime")*10)/10)
    
    let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
    
    var body: some View {
        VStack {
            Text("Main Shortcut")
                .fontWeight(.thin)
                .padding(1)
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
            
            HStack {
                KeyboardShortcuts.Recorder("", name: .toggleShortcut)
                    .controlSize(/*@START_MENU_TOKEN@*/.large/*@END_MENU_TOKEN@*/)
                    .background(BackgroundStyle())
            }
            Divider()
            VStack {
                HStack {
                    GroupBox {
                        Text(resetConfirmation ? "Confirm reset" : "Reset buttons")
                    }
                    .padding(3)
                    .onTapGesture {
                        if !resetConfirmation {
                            resetConfirmation = true
                        } else {
                            UserDefaults.standard.set("13:::", forKey: "defaultButtons")
                            buttonSlides = loadBtns()
                            buttons = buttonSlides[0]
                            resetConfirmation = false
                        }
                    }
                    
                    GroupBox {
                        Text(copiedToClipboard ? "Copied saves to clipboard" : "Copy button saves")
                    }
                    .padding(3)
                    .onTapGesture {
                        let _ = shell("osascript -e 'set the clipboard to \"" + String(UserDefaults.standard.string(forKey: "defaultButtons")!) + "\"'")
                        copiedToClipboard = true
                    }
                }
                HStack {
                    TextField("Paste button saves code here", text: $importButtonsInput)
                        .padding(3)
                    GroupBox {
                        Text(buttonsImported ? "Buttons imported" : "Import buttons")
                    }
                        .padding(3)
                        .onTapGesture {
                            let defaults = UserDefaults.standard
                            defaults.set(importButtonsInput, forKey: "defaultButtons")
                            UserDefaults.standard.synchronize()
                            buttonSlides = loadBtns()
                            buttonsImported = true
                        }
                }
                .padding(.horizontal)
            }
            Divider()
            HStack {
                Spacer()
                Text("Keybind fade duration")
                
                TextField("Seconds", text: $fadeTime)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: fadeTime) { newValue in
                                    let filtered = newValue.filter { allowedCharacters.contains($0.unicodeScalars.first!) }
                                    if filtered != newValue {
                                        self.fadeTime = filtered
                                    }
                                }
                                .onSubmit {
                                    UserDefaults.standard.set(round((Float(fadeTime) ?? 1.0)*10)/10, forKey: "fadeTime")
                                    UserDefaults.standard.synchronize()
                                }
                Spacer()
            }
            Divider()
            Spacer()
        }
    }
}

struct selectBtnView: View {
    @Binding var buttons: [button]
    
    @State var selectedObjectNo: String = "-1"
    @State var addNewMenu: Bool = false
    
    @State var selectedText: String = ""
    @State var selection: String = ""
    
    @State var deleteButtonValue: String = "-1"
    
    @State var currSelectedSlide: Int
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            HStack {
                if buttonSlides.firstIndex(of: buttons) != 0 {
                    GroupBox {
                        Image(systemName: "arrowtriangle.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 15)
                    }
                    .onTapGesture {
                        currSelectedSlide = 0
                        buttons = buttonSlides[0]
                    }
                    .padding(.bottom, -4.0)
                    .padding(.top, -1.0)
                    .padding(.leading, 8.0)
                }
                
                Spacer()
                
                GroupBox {
                    Image(systemName: "terminal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 15)
                }
                .onTapGesture {
                    var customBtnNo: Int = 1
                    for button in buttons {
                        if button.type == .custom {
                            customBtnNo += 1
                        }
                    }
                    buttons.append(button(no: customBtnNo, type: .custom, text: "Custom", image: "terminal", about: "Executes a custom command"))
                    buttonSlides[currSelectedSlide] = buttons
                    selectedObjectNo = String(customBtnNo) + "5"
                    selectedText = "Custom"
                }
                .padding(.bottom, -4.0)
                .padding(.top, -1.0)
                .padding(.trailing, -2.0)
                
                GroupBox {
                    Image(systemName: "link.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 15)
                }
                .onTapGesture {
                    var shortcutBtnNo: Int = 1
                    for button in buttons {
                        if button.type == .shortcut {
                            shortcutBtnNo += 1
                        }
                    }
                    buttons.append(button(no: shortcutBtnNo, type: .shortcut, text: "Shortcut", image: "link", about: "Opens a set path"))
                    buttonSlides[currSelectedSlide] = buttons
                    selectedObjectNo = String(shortcutBtnNo) + "4"
                    selectedText = "New shortcut"
                }
                .padding(.bottom, -4.0)
                .padding(.top, -1.0)
                .padding(.trailing, -2.0)
                
                GroupBox {
                    Image(systemName: "folder.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 15)
                }
                .onTapGesture {
                    buttons.append(button(no: noOfSlides, type: .folder, text: "folder", image: "folder", about: nil))
                    buttonSlides[currSelectedSlide] = buttons
                    buttonSlides.append([])
                    print(noOfSlides)
                    print(currSelectedSlide)
                    selectedObjectNo = String(noOfSlides) + "0"
                    noOfSlides += 1
                    selectedText = "folder"
                }
                .padding(.bottom, -4.0)
                .padding(.top, -1.0)
                .padding(.trailing, -2.0)
                
                GroupBox {
                    Image(systemName: "plus.app")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 15)
                }
                .onTapGesture {
                    if buttons.firstIndex(where: {$0.no == 0}) == nil {
                        buttons.append(button(no: 0, type: .none, text: "", image: "", about: nil))
                        buttonSlides[currSelectedSlide] = buttons
                        selectedObjectNo = "0-1"
                        selectedText = "None"
                    }
                }
                .padding(.bottom, -4.0)
                .padding(.top, -1.0)
                .padding(.trailing, 8.0)
            }
            .padding(.bottom, -4.0)
            HStack {
                Spacer()
                ForEach(buttons, id: \.self) { option in
                    VStack {
                        Spacer()
                        ZStack {
                            GroupBox {
                                HStack {
                                    VStack {
                                        Image(systemName: option.image == "" ? "questionmark.app.dashed" : option.image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30.0, height: 30)
                                            .padding(.all, 3.0)
                                        
                                        Text(option.text == "" ? "None" : option.text)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(1)
                                            .padding([.leading, .bottom, .trailing], 1.0)
                                            .frame(width: 73)
                                            .font(/*@START_MENU_TOKEN@*/.callout/*@END_MENU_TOKEN@*/)
                                    }
                                }
                            }
                            .foregroundColor(selectedObjectNo == String(option.no) + String(option.type.rawValue) ? .accentColor : deleteButtonValue == String(option.no) + String(option.type.rawValue) ? Color(colorScheme == .dark ? .white : .black) : Color(colorScheme == .dark ? .lightGray : .darkGray))
                            .onHover { hover in
                                if hover {
                                    deleteButtonValue = String(option.no) + String(option.type.rawValue)
                                }
                                else {
                                    deleteButtonValue = "-1"
                                }
                            }
                            .onTapGesture {
                                if selectedObjectNo == String(option.no) + String(option.type.rawValue) {
                                    let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo}) ?? 0
                                    buttons[currSelectedButton].text = selectedText
                                    buttonSlides[currSelectedSlide] = buttons
                                    selectedObjectNo = "-1"
                                }
                                else {
                                    selectedObjectNo = String(option.no) + String(option.type.rawValue)
                                    selectedText = option.text
                                }
                            }
                            .padding([.top, .leading, .trailing], 3)
                            HStack {
                                VStack {
                                    if deleteButtonValue == String(option.no) + String(option.type.rawValue) && buttons.count > 1 {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                            .onHover { hover in
                                                if hover {
                                                    deleteButtonValue = String(option.no) + String(option.type.rawValue)
                                                }
                                            }
                                            .onTapGesture {
                                                buttons.remove(at: buttons.firstIndex(where: { String(String($0.no) + String($0.type.rawValue))  ==  String(option.no) + String(option.type.rawValue) } )!)
                                                buttonSlides[currSelectedSlide] = buttons
                                                selectedObjectNo = "-1"
                                            }
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 80)
                    Spacer()
                }
            }
            .frame(height: 80)
            .padding(.bottom, -4.0)
            Divider()
            
            HStack {
                HStack {
                    if selectedObjectNo == "-1" {
                        Text("Settings will be editable here once an object is selected.")
                    }
                    else if selectedObjectNo.last == "0" {
                        HStack {
                            VStack {
                                GroupBox {
                                    let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo}) ?? 0
                                    Image(systemName: buttons[currSelectedButton].image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .padding(3)
                                    
                                    TextField("", text: $selectedText)
                                        .font(.title)
                                        .padding([.leading, .bottom, .trailing], 3.0)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .onSubmit {
                                            if checkForCharacters(input: selectedText) { selectedText = "Folder" }
                                            let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo}) ?? 0
                                            buttons[currSelectedButton].text = selectedText
                                            buttonSlides[currSelectedSlide] = buttons
                                        }
                                    Text("Press enter to save name")
                                        .padding(.bottom, 3.0)
                                }
                                GroupBox {
                                    Text("Edit Items")
                                }
                                .onTapGesture {
                                    var currSelectedSlideTransfer: String = selectedObjectNo
                                    selectedObjectNo = "-1"
                                    currSelectedSlideTransfer.removeLast()
                                    currSelectedSlide = Int(currSelectedSlideTransfer)!
                                    buttons = buttonSlides[currSelectedSlide]
                                }
                                Spacer()
                            }
                            .padding(.trailing, -3)
                        }
                        .padding(.horizontal, 7.0)
                    }
                    else if selectedObjectNo.last == "4"  {
                        ShortcutSelectHelperView(buttons: $buttons, selectedObjectNo: $selectedObjectNo, selectedText: $selectedText, currSelectedSlide: $currSelectedSlide)
                    }
                    else if selectedObjectNo.last == "5"  {
                        CustomSelectHelperView(buttons: $buttons, selectedObjectNo: $selectedObjectNo, selectedText: $selectedText, currSelectedSlide: $currSelectedSlide)
                    }
                    else {
                        ButtonSelectHelperView(buttons: $buttons, selectedObjectNo: $selectedObjectNo, selectedText: $selectedText, currSelectedSlide: $currSelectedSlide)
                    }
                }
            }
            .onTapGesture {
                DispatchQueue.main.async {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                }
            }
            .frame(height: 300)
            Divider()
            Spacer()
        }
        .padding(.trailing, 1.0)
    }
}


// MARK: - Setup Helper Views

struct ButtonSelectHelperView: View {
    @Binding var buttons: [button]
    @Binding var selectedObjectNo: String
    @Binding var selectedText: String
    @Binding var currSelectedSlide: Int
    
    var body: some View {
        HStack {
            VStack {
                GroupBox {
                    HStack {
                        Spacer()
                        VStack {
                            let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo} ) ?? 0
                            Image(systemName: buttons[currSelectedButton].image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .padding(3)
                            Text(selectedText)
                                .font(.title)
                                .padding([.leading, .bottom, .trailing], 3.0)
                        }
                        Spacer()
                    }
                }
                
                GroupBox {
                    let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo} ) ?? 0
                    HStack {
                        Text("Info")
                            .font(.title)
                            .padding([.leading, .bottom, .trailing], 3.0)
                        Spacer()
                    }
                    HStack {
                    Text(buttons[currSelectedButton].about ?? "")
                            .font(.headline)
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .bottom, .trailing], 3.0)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, -2)
            }
            .padding(.trailing, -2)
            
            GroupBox {
                List {
                    ForEach(allButtons, id: \.self) { button in
                        if buttons.firstIndex(where: { String(String($0.no) + String($0.type.rawValue)) == String(String(button.no) + String(button.type.rawValue)) }) == nil {
                            Group {
                                HStack {
                                    Image(systemName: button.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 21.0, height: 21.0)
                                    
                                    Text(button.text)
                                }
                            }
                            .onTapGesture {
                                print(selectedObjectNo)
                                buttons[buttons.firstIndex(where: { String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo }) ?? 0] = allButtons[allButtons.firstIndex(where: { String(String($0.no) + String($0.type.rawValue)) == String(String(button.no) + String(button.type.rawValue)) })!]
                                buttonSlides[currSelectedSlide] = buttons
                                selectedObjectNo = String(button.no) + String(button.type.rawValue)
                                selectedText = button.text
                            }
                            Divider()
                                .padding(.vertical, -2)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8.0)
    }
}

struct ShortcutSelectHelperView: View {
    @Binding var buttons: [button]
    @Binding var selectedObjectNo: String
    @Binding var selectedText: String
    @Binding var currSelectedSlide: Int
    
    var body: some View {
        HStack {
            VStack {
                GroupBox {
                    let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo} ) ?? 0
                    Image(systemName: buttons[currSelectedButton].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(3)
                    TextField("", text: $selectedText)
                        .font(.title)
                        .padding([.leading, .bottom, .trailing], 3.0)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onSubmit {
                            if checkForCharacters(input: selectedText) { selectedText = "Shortcut" }
                            let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo}) ?? 0
                            buttons[currSelectedButton].text = selectedText
                            buttonSlides[currSelectedSlide] = buttons
                        }
                    Text("Press enter to save name")
                        .padding(.bottom, 3.0)
                }
                
                GroupBox {
                    let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo} ) ?? 0
                    HStack {
                        Text("Info")
                            .font(.title)
                            .padding([.leading, .bottom, .trailing], 3.0)
                        Spacer()
                    }
                    HStack {
                    Text(buttons[currSelectedButton].about ?? "")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .bottom, .trailing], 3.0)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, -2)
                
            }
            .padding(.trailing, -2)
            
            GroupBox {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text("Drop file/app to open")
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                if let loadableProvider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) }) {
                    _ = loadableProvider.loadObject(ofClass: URL.self) { fileURL, _ in
                        if !checkForCharacters(input: fileURL!.path) {
                            let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo} ) ?? 0
                            
                            let splitPath = String(fileURL!.path).split(separator: "/")
                            
                            buttons[currSelectedButton].info = fileURL!.path
                            buttons[currSelectedButton].text = String(splitPath.last!)
                            selectedText = String(splitPath.last!)
                            buttonSlides[currSelectedSlide] = buttons
                            print(buttons[currSelectedButton].info!)
                        }
                    }
                    return true
                }
                return false
            }
            
        }
        .padding(.horizontal, 8.0)
    }
}

struct CustomSelectHelperView: View {
    @Binding var buttons: [button]
    @Binding var selectedObjectNo: String
    @Binding var selectedText: String
    @Binding var currSelectedSlide: Int
    
    @State var customCommand: String = ""
    
    var body: some View {
        HStack {
            VStack {
                GroupBox {
                    let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo} ) ?? 0
                    Image(systemName: buttons[currSelectedButton].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(3)
                    TextField("", text: $selectedText)
                        .font(.title)
                        .padding([.leading, .bottom, .trailing], 3.0)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onSubmit {
                            if checkForCharacters(input: selectedText) { selectedText = "Custom" }
                            let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo}) ?? 0
                            buttons[currSelectedButton].text = selectedText
                            buttonSlides[currSelectedSlide] = buttons
                        }
                    Text("Press enter to save name")
                        .padding(.bottom, 3.0)
                }
                
                GroupBox {
                    let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo} ) ?? 0
                    HStack {
                        Text("Info")
                            .font(.title)
                            .padding([.leading, .bottom, .trailing], 3.0)
                        Spacer()
                    }
                    HStack {
                    Text(buttons[currSelectedButton].about ?? "")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .bottom, .trailing], 3.0)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, -2)
            }
            .padding(.trailing, -2)
            
            GroupBox {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        TextField("", text: $customCommand, axis: .vertical)
                            .lineLimit(16...16)
                            .padding([.leading, .bottom, .trailing], 3.0)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onSubmit {
                                if checkForCharacters(input: customCommand) { customCommand = "_" }
                                let currSelectedButton: Int = buttons.firstIndex(where: {String(String($0.no) + String($0.type.rawValue)) == selectedObjectNo}) ?? 0
                                buttons[currSelectedButton].info = customCommand
                                buttonSlides[currSelectedSlide] = buttons
                            }
                        Spacer()
                    }
                    Spacer()
                }
            }
            
        }
        .padding(.horizontal, 8.0)
    }
}


// MARK: - Previes
/*
struct previewView: View {
    @State var customCommand: String = ""
    var body: some View {
        GroupBox {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text("Enter command to be executed here:")
                        .font(.title)
                    Spacer()
                    TextField("", text: $customCommand, axis: .vertical)
                        .lineLimit(10...10)
                        .padding([.leading, .bottom, .trailing], 3.0)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

@available(macOS 13.0, *)
struct ContentView_Previews: PreviewProvider {
    @State var placeholder: windowState = .setup
    @State var buttons = buttonSlides[0]
    static var previews: some View {
        previewView()
    }
}*/
