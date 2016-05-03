(* http get xml *)

open Nethttp_client.Convenience

let body =
  let req = http_get_message "http://www.tbsradio.jp/ijuin/rss.xml" in
  match req # status with
    `Successful ->
    let xmlstr = req # response_body # value in
    print_endline xmlstr
  (* let format = Xmlplaylist.Podcast in *)
  (* let tracks = Xmlplaylist.tracks ~format xmlstr in *)
  (* push queue *)
  | _ -> print_endline "Some error"
;;
