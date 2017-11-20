module Model.Report exposing (make)

import Dict exposing (Dict)
import FunctionMetaData exposing (FunctionMetaData)
import ReferenceMetaData exposing (ReferenceMetaData)
import Report exposing (Report)
import Set exposing (Set)


type alias FileFunctionsMap =
    Dict String (Set String)


type alias FileFunctionMetaMap =
    Dict String (Dict String FunctionMetaData)


type alias FileReferenceMap =
    Dict String (Dict String ReferenceMetaData)


type alias Model model =
    { model
        | exposedFunctions : FileFunctionsMap
        , allFunctionMetaData : FileFunctionMetaMap
        , internalRefsByFile : FileReferenceMap
    }


make : String -> Model model -> Report
make fileName model =
    Report fileName (functionExposingsList fileName model)


functionExposingsList : String -> Model model -> List Report.FunctionData
functionExposingsList fileName model =
    List.map
        (\functionName ->
            Report.FunctionData
                functionName
                (lineForFunctionName fileName functionName model)
                (isExposed fileName functionName model)
                (countInternalReferences fileName functionName model)
        )
        (allFunctionsList fileName model)


allFunctionsList : String -> Model model -> List String
allFunctionsList fileName model =
    Dict.get fileName model.allFunctionMetaData
        |> Maybe.withDefault Dict.empty
        |> Dict.toList
        |> List.map Tuple.first


lineForFunctionName : String -> String -> Model model -> Int
lineForFunctionName fileName functionName model =
    Dict.get fileName model.allFunctionMetaData
        |> Maybe.withDefault Dict.empty
        |> Dict.get functionName
        |> Maybe.map FunctionMetaData.getLineNumber
        |> Maybe.withDefault -1


isExposed : String -> String -> Model model -> Bool
isExposed fileName functionName model =
    Dict.get fileName model.exposedFunctions
        |> Maybe.withDefault Set.empty
        |> Set.member functionName


countInternalReferences : String -> String -> Model model -> Int
countInternalReferences fileName functionName model =
    Dict.get fileName model.internalRefsByFile
        |> Maybe.withDefault Dict.empty
        |> Dict.get functionName
        |> Maybe.map ReferenceMetaData.numInstances
        |> Maybe.withDefault 0
