function dbc=db_connect(db,server, user,pswd)

% DBC=db_connect(db,server,user,pswd)
%
% Connect to database.
% 
% Inputs: 
%  db   = database name, string (e.g.: 'ifcb_mouw2')
%  server = host name, string (e.g.: 'phytoplankton.upmc.edu')
%  user = user name, string (e.g.: 'virginie')
%  pswd = (optional) user password, string, (e.g: 'Restmonami')
%
% Outputs:
%  DBC = data base object
% 

% Created on November 5, 2009 by AB
% Modified on 2021-10-27 by VS

%% Set-up the driver and port 

driver='com.mysql.jdbc.Driver'; % CHANGE if needed based on your database
server=['jdbc:mysql://' server '/'];

%% Open the database connection 

dbc=database(db,user,pswd,driver,server);

if ~isopen(dbc)
    fprintf('\nFailed to connect to %s.\n',db);
end