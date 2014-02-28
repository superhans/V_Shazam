function [hash] = video_to_hash(video_path, every_nth_frame, track_ID)

	centers = load('centers.mat');
	centers = centers.c;
    
    hash = [];
	% first, create a directory next to the video and fill it up with frames
	[pathstr,name,ext] = fileparts(video_path);
	pathstr
	name
	ext
	
	mkdir(pathstr,'/temp');
	
	sample_system_command = ['ffmpeg -i ',video_path,' -r ',num2str(every_nth_frame),' ',...
	pathstr,'/temp/%05d.png']

	system(sample_system_command);
	% now, extract sift features for each image

	d = dir(strcat(pathstr,'/','temp','/','*.png'));                                                                                   
	isub = ~[d(:).isdir];
	query_files = {d(isub).name}'


	visual_word_list = zeros(size(centers,2),size(query_files,1));

	for i=1:size(query_files,1)

		% something to extract SIFT
		file_name = query_files{i};
		abs_file_path = strcat(pathstr,'/','temp','/',file_name);
		disp(abs_file_path);
		I = imread(abs_file_path);
		I = single(rgb2gray(I));
		% I = imresize(I,0.5);
		[F,D] = vl_sift(I);
	
		% assign a visual word to D
		size(D)
		for j=1:size(D,2)
			r = repmat(D(:,j),1,size(centers,2));
			d = sqrt(sum(abs(double(r) - centers).^2));
			[minval,minpos] = min(d);
			visual_word_list(minpos,i) = visual_word_list(minpos,i)+1.0/minval;
		end


	end

	hash = produce_hash(visual_word_list, track_ID)
	size(hash)

	rmdir(strcat(pathstr,'/temp'),'s');

end

function [all_hash_code] = produce_hash(visual_word_list, track_ID)
	
	% all_hash_code = zeros(1,64);
	% all_hash_code = uint8(all_hash_code);
	all_hash_code = [];
	% first, load spectrogram
	
	spectrogram = visual_word_list;
	
	% now, find those robust constellation points
	threshold = 0.015;
	spectrogram = double(spectrogram > threshold);
	spectrogram = double(spectrogram > imdilate(spectrogram, [1 1 1;1 0 1; 1 1 1]));
	% surf(spectrogram(1:100,1:100));colormap(gray);
	% finding maxima
	sum(sum(spectrogram))
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

	threshold_distance = 32;
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
			f1 = dec2bin(curr_row-1,10);
			% neigh_row
			f2 = dec2bin(neigh_row-1,10);
			deltat = dec2bin(neigh_col - curr_col,12);
			time_offset = dec2bin(curr_col-1,16);
			track_byte = dec2bin(track_ID-1,16);

			% concatenate bits
			hash_code = num2str([f1,f2,deltat,time_offset,track_byte],'%d');
			all_hash_code = [all_hash_code;hash_code];
		end

	end

	all_hash_code

	% sort
	[vv ii] = sort(bin2dec(all_hash_code(:,1:32)));
	all_hash_code = all_hash_code(ii,:);

end

function out = de2bi(data,nBits)

	powOf2 = 2.^[0:nBits-1];

	%# do a tiny bit of error-checking
	if data > sum(powOf2)
	   error('not enough bits to represent the data')
	end

	out = false(1,nBits);

	ct = nBits;

	while data>0
		if data >= powOf2(ct)
		data = data-powOf2(ct);
		out(ct) = true;
		end
		ct = ct - 1;
	end

end