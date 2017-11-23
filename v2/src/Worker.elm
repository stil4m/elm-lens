port module Worker exposing (main)

import And
import Ast.Statement exposing (Statement)
import Json.Decode
import Model.AST
import Model.Report
import Model.TopLevelExpressions
import Types.Report exposing (Report)
import Types.TopLevelExpressions exposing (TopLevelExpressions)


type alias Model =
    { fileAST : List Statement
    , topLevelExpressions : TopLevelExpressions
    }


type Message
    = ProcessFile ( String, String )


main : Program Never Model Message
main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Message )
init =
    { fileAST = []
    , topLevelExpressions =
        { functions = []
        , types = []
        , typeAliases = []
        }
    }
        |> And.noCommand


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        ProcessFile ( fileName, text ) ->
            model
                |> Model.AST.buildFrom text
                |> Model.TopLevelExpressions.collect
                |> andSendReport fileName


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ process ProcessFile ]


andSendReport : String -> Model -> ( Model, Cmd Message )
andSendReport fileName model =
    And.execute (report <| Model.Report.make fileName model) model


port report : Report -> Cmd message


port process : (( String, String ) -> message) -> Sub message
