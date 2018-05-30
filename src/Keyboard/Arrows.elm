module Keyboard.Arrows
    exposing
        ( Arrows
        , Direction(..)
        , arrowKey
        , arrows
        , arrowsDirection
        , wasd
        , wasdDirection
        )

{-| Arrow keys and WASD get special treatment using the functions in this module. This is particularly useful for games.

@docs Arrows, arrows, wasd, Direction, arrowsDirection, wasdDirection

-}

import Keyboard exposing (Key(..), RawKey)


{-| Record type used for `arrows` and `wasd`.
Both `x` and `y` can range from `-1` to `1`, and are `0` if no keys are pressed.
-}
type alias Arrows =
    { x : Int, y : Int }


{-| Converts a `RawKey` if it is one of the Arrow keys or W, A, S, D.

<key>ArrowLeft</key> -> `Just ArrowLeft`

<key>A</key> -> `Character A`

<key>B</key> -> `Character B`

-}
arrowKey : RawKey -> Maybe Key
arrowKey rawKey =
    case Keyboard.rawValue rawKey of
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

        other ->
            let
                lower =
                    String.toLower other
            in
            if lower == "w" || lower == "a" || lower == "s" || lower == "d" then
                Just (Character other)

            else
                Nothing


{-| Gives the arrow keys' pressed down state as follows:

    arrows []                      --> { x = 0, y = 0 }

    arrows [ ArrowLeft ]           --> { x = -1, y = 0 }

    arrows [ ArrowUp, ArrowRight ] --> { x = 1, y = 1 }

    arrows [ ArrowDown, ArrowLeft, ArrowRight ]
                                   --> { x = 0, y = -1 }

-}
arrows : List Key -> Arrows
arrows keys =
    let
        toInt key =
            keys
                |> List.member key
                |> boolToInt

        x =
            toInt ArrowRight - toInt ArrowLeft

        y =
            toInt ArrowUp - toInt ArrowDown
    in
    { x = x, y = y }


{-| Similar to `arrows`, gives the W, A, S and D keys' pressed down state.

    wasd []
    --> { x = 0, y = 0 }

    wasd [ Character "A" ]
    --> { x = -1, y = 0 }

    wasd [ Character "W", Character "D" ]
    --> { x = 1, y = 1 }

    wasd [ Character "A", Character "S", Character "D" ]
    --> { x = 0, y = -1 }

-}
wasd : List Key -> Arrows
wasd keys =
    let
        toInt char1 char2 =
            boolToInt
                (List.member (Character char1) keys || List.member (Character char2) keys)

        x =
            toInt "D" "d" - toInt "A" "a"

        y =
            toInt "W" "w" - toInt "S" "s"
    in
    { x = x, y = y }


{-| Type representation of the arrows.
-}
type Direction
    = North
    | NorthEast
    | East
    | SouthEast
    | South
    | SouthWest
    | West
    | NorthWest
    | NoDirection


{-| Gives the arrow keys' pressed down state as follows:

    arrowsDirection []
    --> NoDirection

    arrowsDirection [ ArrowLeft ]
    --> West

    arrowsDirection [ ArrowUp, ArrowRight ]
    --> NorthEast

    arrowsDirection [ ArrowDown, ArrowLeft, ArrowRight ]
    --> South

-}
arrowsDirection : List Key -> Direction
arrowsDirection =
    arrowsToDir << arrows


{-| Similar to `arrows`, gives the W, A, S and D keys' pressed down state.

    wasdDirection []
    --> NoDirection

    wasdDirection [ Character "A" ]
    --> West

    wasdDirection [ Character "W", Character "D" ]
    --> NorthEast

    wasdDirection [ Character "A", Character "S", Character "D" ]
    --> South

-}
wasdDirection : List Key -> Direction
wasdDirection =
    arrowsToDir << wasd


arrowsToDir : Arrows -> Direction
arrowsToDir { x, y } =
    let
        x1 =
            x + 1

        y1 =
            y + 1
    in
    case ( x1, y1 ) of
        ( 1, 2 ) ->
            North

        ( 2, 2 ) ->
            NorthEast

        ( 2, 1 ) ->
            East

        ( 2, 0 ) ->
            SouthEast

        ( 1, 0 ) ->
            South

        ( 0, 0 ) ->
            SouthWest

        ( 0, 1 ) ->
            West

        ( 0, 2 ) ->
            NorthWest

        _ ->
            NoDirection


boolToInt : Bool -> Int
boolToInt bool =
    if bool then
        1

    else
        0
