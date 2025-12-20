# TypeToMeClassic
A typing exercise addon. Type quest descriptions to accept and complete quests. Or sit in the library and write/copy books.

## How to use:
Copy the unzipped TypeToMe folder into `*/_retail_/Interface/AddOns/`

After installing the addon it should automatically run. If you encounter grey text that should be black just start typing.

## Slash Commands:

`/typetome quests`
* Toggles quests typing on/off. Default: On.
* Putting this twice in one macro lets you skip typing and accept/complete just the currently opened quest. Useful for when you are under time pressure - or just can't be bothered to type at the moment.

`/typetome items`
* Toggles item typing on/off. Default: On.


`/typetome stats`
* Toggles statistics output on/off. Default: On. 
* After finishing a text for the first time, words per minute, typed characters, spent time and accuracy are displayed in the chat window. 
* The timer should start when you type the first character and not when you open the quest frame. 

`/typetome <accuracy>`

* Example: `/typetome 72`
* Sets the target accuraty for quest texts to the desired value between 0 and 100. Default: 95.
* "Accuracy" for now just means the ratio of correct characters to all characters after typing the last character for the first time.
* There is no accuracy test for readable items like books and letters. Those are basically free practice mode.

`/typetome default`
* Resets all the above to default settings.

`/typetome`
* View all slash commands and current settings.


## What can I type?
Quest descriptions.

Books, letters and other readable items.

## Why can I not type all gossip texts?
In general all text which would be typed more than once was excluded because that became too annoying too fast.

### Excluded texts: 
* Everything besides the quest info description text in quest accept frames, and the quest info reward text in quest complete frames.

* All quests if you are in an instance - because everyone is an a hurry...

* Quest info description text for auto-accept quests since it makes no sense to hide the accept button and because they appear unprompted.


## Additional Info

All options are account wide.

No statistics are logged.

Partially typed text should only reset when opening a frame with a different questID so if you get interrupted or the quest giver wanders off you don't have to start over as long as you open the same quest (and don't reload the UI).

In general this was inteded to be a very low pressure typing exercise (I'm pretty new to touch typing (and coding) and wanted to finally finish at least one of my projects.)

Feedback welcome. Thank you for trying and happy typing.

## Known issues

* Quests started by items are auto-accepted but not skipped by the addon.