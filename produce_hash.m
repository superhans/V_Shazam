function [all_hash_code] = produce_hash()
	
	track_ID = 1;
	all_hash_code = zeros(1,64);
	all_hash_code = uint8(all_hash_code);

	% first, load spectrogram
	spectrogram = load('orig.mat');
	spectrogram = spectrogram.visual_word_list;

	% now, find those robust constellation points
	threshold = 0.02;
	spectrogram = double(spectrogram > threshold);
	spectrogram = double(spectrogram > imdilate(spectrogram, [1 1 1;1 0 1; 1 1 1]));
	% finding maxima
	size(spectrogram)
	% first, list all anchor points
	[ii,jj] = find(spectrogram);
	coordinates = [ii jj];
	[nnidx,dists] = knnsearch(coordinates,coordinates,'K',11);
	% nnidx = nnidx(:,2:size(nnidx,2)); % all columns except first
	% dists = dists(:,2:size(dists,2));

	% nnidx
	% list all neighbours of anchor points. Time difference not more than 32 frames or 
	% five bits

	threshold_distance = 256;
	for i=1:size(nnidx,1)
		curr_row = coordinates(i,1);
		curr_col = coordinates(i,2);
		% each row contains neighbours of a given point
		for j=2:size(nnidx,2)

			hash_code = zeros(1,64);

			% get row,col of each neighbour
			neigh_row = coordinates(nnidx(i,j),1);
			neigh_col = coordinates(nnidx(i,j),2);

			% if too far away, don't bother
			if(dists(i,j) >= threshold_distance || neigh_col < curr_col)
				continue;
			end
			% the above condition is because the target area is always to 
			% the right of the anchor point.
			
			
			% take each neighbor at a time. hash function is given by 
			% f1,f2,delta t
			f1 = de2bi(curr_row-1,10);
			% neigh_row
			f2 = de2bi(neigh_row-1,10);
			deltat = de2bi(neigh_col - curr_col,12);
			time_offset = de2bi(curr_col-1,16);
			track_byte = de2bi(track_ID-1,16);

			% concatenate bits
			hash_code = num2str([f1,f2,deltat,time_offset,track_byte],'%d');
			all_hash_code = [all_hash_code;hash_code];
		end

	end

	% sort
	[vv ii] = sort(bin2dec(all_hash_code(:,1:32)));
	all_hash_code = all_hash_code(ii,:);

	save('all_hash_code_orig.mat','all_hash_code');


end