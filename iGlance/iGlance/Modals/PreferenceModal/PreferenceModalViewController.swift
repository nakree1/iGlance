//
//  PreferenceModalViewController.swift
//  iGlance
//
//  Created by Dominik on 06.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import ServiceManagement
import CocoaLumberjack
import Sparkle

class PreferenceModalViewController: ModalViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var versionLabel: NSTextField!
    @IBOutlet private var autostartOnBootCheckbox: NSButton! {
        didSet {
            autostartOnBootCheckbox.state = (AppDelegate.userSettings.settings.autostartOnBoot) ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet private var logoImage: NSImageView!

    // MARK: -
    // MARK: Function Overrides

    override func viewWillAppear() {
        super.viewWillAppear()

        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            DDLogError("Could not retrieve the version of the app")
            return
        }
        versionLabel.stringValue = appVersion

        // add a callback to change the logo depending on the current theme
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(onThemeChange),
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )

        // add the correct logo image at startup
        changeLogo()
    }

    // MARK: -
    // MARK: Actions

    /**
     * This function is called when the 'Autostart on boot' checkbox is clicked.
     */
    @IBAction private func autoStartCheckboxChanged(_ sender: NSButton) {
        // set the auto start on boot user setting
        AppDelegate.userSettings.settings.autostartOnBoot = (sender.state == NSButton.StateValue.on)

        // enable the login item if the checkbox is activated
        if sender.state == NSButton.StateValue.on {
            if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, true) {
                DDLogError("Could not enable the iGlanceLauncher as login item")
            }

            return
        }

        // disable the login item if the checkbox is not activated
        if !SMLoginItemSetEnabled(LAUNCHER_BUNDLE_IDENTIFIER as CFString, false) {
            DDLogError("Could not deactive the iGlanceLauncher as login item")
        }
    }

    // MARK: -
    // MARK: Private Functions

    @objc
    private func onThemeChange() {
        changeLogo()
    }

    /**
     * Set the version label to the current app version.
     */
    private func setVersionLabel() {
        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            DDLogError("Could not retrieve the version of the app")
            return
        }
        versionLabel.stringValue = appVersion
    }

    /**
     * Sets the logo according to the current os theme.
     */
    private func changeLogo() {
        if ThemeManager.isDarkTheme() {
            logoImage.image = NSImage(named: "iGlance_logo_white")
        } else {
            logoImage.image = NSImage(named: "iGlance_logo_black")
        }
    }
}