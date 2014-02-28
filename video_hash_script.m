% %% First, get a list of all database files
% 
% 	hash_database = [];
% 
% 	Database_Path = 'Test_cases/Database'
% 	d = dir(strcat(Database_Path,'/','*.mpg'));                                                                                   
% 	isub = ~[d(:).isdir];
% 	database_files = {d(isub).name}'
% 
% 	every_nth_frame = 12.5;
% 
% 	for i=1:size(database_files,1)
% 		file_name = strcat(Database_Path,'/',database_files{i});
% 		hash = video_to_hash(file_name,every_nth_frame,i);
% 		size(hash)
% 		hash_database = [hash_database;hash];
% 	end
% 
% 	% now, sort the hash_database according to the first 32 bits
% 	[vv ii] = sort(bin2dec(hash_database(:,1:32)));
% 	hash_database = hash_database(ii,:);
% 
% 	save('hash_database.mat','hash_database');
% 
% %% Then, get a list of all query files
% 
%     hash_query = [];
% 
% 	Query_Path = 'Test_cases/Queries'
% 	d = dir(strcat(Query_Path,'/','*.mpg'));                                                                                   
% 	isub = ~[d(:).isdir];
% 	query_files = {d(isub).name}'
% 
% 	every_nth_frame = 12.5;
% 
% 	for i=4:4%size(query_files,1)
% 		file_name = strcat(Query_Path,'/',query_files{i});
% 		hash = video_to_hash(file_name,every_nth_frame,i);
% 		size(hash)
% 		hash_query = [hash_query;hash];
% 	end
% 
% 	% now, sort the hash_database according to the first 32 bits
% 	[vv ii] = sort(bin2dec(hash_query(:,1:32)));
% 	hash_query = hash_query(ii,:);
% 
% 	save('hash_query4.mat','hash_query');
%     
% %% Start matching
%     
%     db = load('hash_database.mat');
%     db = db.hash_database;
%     
%     q = load('hash_query4.mat');
%     q = q.hash_query;
%     
%     match_dbhash_to_qhash(db,q);
%     

%% Some preliminaries

    disp('Initializing');
    MatlabPath = getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH',getenv('PATH'));
    
    % run vl_setup
    run('../vlfeat-0.9.17/toolbox/vl_setup');
    
    % clear hash table
    clear_hash_table();
    

    
%% First, get a list of all database files

	hash_database = [];

	Database_Path = 'More_Serious_Tests/Database'
	d = dir(strcat(Database_Path,'/','*.mpg'));                                                                                   
	isub = ~[d(:).isdir];
	database_files = {d(isub).name}';

	every_nth_frame = 2;

	for i=1:size(database_files,1)
		file_name = strcat(Database_Path,'/',database_files{i})
		[N,T] = add_tracks(file_name, every_nth_frame, i)
    end
    
    disp('Finished indexing database');
    
%% Save HashTable if necessary
    
    globalVars = who('global');
    eval(sprintf('global %s', globalVars{1}));
    eval(sprintf('global %s', globalVars{2}));
    save('HashTable.mat','HashTable');
    save('HashTableCounts.mat','HashTableCounts');
    
    
%% Match Query : 

	Database_Path = 'More_Serious_Tests/Database'
	d = dir(strcat(Database_Path,'/','*.mpg'));                                                                                   
	isub = ~[d(:).isdir];
	database_files = {d(isub).name}'

    hash_query = [];

	Query_Path = 'Tiny_Tests/Queries'
	d = dir(strcat(Query_Path,'/','*.mpg'));                                                                                   
	isub = ~[d(:).isdir];
	query_files = {d(isub).name}'

	every_nth_frame = 2;

	for i=1:size(query_files,1)
        file_name = strcat(Query_Path,'/',query_files{i})
        [R,L] = match_query(file_name,every_nth_frame,i);
        disp(['Input = ',query_files{i},' Match = ',database_files{R(1,1)}]);
        R
    end
    

    
    