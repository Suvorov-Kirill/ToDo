//
//  TaskListInteractor.swift
//  ToDo
//
//  Created by Kirill Suvorov on 20.07.2025.
//

import Foundation
import CoreData
import Speech
import AVFoundation

class TasksListInteractor {
    
    // --- Speech Recognition
        private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
        private let audioEngine = AVAudioEngine()
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?
        private var isListening = false

        func startSpeechRecognition(
            onResult: @escaping (String) -> Void,
            onStateChange: @escaping (Bool) -> Void
        ) {
            guard !isListening else { return }
            SFSpeechRecognizer.requestAuthorization { status in
                guard status == .authorized else {
                    onStateChange(false)
                    return
                }
                DispatchQueue.main.async {
                    self.isListening = true
                    onStateChange(true)
                    self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                    let node = self.audioEngine.inputNode
                    let format = node.outputFormat(forBus: 0)
                    node.removeTap(onBus: 0)
                    node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                        self.recognitionRequest?.append(buffer)
                    }
                    self.audioEngine.prepare()
                    try? self.audioEngine.start()
                    self.recognitionTask = self.speechRecognizer?.recognitionTask(with: self.recognitionRequest!) { result, error in
                        if let result = result {
                            onResult(result.bestTranscription.formattedString)
                            if result.isFinal {
                                self.stopSpeechRecognition()
                                onStateChange(false)
                            }
                        }
                        if error != nil {
                            self.stopSpeechRecognition()
                            onStateChange(false)
                        }
                    }
                }
            }
        }

        func stopSpeechRecognition() {
            guard isListening else { return }
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            recognitionRequest = nil
            recognitionTask = nil
            isListening = false
        }
    
    func fetchItems(context: NSManagedObjectContext) -> [Item] {
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]
        let result = try? context.fetch(request)
        return result ?? []
    }
    
    func searchItems(text: String, context: NSManagedObjectContext) -> [Item] {
        let request = Item.fetchRequest()
        if !text.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", text, text)
        }
        let result = try? context.fetch(request)
        return result ?? []
    }
    
    func toggleState(for item: Item, context: NSManagedObjectContext) {
        item.state.toggle()
        try? context.save()
    }
    
    func delete(item: Item, context: NSManagedObjectContext) {
        context.delete(item)
        try? context.save()
    }
    
    func deleteItems(at offsets: IndexSet, items: [Item], context: NSManagedObjectContext) {
        offsets.map { items[$0] }.forEach(context.delete)
        try? context.save()
    }
    
    func loadNetworkTodos() async throws -> [ToDoTask] {
        try await NetworkManager.shared.fetchRequest()
    }
    
    func isFirstLaunch() -> Bool {
        !UserDefaults.standard.bool(forKey: "didLoadTasksFromNetwork")
    }
    
    func setDidLoadTasksFlag() {
        UserDefaults.standard.set(true, forKey: "didLoadTasksFromNetwork")
    }
    
}
