# trainmon

This addon for Ashita v4 tracks and displays Training Regime objectives. It supports both English and Japanese clients.

![Example](https://github.com/onimitch/ffxi-trainmon/blob/main/Example.png "Example")


## How to install:
1. Download the latest Release from the [Releases page](https://github.com/onimitch/ffxi-trainmon/releases)
2. Extract the **_trainmon_** folder to your **_Ashita4/addons_** folder

## How to have Ashita load it automatically:
1. Go to your Ashita v4 folder
2. Open the file **_Ashita4/scripts/default.txt_**
3. Add `/addon load trainmon` to the list of addons to load under "Load Plugins and Addons"

## Usage

Go to a Field Manual and start a training regime. If you've already started one then confirm the training options to update trainmon.

By default the training objectives will only display while you're in the zone the training is for.

You can drag the window by mouse click and hold on the arrow icon.

## Commands

You can use `/trainmon` or `/tmon`

`/trainmon config` (or `/trainmon` alone) - Open the settings window. Show the current regime in all zones, toggle the background, adjust its opacity (0% transparent to 100% opaque), and change title and objective text sizes. Changes apply immediately and are saved. The background is disabled by default. Showing in all zones requires an existing tracked regime.

`/trainmon status` - Show in chat log the current training data.

`/trainmon reset` - Clear all training data from trainmon. Note this doesn't cancel your training regime with the game, it just stops the addon tracking your kills.

`/trainmon hide` - Hide the training window

`/trainmon show` - Show the training window only in the zone the training is for.

`/trainmon show always` - Show the training window in all zones, regardless of what zone the training is for.

## Version 1.4.0

- Updated the ImGui window argument and numeric Ashita zoning check.
- Guarded missing memory scans and intermediate pointers. Unresolved scans are reported at load; their related automatic hiding may be unavailable. Memory signatures were not replaced.
- Added saved background, opacity, text-size, and all-zones controls in the settings window.
- Used server progress directly when its total uniquely identifies an objective, including when a named defeat message is missing. Equal-total objectives retain name matching.
- Fixed the reset command's save-method name.

Offline LuaJIT checks cover syntax and server-progress regression cases. The addon display and settings have been tried in game; the reported Headsman progress case still needs live retesting.

The standalone regression check is `test/test_progress.lua`; run it from this repository with LuaJIT, outside Ashita. It uses in-memory settings stubs and does not access player saves. The generated `package/` folder is excluded from Git; the `gdifonts` submodule remains pinned to its existing revision.

## How does it work?

Trainmon works by parsing messages in the chat log for training data, updates and monster kills.

Some training objectives require members of a family or type, and for that I've built a database to match monsters to their family or type based on data from www.bg-wiki.com.

It isn't perfect though, and despite building some fairly thorough tests that cover both English and Japanese (see test folder in the repo), there is bound to be some missing monster data.

If you get the error message "Failed to find "<monster name>" in Training Data", please [create an issue on GitHub](https://github.com/onimitch/ffxi-trainmon/issues) and let me know what training regime you were doing and what monsters you killed. It helps if you can be very specific of the names that appeared in your chat log.

## Issues/Support

I only have limited time available to offer support, but if you have a problem, have discovered a bug or want to request a feature, please [create an issue on GitHub](https://github.com/onimitch/ffxi-trainmon/issues).
