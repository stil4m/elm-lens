module Types.Report exposing (Report)

import Types.TopLevelExpressions exposing (TopLevelExpressions)


type alias Report =
    { fileName : String
    , topLevelExpressions : TopLevelExpressions
    }
