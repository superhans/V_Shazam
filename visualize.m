function [spectrogram] = visualize(video_path, every_nth_frame)

	% L has the form : 
	% start-time-col start-freq-row end-freq-row delta-time

	logNni = load('logNni1024.mat');
	logNni = logNni.l';

	centers = load('centers_surf_1024.mat');
	centers = centers.c;
    
    hash = [];
	% first, create a directory next to the video and fill it up with frames
	[pathstr,name,ext] = fileparts(video_path);
		
	mkdir(pathstr,'/temp');
	
	sample_system_command = ['ffmpeg -loglevel quiet -i ',video_path,' -r ',num2str(every_nth_frame),' ',...
	pathstr,'/temp/%05d.png'];

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

		if(size(D,2) ~= 0)
			for j=1:size(D,2)
				r = repmat(D(:,j),1,size(centers,2));
				d = sqrt(sum(abs(double(r) - centers).^2));
				[minval,minpos] = min(d);
				% word j is closest to minpos 
				vis_word(minpos,1) = vis_word(minpos,1)+1;
				
			end

			vis_word = vis_word/nd; % could be nan
			vis_word = vis_word.*logNni; 
	        vis_word = vis_word./norm(vis_word);% could be nan
	    end 

		visual_word_list(:,i) = vis_word;

	end

	spectrogram = visual_word_list;
	
	% now, find those robust constellation points
	threshold = 0.15;
	spectrogram = double(spectrogram > threshold);
	spectrogram = double(spectrogram > imdilate(spectrogram, [1 1 1;1 0 1; 1 1 1]));
	
	,figure,h = surf(spectrogram);set(h,'edgecolor','none');colormap('gray');view(2);
	set(gca,'XTick',1:size(spectrogram,2));
	
	rmdir(strcat(pathstr,'/temp'),'s');

end
