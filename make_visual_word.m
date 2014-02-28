% load dictionary
centers = load('centers.mat');
centers = centers.c;

INPUT_PATH = 'copy/'

d = dir(INPUT_PATH);
isub = ~[d(:).isdir];
query_files = {d(isub).name}';

visual_word_list = zeros(size(centers,2),size(query_files,1));

for i=1:size(query_files,1)

	file_name = query_files{i};
	abs_file_path = strcat(INPUT_PATH,file_name);
	disp(abs_file_path);
	I = imread(abs_file_path);
	I = single(rgb2gray(I));
	% I = imresize(I,0.2);
	[F,D] = vl_sift(I);
	
	% assign a visual word to D
	size(D)
	for j=1:size(D,2)
		r = repmat(D(:,j),1,size(centers,2));
		d = sqrt(sum(abs(double(r) - centers).^2));
		[minval,minpos] = min(d);
		visual_word_list(minpos,i) = visual_word_list(minpos,i)+1.0/minval;
	end

	save('copy.mat','visual_word_list');

end

