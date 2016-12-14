Overview.
This is a skeleton application that demonstrates "Tree Node" functionality.
Application has got HTML + AngularJS as front end and Perl + MySQL for back end.


GUI.
GUI allows to see nodes as list.
"Depth up to":  show/hide nodes after certain depth.
"+" symbol:     add a sub-node.
"-" symbol:     delete node and sub-nodes.
"Add" button:   adds new node for provided parent node.

Bower was used to setup angularjs for the project.


Back end.
Perl Plack is used: it lets us wrap web services into other apps. This project uses App::JSon wrapper to modify output before sending to GUI (change status on error + JSON). Please see perl modules for more details.
MySQL as DB backend. dbicdump generated perl binding using conf/schema.conf config file.


Installation.
If you do not have cpanm then install it:
cpan App::cpanminus

Required packages:
cpanm Plack HTTP::Router::Declare JSON DBIx::Class DBD::mysql

Optional (used by bin/start)
cpanm Starman 

For testing:
cpanm DBIx::Mint;


SQL configuration.
You can use below commands to configure database for the app.

mysqladmin create app

mysql -u root -p
(log in to mysql as root)
grant all privileges on app.* to 'app'@'localhost' identified by 'app';
flush privileges;
exit

mysql -u app -p app < conf/populate.sql

The app uses database/username/password as mentioned in bin/app.pl file.


Start/Stop.
The app can be started using below command. After start app is available on port :5000 by default.
plackup -I lib bin/app.pl &
and terminated using "kill PID". The & is added since console stops reacting to Ctrl+C if started as above.
There also are bin/start and bin/stop scripts. Please install Starman to use them. Port is :8888.


Testing.
You can run t/App/Services.t script. It creates temp database using DBIx::Mint, populates it (using SQL at the bottom of t/Test/DB.pm) and creates $schema connection to it.

How to improve.
GUI can be improved using css templates like bootstrap-css and/or angular-bootsrap.
Static content can be provided by apache http server, example: conf/01_app.conf
Plack::Middleware modules can improve app without code modification: authentication, debugging, profiling, etc.
