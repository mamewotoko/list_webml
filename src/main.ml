open Printf
open Nethttp_client.Convenience

type expresssion =  Link | Audio | DataSource

(* TODO: config *)
let podcast_list = ["http://www.nhk.or.jp/rj/podcast/rss/english.xml";
"http://feeds.wsjonline.com/wsj/podcast_wall_street_journal_this_morning?format=xml";
"http://downloads.bbc.co.uk/podcasts/worldservice/tae/rss.xml";
"http://learningenglish.voanews.com/podcast/";
"http://www.tbsradio.jp/bakusho/rss.xml";
"http://www.tbsradio.jp/ijuin/rss.xml"]
;;

(* cannot get icon ... *)
(* cannot get title of rss ... *)
let track2html expresssion track =
  let metadata, uri = track in
  let title =
    try
      List.assoc "title" metadata
    with Not_found -> "" in
  let pubdate =
    try
      List.assoc "pubdate" metadata
    with Not_found -> "" in
  match expresssion with
    Link -> sprintf "<a class=\"list-group-item\" href=\"%s\">%s %s</a>\n"
 		    uri title pubdate
  | DataSource -> sprintf "<li class=\"list-group-item episode\" data-source=\"%s\">%s %s</li>\n"
 			  uri title pubdate
  | Audio -> sprintf "<li class=\"list-group-item\">%s %s<br><audio src=\"%s\" controls></audio></li>\n"
 		     title pubdate uri
;;

let episode_list_html expression url =
  let req = http_get_message url in
  match req # status with
    `Successful ->
    let xmlstr = req # response_body # value in
    let format = Xmlplaylist.Podcast in
    let tracks = Xmlplaylist.tracks ~format xmlstr in
    (* TODO: insert to mysql and filter new item *)
    String.concat "" (List.map (track2html expression) tracks)
  | _ -> "" 
;;

 
(* TODO: call podcast fetch part in async way *)
let generate (cgi : Netcgi.cgi_activation) =
  let expression =
    if cgi # argument_exists "aslink" then
      Link
    else if cgi # argument_exists "audio" then
      Audio
    else
      DataSource in
  let podcast_list =
    if cgi # argument_exists "url" then
      [cgi # argument_value "url"]
    else
      podcast_list in
  let listdata = podcast_list |> List.map (episode_list_html expression) |> String.concat "\n" in
  (* A Netcgi-based content provider *)
  cgi # set_header
    ~cache:`No_cache
    ~content_type:"text/html; charset=\"utf-8\""
    ();
  let data =
    "<html lang-\"ja\"><head><title>PodplayerWeb</title>\n"^
      "<meta charset=\"utf-8\" />"^
      "<meta name=\"viewport\" content=\"width=device-width\" />\n"^
	"<link rel=\"stylesheet\" href=\"/resource/bootstrap/css/bootstrap.min.css\" type=\"text/css\" />\n" ^
	"<link rel=\"stylesheet\" href=\"/resource/css/main.css\" type=\"text/css\" />\n" ^
	   "<script src=\"/resource/jquery/jquery-2.2.3.min.js\"></script>" ^
	   "<script src=\"/resource/bootstrap/js/bootstrap.min.js\"></script>" ^
       "</head>\n" ^
	 "  <body>" ^
	   (match expression with
	      Link -> "<div class=\"container\"><div class=\"list-group\">\n"
	      | DataSource -> "<script src=\"/resource/js/main.js\"></script>" ^
               "<nav class=\"navbar navbar-default navbar-fixed-top\">" ^
 	       "<div class=\"container\" id=\"audio_container\" ><audio id=\"audio\" controls></audio></div>" ^
               "</nav>" ^
	       "<div class=\"container\"><ul id=\"podcast_list\" class=\"list-group\">\n"
	    | Audio -> "<ul class=\"list-group\">\n"
	   ) ^
	     listdata ^
	       (match expression with
		  Link -> "</div>"
		| DataSource -> "</ul>"
		| Audio -> "</ul>") ^
	      "</div></body></html>" in
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
