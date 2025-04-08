type expr = 
|Seq of expr * expr
|Asn of string * expr
|AsnInstVar of string * string * expr
|Star of string list
|Call of expr * expr list
|ObjCall of expr * expr
|Var of string
|NoteLit of string
|ChordLit of string

type block = 
|Expr of expr list
|While of string * expr list
|If of string * expr list

type program = block list

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
