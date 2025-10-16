#require "lwt_react"
#require "lambda-term"

let t2str = fun tm ->
  Printf.sprintf "%02d:%02d:%02d" tm.Unix.tm_hour tm.Unix.tm_min tm.Unix.tm_sec

let make_prompt = fun ui count s ks (recording, macro_count, macro_counter) ->
  let open Printf in
  let open LTerm_text in
  let open LTerm_style in
  let open LTerm_geom in
  let tm = Unix.localtime !UTop.time in
  match ui with
  | UTop_private.Emacs -> [||]
  | UTop_private.Console ->
     let key_seq =
       let keys = String.concat " " (List.map LTerm_key.to_string_compact ks) in
       if ks = [] then [] else [ S "[ "; B_fg lgreen; S keys; E_fg; S " ]─"] in
     let left =
       B_fg lcyan :: S (sprintf "── %s ── %d ─" (t2str tm) count) :: key_seq
       |> eval in
     let right =
       B_fg lcyan :: S (sprintf "< %d >─" macro_counter)
       :: (if recording then [S (sprintf "[ %d ]─" macro_count)] else [])
       |> eval in
     (* let second_line = eval [ B_bold true; B_fg lcyan; S "\n❯ " ] in *)
     let second_line = eval [ B_bold true; B_fg lcyan; S "\n# " ] in
     let llr = Array.length left + Array.length right in
     Array.append (
         if llr > s.cols then Array.sub (Array.append left right) 0 s.cols
         else
           let sep = Uchar.of_int 0x2500 |> Zed_char.unsafe_of_uChar
           and sep_style = { none with foreground = Some lcyan } in
           let line = Array.make (s.cols - llr) (sep, sep_style) in
           Array.concat [ left; line; right ]
       ) second_line

let default_prompt =
  Lwt_react.S.l5 make_prompt
    UTop_private.ui UTop.count UTop.size UTop.key_sequence
    (Lwt_react.S.l3 (fun x y z -> (x, y, z))
       (Zed_macro.recording LTerm_read_line.macro)
       (Zed_macro.count LTerm_read_line.macro)
       (Zed_macro.counter LTerm_read_line.macro));;

UTop.prompt := default_prompt
