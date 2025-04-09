type expr = 
|Asn of expr * expr list
|AsnInstVar of expr * string * expr list
|Call of expr * expr * expr list
|ObjCallNoArgs of expr 
|ObjCallArgs of expr * expr list
|Measures of expr list
|Bar of expr list
|Param of string
|Var of string
|NoteLit of string
|ChordLit of string
|ClassLit of string
|ClassMethodLit of string
|Playback of string

type stmt =
|Expr of expr list
|Repeat of int * stmt
|If of string * stmt

type program = {
    (* locals: bind list; *)
    body: stmt list

}

(* module StringMap = Map.Make(String) *)

(* type sign = 
| Sharp of string
| Flat of string
| Natural of string
| Empty of string *)

(* type note = (string, string, string)

type data_structs = 
| Measure of measures
| Section of section
| Track of track
| Composition of composition

type measures = string

type section = 
{
    key: string;
    time: string;
}

type track = 
{
    instrument: string;
    section list
}

type composition = 
{
    tracks: track StringMap.t
}
 *)
