module Keyboard
    exposing
        ( Key(..)
        , KeyChange(..)
        , KeyParser
        , Msg
        , RawKey
        , anyKey
        , characterKey
        , clears
        , downs
        , editingKey
        , functionKey
        , mediaKey
        , modifierKey
        , navigationKey
        , oneOf
        , phoneKey
        , rawValue
        , subscriptions
        , update
        , updateWithKeyChange
        , updateWithParser
        , ups
        , whitespaceKey
        )

{-| Convenience helpers for working with keyboard inputs.


# Msg and Update

Using Keyboard this way, you get all the help it can provide.
Use either this approach, or the plain subscriptions and handle the state yourself.

@docs Msg, subscriptions, update


## More advanced

@docs updateWithParser, KeyChange, updateWithKeyChange


# Key parsers

@docs RawKey, KeyParser

@docs anyKey, characterKey, modifierKey, whitespaceKey, navigationKey, editingKey, functionKey, phoneKey, mediaKey


## Combining key parsers

@docs oneOf


# Plain Subscriptions

If you prefer to only get "the facts" and do your own handling, use these
subscriptions. Otherwise, you may be more comfortable with the Msg and Update.

@docs downs, ups, clears


# Low level

@docs rawValue


# Keyboard keys

@docs Key

-}

import Browser
import Dict exposing (Dict)
import Json.Decode as Json


{-| An unprocessed key value.

Use a `KeyParser` to turn it into something useful.

-}
type RawKey
    = RawKey String


{-| A key parser can turn `RawKey`s into meaningful `Key`s for your program.
-}
type alias KeyParser =
    RawKey -> Maybe Key


{-| Get the original string value of the `RawKey`.
-}
rawValue : RawKey -> String
rawValue (RawKey key) =
    key


eventKeyDecoder : Json.Decoder RawKey
eventKeyDecoder =
    Json.field "key" (Json.string |> Json.map RawKey)


{-| Subscription for key down events.

**Note** When the user presses and holds a key, there may or may not be many of
these messages before the corresponding key up message.

-}
downs : (RawKey -> msg) -> Sub msg
downs toMsg =
    Browser.onDocument "keydown" (eventKeyDecoder |> Json.map toMsg)


{-| Subscription for key up events.
-}
ups : (RawKey -> msg) -> Sub msg
ups toMsg =
    Browser.onDocument "keyup" (eventKeyDecoder |> Json.map toMsg)


{-| Subscription for window blur events. In the "Msg and Update" way I use this to clear out all
"stuck-down" keys.
-}
clears : msg -> Sub msg
clears msg =
    Browser.onWindow "blur" (Json.succeed msg)


{-| `Keyboard`'s internal message type.
-}
type Msg
    = Down RawKey
    | Up RawKey
    | ClearKeys


{-| The subscriptions needed for the "Msg and Update" way.
-}
subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ downs Down
        , ups Up
        , clears ClearKeys
        ]


insert : KeyParser -> RawKey -> List Key -> List Key
insert keyParser rawKey list =
    case keyParser rawKey of
        Just key ->
            key :: List.filter ((/=) key) list

        Nothing ->
            list


remove : KeyParser -> RawKey -> List Key -> List Key
remove keyParser rawKey list =
    case keyParser rawKey of
        Just key ->
            List.filter ((/=) key) list

        Nothing ->
            list


{-| Use this to have the list of keys update.

This will give you all the keys I can recognize.

  - If you encounter sluggish performance and need to optimize your program,
    try [`updateWithParser`](#updateWithParser).
  - If you need to know exactly what changed just now, have a look
    at [`updateWithKeyChange`](#updateWithKeyChange).

-}
update : Msg -> List Key -> List Key
update =
    updateWithParser anyKey


{-| A more advanced version of `update`. Provide it with a smaller `KeyParser` than `anyKey` and
it will perform a little bit faster.
-}
updateWithParser : KeyParser -> Msg -> List Key -> List Key
updateWithParser keyParser msg state =
    case msg of
        Down key ->
            insert keyParser key state

        Up key ->
            remove keyParser key state

        ClearKeys ->
            []


{-| The second value `updateWithKeyChange` may return, representing the actual
change that happened during the update.
-}
type KeyChange
    = KeyDown Key
    | KeyUp Key


{-| This alternate update function answers the question: "Did the pressed down
keys in fact change just now?"

You might be wondering why this is a `Maybe KeyChange` &ndash; it's because
`keydown` events happen many times per second when you hold down a key. Thus,
not all incoming messages actually cause a change in the model. Also, you will
only get updates for the keys that match your `KeyParser`.

-}
updateWithKeyChange : KeyParser -> Msg -> List Key -> ( List Key, Maybe KeyChange )
updateWithKeyChange keyParser msg state =
    case msg of
        Down key ->
            let
                nextState =
                    insert keyParser key state

                change =
                    if List.length nextState /= List.length state then
                        Maybe.map KeyDown (keyParser key)

                    else
                        Nothing
            in
            ( nextState, change )

        Up key ->
            let
                nextState =
                    remove keyParser key state

                change =
                    if List.length nextState /= List.length state then
                        Maybe.map KeyUp (keyParser key)

                    else
                        Nothing
            in
            ( nextState, change )

        ClearKeys ->
            ( [], Nothing )



{- A `Json.Decoder` for grabbing `event.keyCode` and turning it into a `Key`

       import Json.Decode as Json

       onKey : (Key -> msg) -> Attribute msg
       onKey tagger =
           on "keydown" (Json.map tagger targetKey)

   targetKey : Json.Decoder Key
   targetKey =
     Json.map fromCode (Json.field "keyCode" Json.int)
-}


{-| These are all the keys that have names in `Keyboard`.
-}
type Key
    = Character String
    | Alt
    | AltGraph
    | CapsLock
    | Control
    | Fn
    | FnLock
    | Hyper
    | Meta
    | NumLock
    | ScrollLock
    | Shift
    | Super
    | Symbol
    | SymbolLock
    | Enter
    | Tab
    | Spacebar
    | ArrowDown
    | ArrowLeft
    | ArrowRight
    | ArrowUp
    | End
    | Home
    | PageDown
    | PageUp
    | Backspace
    | Clear
    | Copy
    | CrSel
    | Cut
    | Delete
    | EraseEof
    | ExSel
    | Insert
    | Paste
    | Redo
    | Undo
    | F1
    | F2
    | F3
    | F4
    | F5
    | F6
    | F7
    | F8
    | F9
    | F10
    | F11
    | F12
    | F13
    | F14
    | F15
    | F16
    | F17
    | F18
    | F19
    | F20
    | Again
    | Attn
    | Cancel
    | ContextMenu
    | Escape
    | Execute
    | Find
    | Finish
    | Help
    | Pause
    | Play
    | Props
    | Select
    | ZoomIn
    | ZoomOut
    | AppSwitch
    | Call
    | Camera
    | CameraFocus
    | EndCall
    | GoBack
    | GoHome
    | HeadsetHook
    | LastNumberRedial
    | Notification
    | MannerMode
    | VoiceDial
    | ChannelDown
    | ChannelUp
    | MediaFastForward
    | MediaPause
    | MediaPlay
    | MediaPlayPause
    | MediaRecord
    | MediaRewind
    | MediaStop
    | MediaTrackNext
    | MediaTrackPrevious


{-| This parser tries to match with all the keys I can recognize. It is used in [`update`](#update).

**This might be slow!** If you only need e.g. arrow keys, you can use
`navigationKey` instead.

If the key doesn't match any of the categories, `Nothing` is returned.

-}
anyKey : KeyParser
anyKey =
    oneOf
        [ characterKey
        , modifierKey
        , whitespaceKey
        , navigationKey
        , editingKey
        , functionKey
        , uiKey
        , phoneKey
        , mediaKey
        ]


{-| Turn any `RawKey` into a `Key` using the processing functions (`modifierKey`, `whitespaceKey`,
etc.) provided. If the key doesn't match any of the categories, `Nothing` is returned.
-}
oneOf : List KeyParser -> KeyParser
oneOf fns key =
    case fns of
        [] ->
            Nothing

        fn :: rest ->
            case fn key of
                Just a ->
                    Just a

                Nothing ->
                    oneOf rest key


{-| Returns the character that was pressed.

**NOTE** There is no reasonable way of actually telling if a certain key is a character or not.
For now at least, consider this a Western language focused "best guess".

Examples on a US layout:

<key>A</key> -> `Just (Character "a")`

<key>Shift</key> + <key>A</key> -> Just (Character "A")

<key>Shift</key> + <key>1</key> -> Just (Character "!")

<key>Shift</key> -> Nothing

-}
characterKey : KeyParser
characterKey (RawKey value) =
    if String.length value == 1 then
        Just (Character value)

    else
        Nothing


{-| Converts a `RawKey` if it is one of the [modifier keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Modifier_keys).

<key>Alt</key> -> `Just Alt`

<key>Tab</key> -> `Nothing`

-}
modifierKey : KeyParser
modifierKey (RawKey value) =
    case value of
        -- Modifiers
        "Alt" ->
            Just Alt

        "AltGraph" ->
            Just AltGraph

        "CapsLock" ->
            Just CapsLock

        "Control" ->
            Just Control

        "Fn" ->
            Just Fn

        "FnLock" ->
            Just FnLock

        "Hyper" ->
            Just Hyper

        "Meta" ->
            Just Meta

        "NumLock" ->
            Just NumLock

        "ScrollLock" ->
            Just ScrollLock

        "Shift" ->
            Just Shift

        "Super" ->
            Just Super

        -- Firefox
        "OS" ->
            Just Super

        "Symbol" ->
            Just Symbol

        "SymbolLock" ->
            Just SymbolLock

        _ ->
            Nothing


{-| Converts a `RawKey` if it is one of the [whitespace keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Whitespace_keys).

<key>Tab</key> -> `Just Tab`

<key>Alt</key> -> `Nothing`

-}
whitespaceKey : KeyParser
whitespaceKey (RawKey value) =
    case value of
        -- Whitespace
        "Enter" ->
            Just Enter

        "Tab" ->
            Just Tab

        "Spacebar" ->
            Just Spacebar

        " " ->
            Just Spacebar

        _ ->
            Nothing


{-| Converts a `RawKey` if it is one of the [navigation keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Navigation_keys).

<key>ArrowLeft</key> -> `Just ArrowLeft`

<key>A</key> -> `Nothing`

-}
navigationKey : KeyParser
navigationKey (RawKey value) =
    case value of
        -- Navigation
        "ArrowDown" ->
            Just ArrowDown

        "ArrowLeft" ->
            Just ArrowLeft

        "ArrowRight" ->
            Just ArrowRight

        "ArrowUp" ->
            Just ArrowUp

        "Down" ->
            Just ArrowDown

        "Left" ->
            Just ArrowLeft

        "Right" ->
            Just ArrowRight

        "Up" ->
            Just ArrowUp

        "End" ->
            Just End

        "Home" ->
            Just Home

        "PageDown" ->
            Just PageDown

        "PageUp" ->
            Just PageUp

        _ ->
            Nothing


{-| Converts a `RawKey` if it is one of the [editing keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Editing_keys).

<key>Backspace</key> -> `Just Backspace`

<key>Enter</key> -> `Nothing`

-}
editingKey : KeyParser
editingKey (RawKey value) =
    case value of
        "Backspace" ->
            Just Backspace

        "Clear" ->
            Just Clear

        "Copy" ->
            Just Copy

        "CrSel" ->
            Just CrSel

        "Cut" ->
            Just Cut

        "Delete" ->
            Just Delete

        "EraseEof" ->
            Just EraseEof

        "ExSel" ->
            Just ExSel

        "Insert" ->
            Just Insert

        "Paste" ->
            Just Paste

        "Redo" ->
            Just Redo

        "Undo" ->
            Just Undo

        _ ->
            Nothing


{-| Converts a `RawKey` if it is one of the [function keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Function_keys).

<key>F4</key> -> `Just F4`

<key>6</key> -> `Nothing`

-}
functionKey : KeyParser
functionKey (RawKey value) =
    case value of
        "F1" ->
            Just F1

        "F2" ->
            Just F2

        "F3" ->
            Just F3

        "F4" ->
            Just F4

        "F5" ->
            Just F5

        "F6" ->
            Just F6

        "F7" ->
            Just F7

        "F8" ->
            Just F8

        "F9" ->
            Just F9

        "F10" ->
            Just F10

        "F11" ->
            Just F11

        "F12" ->
            Just F12

        "F13" ->
            Just F13

        "F14" ->
            Just F14

        "F15" ->
            Just F15

        "F16" ->
            Just F16

        "F17" ->
            Just F17

        "F18" ->
            Just F18

        "F19" ->
            Just F19

        "F20" ->
            Just F20

        _ ->
            Nothing


{-| Converts a `RawKey` if it is one of the [UI keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#UI_keys).
-}
uiKey : KeyParser
uiKey (RawKey value) =
    case value of
        -- UI
        "Again" ->
            Just Again

        "Attn" ->
            Just Attn

        "Cancel" ->
            Just Cancel

        "ContextMenu" ->
            Just ContextMenu

        "Escape" ->
            Just Escape

        "Execute" ->
            Just Execute

        "Find" ->
            Just Find

        "Finish" ->
            Just Finish

        "Help" ->
            Just Help

        "Pause" ->
            Just Pause

        "Play" ->
            Just Play

        "Props" ->
            Just Props

        "Select" ->
            Just Select

        "ZoomIn" ->
            Just ZoomIn

        "ZoomOut" ->
            Just ZoomOut

        _ ->
            Nothing


{-| Converts a `RawKey` if it is one of the [phone keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Phone_keys).
-}
phoneKey : KeyParser
phoneKey (RawKey value) =
    case value of
        -- Phone
        "AppSwitch" ->
            Just AppSwitch

        "Call" ->
            Just Call

        "Camera" ->
            Just Camera

        "CameraFocus" ->
            Just CameraFocus

        "EndCall" ->
            Just EndCall

        "GoBack" ->
            Just GoBack

        "GoHome" ->
            Just GoHome

        "HeadsetHook" ->
            Just HeadsetHook

        "LastNumberRedial" ->
            Just LastNumberRedial

        "Notification" ->
            Just Notification

        "MannerMode" ->
            Just MannerMode

        "VoiceDial" ->
            Just VoiceDial

        _ ->
            Nothing


{-| Converts a `RawKey` if it is one of the [media keys](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Media_keys).
-}
mediaKey : KeyParser
mediaKey (RawKey value) =
    case value of
        -- Media
        "ChannelDown" ->
            Just ChannelDown

        "ChannelUp" ->
            Just ChannelUp

        "MediaFastForward" ->
            Just MediaFastForward

        "MediaPause" ->
            Just MediaPause

        "MediaPlay" ->
            Just MediaPlay

        "MediaPlayPause" ->
            Just MediaPlayPause

        "MediaRecord" ->
            Just MediaRecord

        "MediaRewind" ->
            Just MediaRewind

        "MediaStop" ->
            Just MediaStop

        "MediaTrackNext" ->
            Just MediaTrackNext

        "MediaTrackPrevious" ->
            Just MediaTrackPrevious

        _ ->
            Nothing
