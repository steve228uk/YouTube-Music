// Fastfile.swift
// Copyright (c) 2021 Tim Oliver
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

class Fastfile: LaneFile {
    /// The path to the changelog file
    var changelogPath: String { return "CHANGELOG.md" }

    /// The name of the temporary keychain where all of the
    /// signing credentials are stored
    var keychainName: String { return "GitHubActions" }

    /// The path to the app's Info.plist file
    var infoPlistPath: String { return environmentVariable(get: "INFO_PLIST_PATH") }

    /// The owner and name of this repository (eg octocat/repo)
    var repositoryName: String { return environmentVariable(get: "GITHUB_REPOSITORY") }

    /// The name of the final binary without the .app extension (eg MyApp.app)
    var binaryFileName: String { return environmentVariable(get: "BINARY_FILE_NAME") }

    /// Runs a lane that goes takes a provided version number,
    /// updates the project files with that version number, and then
    /// builds, signs and releases a new copy of the app under that version
    func releaseLane() {
        desc("Build, sign, notarize and release a new version of this macOS app")

        // Get the info we need from the environment
        let newVersion = getNewVersion(from: environmentVariable(get: "NEW_VERSION"))

        // Load the changelog text
        let changelogURL = URL(fileURLWithPath: changelogPath)
        guard var changelog = try? String(contentsOf: changelogURL) else {
            fatalError("Was unable to locate \(changelogPath)")
        }

        // From the changelog, get the latest changes, and the previous version
        guard let changelogChanges = parseChangelog(changelog) else {
            fatalError("Was unable to properly read CHANGELOG.md")
        }

        // Before we proceed, verify the new version provided is valid
        verifyNewVersion(newVersion, oldVersion: changelogChanges.previousVersion)

        // Install any needed CocoaPods dependencies
        cocoapods(cleanInstall: true, useBundleExec: true)

        // Make a temporary keychain to store our signing credentials
        setUpKeychain()

        // Install the Apple signing identity from GitHub secrets
        installSigningIdentity()

        // Download and build Markdown to HTML utility
        prepareInkUtility()

        // Bump the version in the Info.plist
        setInfoPlistValue(key: "CFBundleShortVersionString",
                          value: newVersion,
                          path: infoPlistPath)

        // Increment the build number in the Xcode project
        // (This is used by Sparkle to determine new versions)
        let newBuildNumber = incrementBuildNumber()

        // Build the app (All of the build settings are in the project)
        buildMacApp(codesigningIdentity: environmentVariable(get: "CODESIGN_IDENTITY"),
                    exportMethod: "developer-id")

        // Notarize and staple the app
        notarize(package: "\(binaryFileName).app",
                 username: environmentVariable(get: "AC_NOTARIZE_EMAIL"),
                 ascProvider: environmentVariable(get: "AC_NOTARIZE_TEAM"),
                 verbose: true)

        // Set up a formatted file name for the app name, and an escaped variant
        let formattedAppName = binaryFileName.replacingOccurrences(of: " ", with: "-")
        let escapedAppName = binaryFileName.replacingOccurrences(of: " ", with: "\\ ")
        let archiveName = "\(formattedAppName)-\(newVersion).zip"

        // Generate the final ZIP for the build
        sh(command: "ditto -c -k --sequesterRsrc --keepParent \(escapedAppName).app \(archiveName)",
           log: false)

        // Generate the Sparkle app cast for this new version
        do {
            try updateAppCast(fileName: archiveName,
                              newBuildNumber: newBuildNumber,
                              newVersion: newVersion,
                              changes: changelogChanges.changes)
        } catch { fatalError("Unable to update Appcast.xml (\(error))") }

        // Update the CHANGELOG
        do { try updateChanglog(&changelog, newVersion: newVersion) }
        catch { fatalError("Unable to update Changelog \(error)") }

        // Commit all of the files we changed
        gitCommit(path: [infoPlistPath,
                         "CHANGELOG.md", "Appcast.xml", "*.pbxproj"],
                  message: "Release version \(newVersion)! 🎉")

        // Make a tag for this release
        addGitTag(tag: newVersion)

        // Push to remote
        pushToGitRemote()

        // Push GitHub Release
        setGithubRelease(repositoryName: repositoryName,
                         tagName: newVersion,
                         name: newVersion,
                         description: formattedReleaseChanges(changelogChanges.changes),
                         uploadAssets: [archiveName])

        // Generate a SHA-256 hash of the artifact and also expose that
        let shaHash = sh(command: "shasum -a 256 \(archiveName) | awk '{ print $1 }'",
                         log: false).trimmingCharacters(in: .whitespacesAndNewlines)

        // Expose the archive file name to GitHub Actions so we can access it in subsequent steps
        sh(command: "echo \"artifact_name=\(archiveName)\" >> $GITHUB_ENV", log: false)
        sh(command: "echo \"artifact_hash=\(shaHash)\" >> $GITHUB_ENV", log: false)
	}
}

extension Fastfile {

    /// Parse the new version out of the environment variable
    func getNewVersion(from string: String)-> String {
        // Run a regex to extract just the version number (In case they prefixed v at the front)
        guard let range = string.ranges(for: "([0-9]+\\.[0-9]+\\.[0-9]+)")?.first else {
            fatalError("A valid version number wasn't provided (eg '1.0.0')")
        }

        return String(string[Range(range, in: string)!])
    }

    /// Verify the version provided is in a valid format
    func verifyNewVersion(_ newVersion: String, oldVersion: String) {
        // Check a tag doesn't already exist
        if gitTagExists(tag: newVersion) {
            fatalError("Tag for version \(newVersion) already exists")
        }

        // Check this version is actually higher than the older version
        if newVersion.compare(oldVersion, options: .numeric) != .orderedDescending {
            fatalError("New version \(newVersion) was not higher than older version \(oldVersion)")
        }
    }

    /// Create a temporary keychain to store the signing credentials
    func setUpKeychain() {
        // Delete the keychain if it already exists
        let keychainURL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Keychains/\(keychainName)-db")
        if FileManager.default.fileExists(atPath: keychainURL.path) {
            deleteKeychain(name: keychainName)
        }

        // Create the new keychain
        createKeychain(name: keychainName,
                       password: environmentVariable(get: "MATCH_KEYCHAIN_PASSWORD"),
                       defaultKeychain: true,
                       unlock: true,
                       timeout: 600, // 10 minutes
                       lockAfterTimeout: false,
                       requireCreate: true)
    }

    /// Extract the signing identity from GitHub secrets and install it in our keychain
    func installSigningIdentity() {
        // Decode the signing cert from GitHub secrets
        let certificateString = environmentVariable(get: "SIGNING_CERT")
        guard let data = Data(base64Encoded: certificateString, options: .ignoreUnknownCharacters),
              data.count > 0 else {
            fatalError("Was unable to decode signing certificate")
        }

        // Save the decoded certificate to disk
        let certificateURL = URL(fileURLWithPath: "Certificate.p12")
        do { try data.write(to: certificateURL) }
        catch { fatalError("Unable to save signing identity to disk") }

        // Import into the keychain
        importCertificate(certificatePath: "Certificate.p12",
                          certificatePassword: environmentVariable(get: "SIGNING_CERT_PASSWORD"),
                          keychainName: "\(keychainName)-db",
                          keychainPassword: environmentVariable(get: "MATCH_KEYCHAIN_PASSWORD"))
    }

    /// In order to convert Markdown to HTML, download and build a copy
    /// of John Sundell's Ink library, and build a copy.
    func prepareInkUtility() {
        // Clone the repo, and build it
        sh(command: "git clone https://github.com/johnsundell/Ink.git;cd Ink; make; cd ..",
           log: false)
    }

    /// Take the changelog and extract the information we need to push
    /// a new release (mainly the unreleased changes, and the last released version)
    /// - Parameter changelog: The complete changelog loaded from disk
    /// - Returns: A tuple containing the unreleased text as markdown, and the previous version
    func parseChangelog(_ changelog: String) -> (changes: String, previousVersion: String)? {
        // Create a regular expression that extracts everything between the
        // '[Unreleased]' and the previous version, as well as the previous version
        guard let ranges = changelog.ranges(for: "## \\[Unreleased\\](.*?)## \\[([0-9]+\\.[0-9]+\\.[0-9]+)\\]"),
              ranges.count > 1 else {  return nil }

        // Extract the changes, and trim outer white space
        let changes = String(changelog[Range(ranges[0], in: changelog)!])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Extract the previous version number
        let previousVersion = String(changelog[Range(ranges[1], in: changelog)!])

        // Return the two as a tuple
        return (changes: changes, previousVersion: previousVersion)
    }

    /// Update the Sparkle app cast file with a new entry for this version
    /// - Parameters:
    ///   - fileName: The name of the zip file on disk that will be distributed
    ///   - newVersion: The new version of the app
    ///   - changes: The changes in markdown as extracted from the changelog
    /// - Throws: Throws an error if any step of the process fails
    func updateAppCast(fileName: String,
                       newBuildNumber: String,
                       newVersion: String,
                       changes: String?) throws {
        // Load the appcast file and insert the string
        let appcastURL = URL(fileURLWithPath: "Appcast.xml")
        guard var appcast = try? String(contentsOf: appcastURL) else {
            throw "Unable to locate Appcast.xml"
        }

        // Work out where we need to inject this code before proceeding
        guard let range = appcast.ranges(for: "(.*?\\n)[ ]+<item>")?.first else {
            throw "Unable to parse Appcast.xml"
        }

        // Fetch the minimum supported version of macOS in this build
        let minimumSystemVersion = getInfoPlistValue(key: "LSMinimumSystemVersion",
                                                     path: "\(binaryFileName).app/Contents/Info.plist")


        // Sign the ZIP file with Sparkle's private key
        let sparkleKey = environmentVariable(get: "SPARKLE_PRIVATE_KEY")
        let signature = sh(command: "./Pods/Sparkle/bin/sign_update -s \(sparkleKey) \(fileName)",
                           log: false).trimmingCharacters(in: .whitespacesAndNewlines)

        // Save the changes to disk so we can pass the file as one element to Ink
        // (Otherwise we have to sanitize it against all of Bash's special characters)
        let changesFilename = "_changes.md"
        do {
            let sanitizedChanges = changes ?? "No changes listed for this version."
            try sanitizedChanges.write(toFile: changesFilename, atomically: true, encoding: .utf8)
        } catch {
            throw "Unable to save new changes from Changelog to disk"
        }

        // Convert the changes from markdown to HTML using Ink
        var htmlChanges = sh(command: "./Ink/.build/release/ink-cli \(changesFilename)",
                             log: false)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Prepend a stylesheet to make the release notes look more consistent
        htmlChanges = """
        <style>
            body { font-family: -apple-system, sans-serif; font-size: 0.9em; line-height: 150%; }
            h3 { font-size: 1.5em; margin-bottom: 0; font-weight: 700; }
            li { margin-bottom: 0.5em; }
        </style>
        """ + htmlChanges

        // Generate today's date in the appropriate format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let dateString = dateFormatter.string(from: Date())

        // Generate the item block for this app cast with all of our generated data
        let appcastItem = """
                <item>
                    <title>Version \(newVersion)</title>
                    <description>
                        <![CDATA[
                        \(htmlChanges)
                        ]]>
                    </description>
                    <pubDate>\(dateString)</pubDate>
                    <sparkle:minimumSystemVersion>\(minimumSystemVersion)</sparkle:minimumSystemVersion>
                    <enclosure url="https://github.com/\(repositoryName)/releases/download/\(newVersion)/\(fileName)"
                    sparkle:version="\(newBuildNumber)" sparkle:shortVersionString="\(newVersion)"
                    \(signature)
                    type="application/octet-stream"/>
                </item>\n
        """

        appcast.insert(contentsOf: appcastItem, at: appcast.index(appcast.startIndex, offsetBy: range.length))
        try appcast.write(to: appcastURL, atomically: true, encoding: .utf8)
    }

    func updateChanglog(_ changelog: inout String, newVersion: String) throws {
        //  Find the range of the unreleased block
        guard let unreleasedBlock = changelog.ranges(for: "(##\\s\\[Unreleased\\]\\n)")?.first else {
            throw "Could not find '## [Unreleased]' in Changelog"
        }

        // Calculate the current date and convert to string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        // Insert the new release number under it
        // e.g
        // ## [Unreleased]
        //
        // ## [1.0.0]
        changelog.insert(contentsOf: "\n## [\(newVersion)] - \(dateString)\n",
                         at: changelog.index(changelog.startIndex, offsetBy: NSMaxRange(unreleasedBlock)))

        // Update the links at the bottom of the changelog with the new version
        guard let linkRanges = changelog.ranges(for: "(\\[Unreleased\\]:\\s(.*\\/)([0-9]+\\.[0-9]+\\.[0-9]+)\\.\\.\\.HEAD)"),
              linkRanges.count == 3 else {
            fatalError("Unable to find footer links in Changelog")
        }
        // Get the previous version from the links (eg 1.0.6)
        let previousVersion = changelog[Range(linkRanges[2], in: changelog)!]

        // Get the base URL
        let baseURL = changelog[Range(linkRanges[1], in: changelog)!]

        // Insert a new entry below the unreleased block for the previous version
        changelog.insert(contentsOf: "[\(newVersion)]: \(baseURL)\(previousVersion)...\(newVersion)\n",
                         at: changelog.index(changelog.startIndex, offsetBy: NSMaxRange(linkRanges[0])))

        // Update the unreleased block with the new version
        // eg [Unreleased]: https://github.com/octocat/repo/compare/1.0.6...HEAD
        // to
        // [Unreleased]: https://github.com/octocat/repo/compare/1.1.0...HEAD
        changelog.replaceSubrange(Range(linkRanges[2], in: changelog)!, with: newVersion)

        // Write this new changelog back to disk
        try changelog.write(toFile: changelogPath, atomically: true, encoding: .utf8)
    }

    /// Formats the changes from the changelog for the notes section in GitHub Releeases
    /// - Parameter changes: The new changes that were extracted from the changelog
    /// - Returns: The formatted changes ready for GitHub Releases
    func formattedReleaseChanges(_ changes: String) -> String {
        // Extract the ID of the GitHub job running this flow, and attach it to the Release notes
        let domainName = environmentVariable(get: "GITHUB_SERVER_URL")
        let runID = environmentVariable(get: "GITHUB_RUN_ID")
        let buildJobURL = "\(domainName)/\(repositoryName)/actions/runs/\(runID)?check_suite_focus=true"
        return changes + "\n\n#\n\n###### [Release Workflow Job (#\(runID))](\(buildJobURL))"
    }
}

// MARK: - Regular Expression Extension -
extension String {
    /// Given a regular expression pattern, return an array
    /// of all of the ranges of the matching groups found
    /// - Parameter pattern: The regular expression to use
    /// - Returns: An array of ranges, or nil if none were found
    public func ranges(for pattern: String) -> [NSRange]? {
        // Cover the entire string when searching
        let stringRange = NSRange(location: 0, length: self.count)

        // Define the regular expression, explicitly including new line characters
        let regex = try! NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        )

        // Run the query, and verify at least one group was found
        guard let matches = regex.firstMatch(in: self, options: [], range: stringRange),
              matches.numberOfRanges > 1 else { return nil }

        // Convert the results to an array of ranges
        // (Skip the first as that is the matching block, and not a group)
        return (1..<matches.numberOfRanges).map { matches.range(at: $0) }
    }
}

// Enable throwing string errors
extension String: Error {}
