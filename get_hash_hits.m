function R = get_hash_hits(H)

	% Each element of H is a <(20 bit) hash value> or 24 bit in our case

	if(size(H,2) == 3)
		% discard first column, i.e. song_id
		H = H(:,[2,3]);
	end

	if min(size(H))==1
		% if H is [1 2 3] or [1 2 3]' (single row or single column), then make it [0 1;0 2;0 3]. No idea why. 
		H = [zeros(length(H),1),H(:)];
	end

	global HashTable HashTableCounts
    size(HashTable)
	nhtcols = size(HashTable,1); %gets the number of rows of HashTable

	TIMESIZE=16384; % pissing me off

	Rsize = 1000;  % preallocate
	R = zeros(Rsize,3); % Create a 1000 X 3 matrix. 
	Rmax = 0;

    
    % disp('Finsihed this bit');
	for i=1:length(H)
		hash = H(i,2); % get the hash
		htime = double(H(i,1)); % get the exact time offset
		nentries = min(nhtcols,HashTableCounts(hash+1)); % which is lower, number of rows of HashTable or HashTableCounts ?
		htcol = double(HashTable(1:nentries,hash+1)); % obtain all those rows for the hash+1 th column
		video_id = floor(htcol/TIMESIZE); % I think we obtain the videoID through this
		times = round(htcol-video_id*TIMESIZE); % the explanation given is : 
		%    If H is a 2 column matrix, the first element is taken as a
		%    time base which is subtracted from the start time index for
		%    the retrieved hashes.

		if Rmax+nentries > Rsize
    		R = [R;zeros(Rsize,3)];
    		Rsize = size(R,1);
  	    end

  	    dtimes = times-htime;
  	    R(Rmax+[1:nentries],:) = [video_id, dtimes, repmat(double(hash),nentries,1)];
  		Rmax = Rmax + nentries;

    end
    % disp('And this bit');
	R = R(1:Rmax,:);
    % disp('But not this');
end
