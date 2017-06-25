# Desolate Host Frame Fix

## Download
https://mods.curse.com/addons/wow/270658-desolate-host-frame-fix

## What is it
This World of Warcraft addon adjusts the alpha color channel of raid frame objects during the 'The Desolate Host' raid encounter in the Tomb of Sargeras.

## How it works
It works by hooking the unit spell range checking functions and adds an extra check that the unit be in the same "realm" as you, whether it be the corporeal or spirit. Should the unit not be int phase with you, the frame alpha will adjust to look the same as if the unit was out of range.

## Motivation
Long time healers, like myself, have an innate reaction to heal players that get dangerously low. If that person happens to be in a separate realm, you click and nothing happens and then you get the dreaded blue hand. The reaction is usally suppressed if the unit is indicated as out of range (>40 yards).

You would be a user if this addon if you are a healer that uses click-bind or mouseover style casting, but it could be useful for raid leaders to quickly asses the situation. 

## Feedback
I am interested in hearing directly from you. About anything you want to share or ask. You can [report issues on GitHub](https://github.com/InKahootz/DesolateHostFrameFix/issues).
