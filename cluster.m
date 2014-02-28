addpath('/fs/lamphomes/varunm/PANDORA/Fall_2013/VLAVS/vlfeat-0.9.17/toolbox/');
run('vl_setup.m');

n_centers = 256;
all_sift_vectors = load('all_sift_vectors1.mat');
all_sift_vectors = single(all_sift_vectors.all_sift_vectors);
disp('finished loading data');
[c,a] = vl_kmeans(all_sift_vectors,n_centers);
disp('finished clustering. now saving');
save('centers_256.mat','c');