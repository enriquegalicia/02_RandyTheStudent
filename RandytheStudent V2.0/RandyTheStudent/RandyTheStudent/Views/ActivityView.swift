//
//  ActivityView.swift
//  RandyTheStudent
//
//  Thin SwiftUI wrapper around UIActivityViewController (the standard share
//  sheet) — used to share exported CSV files (AirDrop, Mail, Files, "Copy",
//  save to Files, etc.) via a plain file URL, which is what makes the
//  recipient see an actual named ".csv" file rather than a lump of text.
//

import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update — the activity items are fixed at creation time.
    }
}
