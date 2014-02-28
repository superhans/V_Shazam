function matched_video = match_dbhash_to_qhash(dbhash,qhash)

	% note : this implementation does not use inverted indexing

	% dbhash is 781 x 64 and qhash is 91 x 64

	% Extract first 32 bits of both
	dbhash_32 = dbhash(:,1:32)
	qhash_32 = qhash(:,1:32)

	% now, search for qhash_32 in dbhash_32

	matched_row = [];
	matched_in_qhash_row = [];
	count = 0;

	for i=1:size(qhash_32,1)
		curr_qhash_row = qhash_32(i,:);
		hash_pos = strmatch(curr_qhash_row,dbhash_32);
	
		if(isempty(hash_pos) == 0)
			matched_row = [matched_row;hash_pos];
			% matched_in_qhash_row = [matched_in_qhash_row i];
		end
	end

	
	matched_row = unique(matched_row);
	matched_video = [];

	% now, fetch the corresponding rows of matched_row in dbhash
	dbhash_relevant = dbhash(matched_row,:);
	% dbhash_relevant(:,33:48)
	% find the unique number of bins
	unique_track_ids = unique(dbhash_relevant(:,49:64),'rows');


	% now, for each row in unique_track_ids, find the relevant time stamps
	for i=1:size(unique_track_ids,1)
		x_y_pair = [];
		for j=1:size(dbhash_relevant,1)
			if(strcmp(unique_track_ids(i,:),dbhash_relevant(j,49:64)) == 1)
				matching_hash_code = dbhash_relevant(j,1:32);
				% database_time = bin2dec(dbhash_relevant(:,33:48));
				database_time = bin2dec(dbhash_relevant(j,33:48));
				matched_query_row = strmatch(matching_hash_code,qhash_32);
				% qhash_32(matched_query_row,:);
				query_time = bin2dec(qhash(matched_query_row,33:48));
				[x,y] = meshgrid(database_time, query_time);
				x_y_pair = [x_y_pair;x(:) y(:)];
			end
		end
		% x_y_pair
		% disp('*******************8');
		,figure,plot(x_y_pair(:,1),x_y_pair(:,2),'o');
		title(strcat('graph '));
		xlabel(num2str(bin2dec(unique_track_ids(i,:))));
		
	end

end