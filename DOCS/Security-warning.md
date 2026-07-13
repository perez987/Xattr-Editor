## Security warning when opening the app

The conditions Apple imposes to maintain user security and privacy are becoming increasingly strict. This, of course, benefits users but it has drawbacks.

When a file is downloaded from the Internet, an extended attribute named `com.apple.quarantine` is added to it so that Gatekeeper requests confirmation before executing them.

In pre-Sequoia versions, Gatekeeper warning for files downloaded from the Internet had a simple solution: accepting the warning when opening the file or right-clicking on the file -> “Open”.

But in Sequoia and Tahoe, the warning is more serious and might upset the user. It may display this message:
<br>`The application is damaged and cannot be opened.`<br>
Or this one:
<br>`Could not verify that Download Full Installer does not contain malicious software.`<br>
With the recommendation in both cases to move the file to the Trash.

This is the warning that appears when the app is not digitally signed or notarized by Apple; in which case, the warning is more benign, reminiscent of the pre-Sequoia versions.

Currently, an Apple Developer account is required to digitally sign or notarize Mac applications. However, many developers don't want to register with the Apple Developer Program, either because of the cost or because they develop small apps that are distributed for free.

This is the case with many of the apps we publish as amateurs, signed ad-hoc and not notarized. Although the source code for these types of applications is usually available and can be explored to determine if there are conditions that weaken security, this warning may raise some suspicions. 

Users who have Gatekeeper disabled will not see this warning. However, disabling Gatekeeper globally to run a single application is not a valid recommendation.

How to fix this?

### Option 1: Disable Gatekeeper (NOT RECOMMENDED)

1.- **Disable Gatekeeper:** Open the Terminal app on your Mac and run the following command: `sudo spctl —master-disable`:

- Note: in recent macOS versions, the argument `—master-disable` has been changed to `—global-disable`
- Go to "System Settings"->"Privacy & Security"->"Security" -> Allow applications from "Everywhere"
- Both arguments can revert this and enable Gatekeeper again:  `—master-enable`  `—global-enable`
- From this point on, downloaded apps will run without security prompts

2.- Download the latest release from the [Releases](https://github.com/perez987/icns-creator/releases) page.

2.- Move the unzipped `Icns Creator.app` file to your Applications folder.

4.- Double-click the `Icns Creator.app` file to run it.

5.- You will be prompted with a warning that the app is from an unidentified developer. Click "Open”.

> Disabling Gatekeeper globally to run a single application is not a valid recommendation.

### Option 2: Without disabling Gatekeeper

#### 1.- System Settings >> Security and Privacy

First, go to `Privacy & Security` to see if there's a message about blocking the downloaded application with `Open Anyway `option. 

By clicking `Open Anyway`, macOS will ask again if you want to open the file and, if you answer yes, it will ask for the user password and open it.

This is the easiest way to fix it.

#### 2.- xattr command line tool

`xattr`handles extended attributes (*xattrs*), which are additional metadata attached to files and directories beyond standard information like name or size. This tool is built into macOS natively. With `xattr` you can remove the `com.apple.quarantine` attribute from any file downloaded from Internet and the task is quite simple.

- `xattr` without arguments displays extended attributes:

```
> sudo xattr /Applications/Icns\ creator.app
> com.apple.quarantine
```

- `xattr -cr` removes all extended attributes:

`> sudo xattr -cr /Applications/Icns\ creator.app`

- After this command, `xattr` no longer displays `com.apple.quarantine` extended attribute:

```
> sudo xattr /Applications/Icns\ creator.app 
> (no output)
```

#### 3.- Xattr-remove

Xattr-remove is a simple GUI application to remove the extended attribute `com.appl.quarantine` from files downloaded from Internet. It has their own [repository](https://github.com/perez987/Xattr-remove).

#### 4.- Result

Either way, disabling Gatekeeper, System Settings, “xattr” or Xattr-remove, from this point on, the downloaded app will run without security prompts because the `com.apple.quarantine` attribute has been removed.

### Option 3 (For developers)

To build the app by yourself or make modifications on the source code (Optional). If you have issues because of Apple's security issues, or you do not prefer to install compiled apps, you can compile the app by yourself and review the code as well.

Note: You don't need to remove the `com.apple.quarantine` attribute if you download the source code, compile the app with Xcode, and save the product for regular use. When you compile an app in Xcode and set it to Sign to Run Locally, Xcode signs it with a trusted local certificate so the system can run it. If `Hardened Runtime` is disabled, the app doesn't need Apple's certification and will continue to function normally on your Mac. That's why you don't see the security warning.
