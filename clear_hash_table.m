function clear_hash_table()
	global HashTable HashTableCounts
	nhashes = 2^22;

	maxnentries = 2000; % will need to change this number
	disp(['Max Entries per hash = ',num2str(maxnentries)]);
	% HashTable = zeros(maxnentries, nhashes, 'uint32');
    HashTable = spalloc(maxnentries, nhashes, 10000000);
	HashTableCounts = zeros(1,nhashes);
end