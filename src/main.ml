open Printf
open Nethttp_client.Convenience
  
(* cannot get icon ... *)
(* cannot get title of rss ... *)
let track2html track =
  let metadata, uri = track in
  let title =
    try
      List.assoc "title" metadata
    with Not_found -> "" in
  let pubdate =
    try
      List.assoc "pubdate" metadata
    with Not_found -> "" in
  (* sprintf "<div><a href=\"#\" class=\"list-group-item\">%s %s<br><audio src=\"%s\" controls></a></div>\n" *)
(* 	  title pubdate uri *)
  sprintf "<li class=\"list-group-item\">%s %s<br><audio src=\"%s\" controls></audio></li>\n"
 	  title pubdate uri
;;
	    
(* TODO: call podcast fetch part in async way *)
let generate (cgi : Netcgi.cgi_activation) =
  let req = http_get_message "http://www.tbsradio.jp/ijuin/rss.xml" in
  let listdata = 
    match req # status with
      `Successful ->
      let xmlstr = req # response_body # value in
      let format = Xmlplaylist.Podcast in
      let tracks = Xmlplaylist.tracks ~format xmlstr in
      String.concat "" (List.map track2html tracks)
    | _ -> "" in
  (* A Netcgi-based content provider *)
  cgi # set_header
    ~cache:`No_cache
    ~content_type:"text/html; charset=\"utf-8\""
    ();
  let data =
    "<html>\n" ^
      "  <head><title>List</title>"^
	"<meta name=\"viewport\" content=\"width=device-width\" />"^
	  "<link rel=\"stylesheet\" href=\"/resource/bootstrap/css/bootstrap.min.css\" type=\"text/css\" />\n" ^
	   "<script src=\"/resource/jquery/jquery-2.2.3.min.js\"></script>" ^
	   "<script src=\"/resource/bootstrap/js/bootstrap.min.js\"></script>" ^
       "</head>\n" ^
	"  <body><div class=\"container\"><ul class=\"list-group\">\n" ^
	  listdata ^
	    "</div></body>\n" ^
	      "</html>" in
  cgi # output # output_string data;
  cgi # output # commit_work()
;;

let resource_path_regexp = Str.regexp "^/resource/"
;;
  
let on_request notification = 
  (* This function is called when the full HTTP request has been received. For
   * simplicity, we create a [std_activation] to serve the request.
   *
   * An advanced implementation could set up further notifications to get informed
   * whenever there is space in the response buffer for additional output.
   * Currently, data is fully buffered (first
   * in the transactional buffer, then in the response buffer), and only when
   * the message is complete, the transmission to the client starts.
   * By generating only the next part of the response when there is space in
   * the response buffer, the advanced implementation can prevent that the
   * buffers become large.
   *)
  (try
      let env =
        notification # environment in
      let request_uri = env # cgi_request_uri |> Uri.of_string in
      let path = Uri.path request_uri in
      if "/" = path then
	let cgi =
          Netcgi_common.cgi_with_args
            (new Netcgi_common.cgi)
            (env :> Netcgi.cgi_environment)
            Netcgi.buffered_transactional_outtype
            env#input_channel
            (fun _ _ _ -> `Automatic) in
	generate cgi;
      else if Str.string_match resource_path_regexp path 0 then
      	let localpath = "."^path in
      	let length = (Unix.stat localpath).Unix.st_size |> Int64.of_int in 
      	let fd = Unix.openfile localpath [Unix.O_RDONLY; Unix.O_NONBLOCK] 0o640 in
	if Filename.check_suffix localpath ".css" then
	  env # set_output_header_field "Content-Type" "text/css"
	else if Filename.check_suffix localpath ".js" then
	  env # set_output_header_field "Content-Type" "text/javascript"
	else if Filename.check_suffix localpath ".png" then
	  env # set_output_header_field "Content-Type" "image/png";
      	env # send_file fd length;
    with e ->
      printf "Uncaught exception: %s\n" (Printexc.to_string e);
      flush stdout
  );
  notification # schedule_finish()

let on_request_header (notification : Nethttpd_engine.http_request_header_notification) =
  (* After receiving the HTTP header: We always decide to accept the HTTP body, if any
   * is following. We do not set up special processing of this body, it is just
   * buffered until complete. Then [on_request] will be called.
   *
   * An advanced server could set up a further notification for the HTTP body. This
   * additional function would be called whenever new body data arrives. (Do so by
   * calling [notification # environment # input_ch_async # request_notification].)
   *)
  notification # schedule_accept_body ~on_request ()
;;

let serve_connection ues fd =
  (* Creates the http engine for the connection [fd]. When a HTTP header is received
   * the function [on_request_header] is called.
   *)
  let config = Nethttpd_engine.default_http_engine_config in
  Unix.set_nonblock fd;
  let _ =
    new Nethttpd_engine.http_engine ~on_request_header () config fd ues in
  ()
;;

let rec accept ues srv_sock_acc =
  (* This function accepts the next connection using the [acc_engine]. After the
   * connection has been accepted, it is served by [serve_connection], and the
   * next connection will be waited for (recursive call of [accept]). Because
   * [server_connection] returns immediately (it only sets the callbacks needed
   * for serving), the recursive call is also done immediately.
   *)
  let acc_engine = srv_sock_acc # accept() in
  Uq_engines.when_state ~is_done:(fun (fd,fd_spec) ->
			        if srv_sock_acc # multiple_connections then (
			          serve_connection ues fd;
			          accept ues srv_sock_acc
                                   ) else
				  srv_sock_acc # shut_down())
                        ~is_error:(fun _ -> srv_sock_acc # shut_down())
                        acc_engine;
;;

let start port =
  (* We set up [lstn_engine] whose only purpose is to create a server socket listening
   * on the specified port. When the socket is set up, [accept] is called.
   *)
  printf "Listening on port %d\n" port;
  flush stdout;
  let ues = Unixqueue.create_unix_event_system () in
  (* Unixqueue.set_debug_mode true; *)
  let opts = { Uq_server.default_listen_options with
     Uq_engines.lstn_reuseaddr = true } in
  let lstn_engine =
    Uq_server.listener
      (`Socket(`Sock_inet(Unix.SOCK_STREAM, Unix.inet_addr_any, port) ,opts)) ues in
  Uq_engines.when_state ~is_done:(accept ues) lstn_engine;
  (* Start the main event loop. *)
  Unixqueue.run ues
;;
let conf_debug() =
  (* Set the environment variable DEBUG to either:
       - a list of Netlog module names
       - the keyword "ALL" to output all messages
       - the keyword "LIST" to output a list of modules
     By setting DEBUG_WIN32 additional debugging for Win32 is enabled.
   *)
  let debug = try Sys.getenv "DEBUG" with Not_found -> "" in
  if debug = "ALL" then
    Netlog.Debug.enable_all()
  else if debug = "LIST" then (
    List.iter print_endline (Netlog.Debug.names());
    exit 0
  )
  else (
    let l = Netstring_str.split (Netstring_str.regexp "[ \t\r\n]+") debug in
    List.iter
      (fun m -> Netlog.Debug.enable_module m)
      l
  );
  if (try ignore(Sys.getenv "DEBUG_WIN32"); true with Not_found -> false) then
    Netsys_win32.Debug.debug_c_wrapper true
;;

let _ =
  if Array.length Sys.argv != 2 then (
    print_endline ("Usage: "^Sys.argv.(0)^" PORT");
    exit 1
  );
  let port =
    int_of_string Sys.argv.(1)
  in
  Netsys_signal.init();
  conf_debug();
  start port
