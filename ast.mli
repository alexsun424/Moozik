type measures =
    |Note of string
    |Measure of string list

type section = string list

type track = section list

type composition = track list 

type program = 
    Playback of string


(* program = {
    key: "C"
    time: "4/4"
    notes: 
}

pythonscript keyvariable timevariable notesvariable *)
