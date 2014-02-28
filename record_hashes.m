function N = record_hashes(H)
	% from DPE's code
	global HashTable HashTableCounts
	% H is a matrix with the following properties : 
	% <song id><start time index><hash>
	% 16 bit 16 bit 32 bit
	maxnentries = size(HashTable,1); % 100
	nhash = size(H,1); % number of hashes
	N = 0;
	TIMESIZE = 16384;

	for i=1:nhash
		video_id = H(i,1);
		toffs = mod(round(H(i,2)), TIMESIZE); % not sure why, but this is basically the time offset
		hash = 1+H(i,3); % avoiding problem when hash == 0
		htcol = HashTable(:,hash); % fetches the hash-th column from HashTable
		nentries =  HashTableCounts(hash) + 1; % fetches the hash-th entry from HashTableCounts and adds 1
		if nentries <= maxnentries
			% put entry in next available slot
			r = nentries;
  		else
  			% choose a slot at random; will only be stored if it falls into
    		% the first maxnentries slots (whereupon it will replace an older 
    		% value).  This approach guarantees that all values we try to store
    		% under this hash will have an equal chance of being retained.
    		r = ceil(nentries*rand(1));
   		end

   		if r <= maxnentries
   			hashval = int32(video_id*TIMESIZE + toffs); % no idea why, but okay - offset time
   			HashTable(r,hash) = hashval;
   			N = N+1; 
   		end
   		HashTableCounts(hash) = nentries;
	end


end