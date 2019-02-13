# 2048 Example Skillz iOS Integration

This repository contains an example iOS game that integrates the Skillz SDK. It is intended to supplement the [documentation](https://cdn.skillz.com/doc/developer/ios_native/integrate_skillz_sdk/install_skillz_via_xcode/) that walks users through the process of integrating an iOS game.

All credits to the design of this game belongs to:
* Danqing Liu
* Scott Matthewman
* Sihao Lu

Original code: https://github.com/danqing/2048

Use governed by the MIT License.

## Build Environment

This project integrated the Skillz SDK version 21.0.19 Beta. Check the [Downloads](https://developers.skillz.com/downloads) page for the latest version.

The project was built on Xcode 10.1. Also, make sure you have the appropriate developer certificate and provisioning profiles so that it can be run on an iOS device. The provisioning profiles need to set the bundle name to `com.skillz.examples.2048`.

If you are experiencing trouble, please email integrations@skillz.com with a detailed description of the issue you are encountering.

## Commit Instructions

The commits in this repository have been organized to make the SDK integration easier to follow.

### Commit 01: Prepwork for SDK Integration

The [first commit](https://github.com/skillz/2048/commit/ed429dcf13ca0e4af26fefd479be7056b13b3b16) makes some preparations before integrating the SDK. Specifically, the UI was altered in anticipation of launching the Skillz SDK, being able to abort a match (the "Restart" button was renamed to "Forfeit"), and removing soon to be dead code.

### Commit 02: Install the Skillz SDK

The [second commit](https://github.com/skillz/2048/commit/7b4654e642630b5e78fad6678f83f29951ccd6c3) simply installs the Skillz SDK that was downloaded from the [Skillz Developer Portal](https://developers.skillz.com/downloads). This is done by dragging the `Skillz.framework` file into your XCode project, and adding it to both your `Linked Libraries` and `Embedded Binaries` build phases. Refer to the [full instructions](https://cdn.skillz.com/doc/developer/ios_native/integrate_skillz_sdk/install_skillz_via_xcode/) for more information.

At this point, the game is not integrated with the SDK and still compiles and runs normally.

### Commit 03: Getting In and Out of the Skillz SDK

Finally, the Skillz SDK is [integrated](https://github.com/skillz/2048/commit/b9ddefc4293748373a646f657eb80f146c3decdd) by following the instructions at this [page](https://cdn.skillz.com/doc/developer/ios_native/integrate_skillz_sdk/implement_the_app_delegate/).

Changes in this commit include:
* Implementing the `SkillzDelegate` protocol so that the game is notified when a match will begin.
* Modifying `M2ViewController` to launch the Skillz UI after the game's main view has been loaded.
* Reporting the user's current score while a match is in progress.
* Reporting the user's final score when the match ends.
* Aborting a match.

### Commit 04: Ensuring Fairness

This [commit](https://github.com/skillz/2048/commit/1eb0a63e8a7c4873215a0b2433a0d82c552fd5b5) ensures fairness during a match by calling `[Skillz getRandomNumberWithMin: andMax:]` when setting a ball's initial direction and force. Refer to this [page](https://cdn.skillz.com/doc/developer/ios_native/integrate_skillz_sdk/reimplement_random_number_generation_rng_for_fairness/) for more details.