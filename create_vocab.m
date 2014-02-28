%% Add vlfeat library

% addpath('/fs/lamphomes/varunm/PANDORA/Fall_2013/VLAVS/vlfeat-0.9.17/toolbox/');
% run('vl_setup.m');

INPUT_PATH = 'INRIA_HOLIDAYS/';

% extract all query files.
d = dir(INPUT_PATH);
isub = ~[d(:).isdir];
query_files = {d(isub).name}';

all_sift_vectors = [];% zeros(128,149100);

for i=1:size(query_files,1)
	file_name = query_files{i};
	abs_file_path = strcat(INPUT_PATH,file_name);
	disp(abs_file_path);
	I = imread(abs_file_path);
	I = single(rgb2gray(I));
	I = imresize(I,0.2);
	[F,D] = vl_sift(I);
	% size(D)
	% randomly take 100 columns from D
	r = randperm(size(D,2));
	r = r(1:min(100,size(D,2)));
	D_small = D(:,r);
	all_sift_vectors = [all_sift_vectors D_small];

end

save('all_sift_vectors1.mat','all_sift_vectors');

