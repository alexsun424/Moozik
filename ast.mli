module StringMap = Map.Make(String)

(* type sign = 
| Sharp of string
| Flat of string
| Natural of string
| Empty of string *)

type note = (string, string, string)

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

