function find_landmarks_par(video_path, every_nth_frame, track_ID, threshold)
	% L has the form : 
	% start-time-col start-freq-row end-freq-row delta-time
    
    track_id_str = track_ID;
    
    MatlabPath = getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH',getenv('PATH'));
    
    threshold = str2num(threshold);
    every_nth_frame = str2num(every_nth_frame);
    track_ID = str2num(track_ID);
    
	logNni = load('logNni1024.mat');
	logNni = logNni.l';

	centers = load('centers_surf_1024.mat');
	centers = centers.c;
    
    hash = [];
	% first, create a directory next to the video and fill it up with frames
	[pathstr,name,ext] = fileparts(video_path);
		
	mkdir(pathstr,'/temp');
	
	sample_system_command = ['ffmpeg -loglevel quiet -i "',video_path,'" -r ',num2str(every_nth_frame),' "',...
	pathstr,'/temp/%05d.png"'];

	system(sample_system_command);
	% now, extract sift features for each image

	d = dir(strcat(pathstr,'/','temp','/','*.png'));                                                                                   
	isub = ~[d(:).isdir];
	query_files = {d(isub).name}';


	visual_word_list = zeros(size(centers,2),size(query_files,1));

	for i=1:size(query_files,1)
		% something to extract SIFT
		file_name = query_files{i};
		abs_file_path = strcat(pathstr,'/','temp','/',file_name);
		% disp(abs_file_path);
		I = imread(abs_file_path);
		I = rgb2gray(I); % removed the conversion to single
		% I = single(I);
		% I = imresize(I,0.5);
		% [F,D] = vl_sift(I);
		points = detectSURFFeatures(I);
		[D, ~] = extractFeatures(I, points);
		D = D';
		% assign a visual word to D
		% size(D)
		% made some changes to introduce the tf-idf concept
		% For each SURF feature, find out which 

		vis_word = zeros(size(centers,2),1);
		nd = size(D,2);

		for j=1:size(D,2)
			r = repmat(D(:,j),1,size(centers,2));
			d = sqrt(sum(abs(double(r) - centers).^2));
			[minval,minpos] = min(d);
			% word j is closest to minpos 
			vis_word(minpos,1) = vis_word(minpos,1)+1;
			
		end

		vis_word = vis_word/nd;
		vis_word = vis_word.*logNni; 
        vis_word = vis_word./norm(vis_word);
		visual_word_list(:,i) = vis_word;

	end

	L = double(produce_hash(visual_word_list, track_ID, threshold));

    save(['L', track_id_str , '.mat'], 'L');
    
	rmdir(strcat(pathstr,'/temp'),'s');

end

function [all_hash_code] = produce_hash(visual_word_list, track_ID, threshold)
	
	% all_hash_code = zeros(1,64);
	% all_hash_code = uint8(all_hash_code);
	all_hash_code = [];
	% first, load spectrogram
	
	spectrogram = visual_word_list;

	% max(max(spectrogram))
	
	% now, find those robust constellation points
	% threshold = 0.15;
	spectrogram = double(spectrogram > threshold);
	spectrogram = double(spectrogram > imdilate(spectrogram, [1 1 1;1 0 1; 1 1 1]));
	% surf(spectrogram(1:100,1:100));colormap(gray);
	% finding maxima
	% sum(sum(spectrogram))
	% size(spectrogram)
	% first, list all anchor points
	[ii,jj] = find(spectrogram);
	coordinates = [ii jj];
	[nnidx,dists] = knnsearch(coordinates,coordinates,'K',11);
	% nnidx = nnidx(:,2:size(nnidx,2)); % all columns except first
	% dists = dists(:,2:size(dists,2));

	% nnidx
	% list all neighbours of anchor points. Time difference not more than 32 frames or 
	% five bits

	% threshold_distance = 32; If abs(end_freq - start_freq > 32)
	% end_freq - start_freq

	for i=1:size(nnidx,1)
		curr_row = coordinates(i,1);
		curr_col = coordinates(i,2);
		% each row contains neighbours of a given point
		for j=2:size(nnidx,2)

			hash_code = zeros(1,4);

			% get row,col of each neighbour
			neigh_row = coordinates(nnidx(i,j),1);
			neigh_col = coordinates(nnidx(i,j),2);

			% if too far away, don't bother
			if(abs(curr_row - neigh_row) > 31 || neigh_col < curr_col || (curr_row == neigh_row))
				continue;
            end
            % added a current row == neighbour row criterion to reduces 
            % spurious hashes
            
            
			% the above condition is because the target area is always to 
			% the right of the anchor point.
			
			
			% take each neighbor at a time. hash function is given by 
			% f1,f2,delta t
			% L has the form : 
			% start-time-col start-freq-row end-freq-row delta-time

			f1 = curr_row;
			f2 = neigh_row;
			deltat = neigh_col - curr_col;
			time_offset = curr_col;
			track_byte = track_ID;

			% concatenate bits
			hash_code = [time_offset f1 f2 deltat];
			all_hash_code = [all_hash_code;hash_code];
		end

	end

end
