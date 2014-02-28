function clear_hash_table()
	global HashTable HashTableCounts
	nhashes = 2^20

	maxnentries = 100; % will need to change this number
	disp(['Max Entries per hash = ',num2str(maxnentries)]);
	HashTable = zeros(maxnentries, nhashes, 'uint32');
	HashTableCounts = zeros(1,nhashes);
end