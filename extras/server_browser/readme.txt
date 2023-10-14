SERVER BROWSER - derpy54320

install:
 1. install derpy's script loader 7.1 or better
 2. put server_browser.zip into _derpy_script_loader/scripts (the whole zip file, not extracted)

usage:
 press F1 to open the server browser if not connected to a server
 you can also hold F1 while connected to a server to disconnect from it

config:
 for security, derpy's script loader doesn't allow networking by default *and* it only allows servers added by the user to be "listed"
 open _derpy_script_loader/config.txt so you can set allow_networking to true and add any servers you want shown by adding list_server lines

direct:
 the server browser offers no "direct connect" button because this is already something you can do without the browser
 open the console (using ~ or `) and type "connect" followed by the ip you want to connect to (for example: connect 64.176.196.254)